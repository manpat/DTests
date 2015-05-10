module main;

import denj.system.window;
import denj.system.input;
import denj.graphics;
import denj.utility;
import denj.math;
import std.math;
import std.traits;

// For keys
import derelict.opengl3.gl;
import derelict.sdl2.sdl;

uint program;
float t = 0f;
mat3 rotation;

void main(){
	enum Width = 800;
	enum Height = 600;
	enum Aspect = cast(float)Height/Width;

	Window.Init(Width, Height, "Stencil Test");
	Input.Init();
	Renderer.Init();
	program = GenShader();

	Setup();

	glFrontFace(GL_CW);
	glEnable(GL_STENCIL_TEST);
	glEnable(GL_CULL_FACE);

	auto scale = 1f/8f;
	auto n = 0.1f;
	auto f = 100f;
	auto rig = 0.5f * scale;
	auto top = Aspect/2f * scale;
	auto projection = mat4(
		n/rig, 0, 0, 0,
		0, n/top, 0, 0,
		0, 0, -(f+n)/(f-n), -2f*f*n/(f-n),
		0, 0, -1, 0
	);

	glEnableVertexAttribArray(0);
	while(Window.IsOpen()){
		Window.FrameBegin();

		t += 0.01f;

		if(Input.GetKeyDown(SDLK_ESCAPE)){
			Window.Close();
		}

		// Make sure glClear is allowed to write to all buffers
		glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
		glDepthMask(GL_TRUE);
		glStencilMask(0xff);
		glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);

		float ang = sin(t*0.5)*PI/2f;
		rotation = mat3(
			cos(ang),  0,-sin(ang),
			0,       1, 0,     
			sin(ang),  0, cos(ang),
		);

		glUniformMatrix4fv(glGetUniformLocation(program, "projection"), 1, GL_TRUE, projection.data.ptr);
		glUniformMatrix3fv(glGetUniformLocation(program, "transform"), 1, GL_FALSE, rotation.data.ptr);
		glUniform1f(glGetUniformLocation(program, "scale"), 1f);
		glUniform1f(glGetUniformLocation(program, "offset"), 0f);
		glUniform1f(glGetUniformLocation(program, "time"), t);
		DrawMainScene();

		Window.Swap();
		Window.FrameEnd();
	}
}

struct VBO{
	int verts;
	uint vbo;
}

VBO cube;
VBO portals;
void Setup(){
	auto cubeData = [
		vec3(-1, 1,-1),
		vec3(-1, 1, 1),
		vec3(-1,-1, 1),

		vec3(-1, 1,-1),
		vec3(-1,-1, 1),
		vec3(-1,-1,-1),

		vec3(-1, 1, 1),
		vec3( 1, 1, 1),
		vec3( 1,-1, 1),

		vec3(-1, 1, 1),
		vec3( 1,-1, 1),
		vec3(-1,-1, 1),

		vec3( 1, 1,-1),
		vec3( 1,-1, 1),
		vec3( 1, 1, 1),

		vec3( 1, 1,-1),
		vec3( 1,-1,-1),
		vec3( 1,-1, 1),
	];

	enum ps = 0.95f;
	auto portalData = [
		vec3(-1, ps,-ps),
		vec3(-1, ps, ps),
		vec3(-1,-ps, ps),

		vec3(-1, ps,-ps),
		vec3(-1,-ps, ps),
		vec3(-1,-ps,-ps),

		vec3(-ps, ps, 1),
		vec3( ps, ps, 1),
		vec3( ps,-ps, 1),

		vec3(-ps, ps, 1),
		vec3( ps,-ps, 1),
		vec3(-ps,-ps, 1),
	];

	cube.verts = cast(int) cubeData.length;
	portals.verts = cast(int) portalData.length;

	glGenBuffers(1, &cube.vbo);
	glBindBuffer(GL_ARRAY_BUFFER, cube.vbo);
	glBufferData(GL_ARRAY_BUFFER, cube.verts*vec3.sizeof, cubeData.ptr, GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);

	glGenBuffers(1, &portals.vbo);
	glBindBuffer(GL_ARRAY_BUFFER, portals.vbo);
	glBufferData(GL_ARRAY_BUFFER, portals.verts*vec3.sizeof, portalData.ptr, GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

void DrawMainScene(){
	glBindBuffer(GL_ARRAY_BUFFER, portals.vbo);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null);

	// Draw portals into depth buffer
	glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
	glDepthMask(GL_TRUE);
	glStencilMask(0x0);
	glDrawArrays(GL_TRIANGLES, 0, portals.verts);

	// Enable writing to stencil buffer for masks
	// glColorMask(GL_FALSE, GL_FALSE, GL_TRUE, GL_TRUE);
	glDepthMask(GL_FALSE);
	glStencilMask(0xff);

	// Draw masks
	// Using the separate version means that backfaces never show through
	glStencilOpSeparate(GL_FRONT, GL_REPLACE, GL_KEEP, GL_KEEP);
	glStencilOpSeparate(GL_BACK, GL_KEEP, GL_KEEP, GL_KEEP);

	// First mask
	glStencilFunc(GL_NEVER, 1, 0xff);
	glDrawArrays(GL_TRIANGLES, 0, portals.verts/2);

	// Second mask
	glStencilFunc(GL_NEVER, 2, 0xff);
	glDrawArrays(GL_TRIANGLES, portals.verts/2, portals.verts/2);

	// Disable writing to stencil buffer when drawing scenes
	glDepthMask(GL_TRUE);
	glStencilMask(0x0);

	// Reset rotation
	glUniformMatrix3fv(glGetUniformLocation(program, "transform"), 1, GL_FALSE, mat3.identity.data.ptr);

	glBindBuffer(GL_ARRAY_BUFFER, cube.vbo);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null);

	// Draw first subscene
	glUniform1f(glGetUniformLocation(program, "scale"), sin(t)*0.3f + 0.5f);
	glUniform1f(glGetUniformLocation(program, "offset"), 0f);
	
	glColorMask(GL_TRUE, GL_FALSE, GL_FALSE, GL_TRUE);
	glStencilFunc(GL_EQUAL, 1, 0xff);
	glDrawArrays(GL_TRIANGLES, 0, cube.verts);

	// Draw second subscene
	glUniform1f(glGetUniformLocation(program, "scale"), 0.5f);
	glUniform1f(glGetUniformLocation(program, "offset"), sin(t));

	glColorMask(GL_FALSE, GL_TRUE, GL_FALSE, GL_TRUE);
	glStencilFunc(GL_EQUAL, 2, 0xff);
	glDrawArrays(GL_TRIANGLES, 0, cube.verts);

	// Restore transform so it lines up with portals and draw main scene
	glUniformMatrix3fv(glGetUniformLocation(program, "transform"), 1, GL_FALSE, rotation.data.ptr);
	glUniform1f(glGetUniformLocation(program, "scale"), 1.02f + sin(t*3f)*0.01f);
	glUniform1f(glGetUniformLocation(program, "offset"), 0f);
	
	glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
	glStencilFunc(GL_EQUAL, 0, 0xff);
	glDrawArrays(GL_TRIANGLES, 0, cube.verts);

	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

uint GenShader(){
	auto program = glCreateProgram();
	
	auto vsrc = 
	`#version 330

	uniform float time;
	uniform float scale;
	uniform float offset;
	uniform mat4 projection;
	uniform mat3 transform;
	in vec3 pos;

	void main(){
		vec3 tpos = (transform*(pos*scale) + vec3(offset, 0f, -4f));
		vec4 ppos = projection*vec4(tpos, 1f);
		gl_Position = ppos;
	}`.dup ~ '\0';

	auto fsrc = 
	`#version 330

	uniform float scale;
	out vec4 color;
	void main(){
		color = vec4(vec3(scale), 1);
	}`.dup ~ '\0';
	
	auto vsh = glCreateShader(GL_VERTEX_SHADER);
	auto vsrcp = vsrc.ptr;
	glShaderSource(vsh, 1, &vsrcp, null);
	glCompileShader(vsh);
	GLint status;
	glGetShaderiv(vsh, GL_COMPILE_STATUS, &status);
	if(status == GL_FALSE){
		char[] buffer = new char[512];
		glGetShaderInfoLog(vsh, 512, null, buffer.ptr);

		Log(buffer);
		throw new Exception("Shader compile fail");
	}

	auto fsh = glCreateShader(GL_FRAGMENT_SHADER);
	auto fsrcp = fsrc.ptr;
	glShaderSource(fsh, 1, &fsrcp, null);
	glCompileShader(fsh);
	glGetShaderiv(fsh, GL_COMPILE_STATUS, &status);
	if(status == GL_FALSE){
		char[] buffer = new char[512];
		glGetShaderInfoLog(fsh, 512, null, buffer.ptr);

		Log(buffer);
		throw new Exception("Shader compile fail");
	}

	glAttachShader(program, vsh);
	glAttachShader(program, fsh);
	glBindFragDataLocation(program, 0, "color");
	glLinkProgram(program);
	glDeleteShader(vsh);
	glDeleteShader(fsh);

	glUseProgram(program);

	return program;
}