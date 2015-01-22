import std.random;
import std.stdio;
import std.conv;
import std.math;

import shader;
import cruft;

import vertexarray;
import camera;
import input;
import hud;
import gl;

void main(){
	try{
		InitCruft();
		scope(exit) DeinitCruft();

		auto shader = new Shader("shaders/passthrough.glsl", "draw");
		auto posAttr = shader.GetAttribute("position");
		auto uvAttr = shader.GetAttribute("uv");

		InitHUD();
		InitInput();

		auto camera = new Camera;

		float aspect = 8f/6f;
		mat4 projectionMatrix = projection(60f, aspect, 0.1, 500);
		shader.SetUniform("projectionMatrix", projectionMatrix);

		double dt = 0f;

		double t = 0f;
		bool running = true;
		bool emit = false;

		enum framecap = 100;
		uint framecount = 0;
		double frameaccum = 0;
		double fps = 0;

		auto quad = SetUpQuad();
		auto texArray = SetUpTextureArray();
		auto indexTex = SetUpIndexTexture();

		while(running){
			SDL_Event e;
			CheckInputEvents(&e);

			if(GetKey(SDLK_ESCAPE)){
				running = false;
			}

			auto pt = SDL_GetTicks()/1000f;
			dt = pt - t;
			t = pt;

			frameaccum += dt;
			framecount++;
			if(frameaccum >= 0.25f){
				fps = cast(double)framecount / frameaccum;
				frameaccum = 0;
				framecount = 0;
			}

			shader.Use();

			camera.Update();

			shader.SetUniform!float("time", t);
			shader.SetUniform("projectionMatrix", projectionMatrix);

			glClearColor(0f, 0f, 0f, 1f);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

			posAttr.Enable();
			uvAttr.Enable();

			quad.verts.Bind(posAttr);
			quad.uvs.Bind(uvAttr);

			glActiveTexture(GL_TEXTURE0);
			glBindTexture(GL_TEXTURE_2D, indexTex);
			shader.SetUniform("indexTex", 0);

			glActiveTexture(GL_TEXTURE2);
			glBindTexture(GL_TEXTURE_2D_ARRAY, texArray);
			shader.SetUniform("texArray", 2);

			MatrixStack.Push();

				MatrixStack.top = MatrixStack.top * mat4.translation(sin(t), sin(t*2f)*0.4f, 0);
				glDrawArrays(GL_TRIANGLES, 0, quad.verts.length);

			MatrixStack.Pop();

			quad.verts.Unbind();
			quad.uvs.Unbind();

			posAttr.Disable();
			uvAttr.Disable();

			glClear(GL_DEPTH_BUFFER_BIT);

			PrintHUD!(GUIAnchor.Left)(to!string(fps) ~ " fps", vec2(-0.98, 0.9));

			Swap();
		}

	}catch(Exception e){
		writeln(e.file, ":", e.line, ": ", e.msg);
	}
}

mat4 projection(float fov, float a, float n, float f){
	float D2R = PI/180f;
	float ys = 1f / tan(D2R * fov / 2);
	float xs = ys / a;
	float fn = 1f / (f-n);

	return mat4(xs, 0, 0, 0,
				0, ys, 0, 0,
				0, 0, -(f+n)*fn,-2*f*n*fn,
				0, 0, -1, 0);
}

GLuint SetUpTextureArray(){
	enum width = 2;
	enum height = 2;
	enum numtextures = 3;
	enum mipcount = 1;

	auto data = [
		// 0
		vec3(1, 0, 1),
		vec3(1, 1, 0),
		vec3(1, 0, 1),
		vec3(1, 1, 0),

		// 1
		vec3(0, 1, 1),
		vec3(0, 1, 1),
		vec3(0, 1, 0),
		vec3(0, 1, 0),

		// 2
		vec3(0, 0, 1),
		vec3(0, 0, 0),
		vec3(0, 0, 0),
		vec3(0, 0, 1),
	];

	GLuint tex = 0;

	cgl!glGenTextures(1, &tex);
	cgl!glBindTexture(GL_TEXTURE_2D_ARRAY, tex);
	cgl!glTexStorage3D(GL_TEXTURE_2D_ARRAY, mipcount, GL_RGBA32F, width, height, numtextures);
	cgl!glTexSubImage3D(GL_TEXTURE_2D_ARRAY, 0, 0, 0, 0, width, height, numtextures, GL_RGB, GL_FLOAT, data.ptr);

	cgl!glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	cgl!glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	cgl!glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_WRAP_S, GL_REPEAT);
	cgl!glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_WRAP_T, GL_REPEAT);

	return tex;
}

GLuint SetUpIndexTexture(){
	GLuint tex = 0;

	ubyte[] data = [
		0, 2, 2, 2,
		0, 0, 1, 2,
		0, 1, 1, 1,
		2, 2, 2, 2,
	];

	cgl!glGenTextures(1, &tex);
	cgl!glBindTexture(GL_TEXTURE_2D, tex);

	cgl!glTexStorage2D(GL_TEXTURE_2D, 1, GL_R8, 4, 4);
	cgl!glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 4, 4, GL_RED, GL_UNSIGNED_BYTE, data.ptr);

	cgl!glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	cgl!glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	cgl!glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	cgl!glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	return tex;
}

struct Quad {
	VertexArray!vec3 verts;	
	VertexArray!vec2 uvs;
}

Quad SetUpQuad(){
	Quad quad;
	quad.verts = new VertexArray!vec3;
	quad.uvs = new VertexArray!vec2;

	quad.verts.Load([
		vec3(-1,-1, 0),
		vec3( 1, 1, 0),
		vec3(-1, 1, 0),
		
		vec3(-1,-1, 0),
		vec3( 1,-1, 0),
		vec3( 1, 1, 0),
	]);

	quad.uvs.Load([
		vec2( 0, 1),
		vec2( 1, 0),
		vec2( 0, 0),
		
		vec2( 0, 1),
		vec2( 1, 1),
		vec2( 1, 0),
	]);

	return quad;
}