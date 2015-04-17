module main;

import denj.system.window;
import denj.system.input;
import denj.utility;
import denj.math;
import std.math;

// For keys
import derelict.opengl3.gl;
import derelict.sdl2.sdl;

void main(){
	auto window = new Window(800, 600, "Stencil Test");
	auto input = new Input();
	auto program = GenShader();

	uint vao;
	glGenVertexArrays(1, &vao);
	glBindVertexArray(vao);

	glFrontFace(GL_CW);
	glEnable(GL_STENCIL_TEST);

	auto verts = [
		vec2( 0, 1),
		vec2( 1,-1),
		vec2(-1,-1),
	];

	uint triangle = 0;
	glGenBuffers(1, &triangle);
	glBindBuffer(GL_ARRAY_BUFFER, triangle);
	glBufferData(GL_ARRAY_BUFFER, verts.length*vec2.sizeof, verts.ptr, GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);

	void DrawTriangle(float scale = 1f, float offset = 0f){
		glUniform1f(glGetUniformLocation(program, "scale"), scale);
		glUniform1f(glGetUniformLocation(program, "offset"), offset);
		
		glBindBuffer(GL_ARRAY_BUFFER, triangle);
		glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, null);
		glDrawArrays(GL_TRIANGLES, 0, 3);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}

	glEnableVertexAttribArray(0);
	float t = 0f;
	while(window.IsOpen()){
		t += 0.03f;

		window.FrameBegin();
		window.Update();

		if(input.KeyPressed(SDLK_ESCAPE)){
			window.Close();
		}

		glStencilMask(0xff);
		glClearColor(0.05,0.05,0.05,1);
		glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);

		glColorMask(GL_FALSE,GL_FALSE,GL_FALSE,GL_FALSE);
		glDepthMask(GL_FALSE);

		//glColorMask(GL_TRUE,GL_FALSE,GL_FALSE,GL_FALSE);

		// Big triangle mask
		glStencilFunc(GL_ALWAYS, 1, 0xff);
		glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
		DrawTriangle(1.4f);

		// Small moving triangle mask
		glStencilOp(GL_KEEP, GL_KEEP, GL_INVERT);
		DrawTriangle(0.5f + sin(t)*0.2, cos(t/2f));
		DrawTriangle(0.7f, cos(t/3f));
		DrawTriangle(0.3f, cos(t/5f));

		// Enable colour, disable stencil
		glColorMask(GL_TRUE,GL_TRUE,GL_TRUE,GL_TRUE);
		glDepthMask(GL_TRUE);
		glStencilMask(0x0);

		// Draw big tri only if stencil == 1
		glStencilFunc(GL_EQUAL, 1, 0xff);
		glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
		DrawTriangle(0.8f, sin(t));

		// Draw smaller tri only if stencil != 1
		glStencilFunc(GL_NOTEQUAL, 1, 0xff);
		DrawTriangle(0.7f, sin(t+0.05));

		window.Swap();
	}
}

uint GenShader(){
	auto program = glCreateProgram();
	
	auto vsrc = 
	`#version 330

	uniform float scale;
	uniform float offset;
	in vec2 pos;

	void main(){
		gl_Position = vec4(pos*scale + vec2(offset, 0), 0, 1);
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