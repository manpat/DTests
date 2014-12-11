import std.stdio;
import std.conv;
import std.math;
import std.random;
import derelict.sdl2.sdl;

import cruft;
import shader;

import vertexarray;
import camera;
import gl;

void main(){
	try{
		InitCruft();
		scope(exit) DeinitCruft();

		auto shader = new Shader("shaders/vanilla.glsl", "draw");
		auto posAttr = shader.GetAttribute("position");

		float v = (1.0 + sqrt(5.0)) / 2.0;
		auto verts = new VertexArray!vec3();
		verts.Load([
			vec3(-1,  v,  0), // 0
			vec3( 1,  v,  0),
			vec3(-1, -v,  0),
			vec3( 1, -v,  0),

			vec3( 0, -1,  v), // 4
			vec3( 0,  1,  v),
			vec3( 0, -1, -v),
			vec3( 0,  1, -v),

			vec3( v,  0, -1), // 8
			vec3( v,  0,  1),
			vec3(-v,  0, -1),
			vec3(-v,  0,  1),
		]);

		auto indices = new VertexArray!uint(GL_ELEMENT_ARRAY_BUFFER);
		indices.Load([
			0, 11, 5,
			0, 5, 1,
			0, 1, 7,
			0, 7, 10,
			0, 10, 11,

			1, 5, 9,
			5, 11, 4,
			11, 10, 2,
			10, 7, 6,
			7, 1, 8,

			3, 9, 4,
			3, 4, 2,
			3, 2, 6,
			3, 6, 8,
			3, 8, 9,

			4, 9, 5,
			2, 4, 11,
			6, 2, 10,
			8, 6, 7,
			9, 8, 1,
		]);

		//mat4 projectionMatrix = projection(60f, 8f/6f, 0.1, 1000);
		float aspect = 8f/6f;
		mat4 projectionMatrix = orthographic(-1f, 1f, 1f, -1f, 0.1, 1000);
		shader.SetUniform("projectionMatrix", projectionMatrix);

		mat4 cameraMatrix = mat4.identity();
		shader.SetUniform("modelViewMatrix", cameraMatrix);

		double dt = 0f;

		double t = 0f;
		bool running = true;
		bool emit = false;

		enum framecap = 100;
		uint framecount = 0;
		double frameaccum = 0;
		vec3 prevm;
		bool doRotateCamera = false;

		auto camera = new Camera;

		while(running){
			SDL_Event e;
			while(SDL_PollEvent(&e)){
				switch(e.type){
					case SDL_KEYDOWN:
						if(e.key.keysym.sym == SDLK_ESCAPE){
							running = false;
						}else if(e.key.keysym.sym == SDLK_w){
							camera.Translate(vec3(0, 0, 5)*dt);
						}else if(e.key.keysym.sym == SDLK_s){
							camera.Translate(vec3(0, 0,-5)*dt);
						}
						break;

					case SDL_MOUSEBUTTONDOWN:
						doRotateCamera = true;
						break;
					case SDL_MOUSEBUTTONUP:
						doRotateCamera = false;
						break;

					case SDL_MOUSEMOTION:{
						auto m = vec3(e.motion.x, e.motion.y, 0f);
						m.x = (m.x / 800f) * 2f - 1f;
						m.y = (-m.y / 600f) * 2f + 1f;

						if(doRotateCamera){
							auto dlt = m - prevm;
							auto rot = vec3(dlt.y, -dlt.x, 0);
							camera.Rotate(rot);
						}

						prevm = m;

						break;
					}

					default:
						break;
				}
			}

			auto pt = SDL_GetTicks()/1000f;
			dt = pt - t;
			t = pt;

			frameaccum += dt;
			framecount++;
			if(framecount >= framecap){
				writeln("FPS: " ~ to!string(cast(double)framecount / frameaccum));
				stdout.flush();
				frameaccum = 0;
				framecount = 0;
			}

			shader.SetUniform("modelViewMatrix", camera.matrix);

			shader.Use();
			shader.SetUniform!float("time", t);

			glClearColor(0f, 0f, 0f, 1f);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

			posAttr.Enable();

			verts.Bind(posAttr);
			indices.Bind();

			glPatchParameteri(GL_PATCH_VERTICES, 3);
			glDrawElements(GL_PATCHES, indices.length, GL_UNSIGNED_INT, null);

			verts.Unbind();
			indices.Unbind();

			posAttr.Disable();

			Swap();

		}

	}catch(Exception e){
		writeln("Fuck: ", e.msg);
	}
}

mat4 projection(float fov, float a, float n, float f){
	float D2R = PI/180f;
	float ys = 1f / tan(D2R * fov / 2);
	float xs = ys / a;
	float fn = 1f/(n-f);

	return mat4(xs, 0, 0, 0,
				0, ys, 0, 0,
				0, 0, (f+n)*fn, 2*f*n*fn,
				0, 0, -1, 0);
}

mat4 orthographic(float l, float r, float t, float b, float n, float f){
	float rtl = r - t;
	float ttb = t - b;
	float ftn = f - n;

	return mat4(
		2/rtl, 0, 0, -(r+l)/rtl,
		0, 2/ttb, 0, -(t+b)/ttb,
		0, 0, -2/ftn, (f+n)/ftn,
		0, 0, 0, 1
		);
}


//auto verts = new VertexArray!vec3();
//verts.Load([
//	vec3(-1, -1, -1), // 0
//	vec3(-1,  1, -1),
//	vec3( 1,  1, -1),
//	vec3( 1, -1, -1),

//	vec3(-1, -1,  1), // 4
//	vec3( 1, -1,  1),
//	vec3( 1,  1,  1),
//	vec3(-1,  1,  1),

//	vec3(-1, -1, -1), // 8
//	vec3(-1, -1,  1),
//	vec3(-1,  1,  1),
//	vec3(-1,  1, -1),

//	vec3( 1, -1, -1), // 12
//	vec3( 1,  1, -1),
//	vec3( 1,  1,  1),
//	vec3( 1, -1,  1),

//	vec3(-1, -1, -1), // 16
//	vec3( 1, -1, -1),
//	vec3( 1, -1,  1),
//	vec3(-1, -1,  1),

//	vec3(-1,  1, -1), // 20
//	vec3(-1,  1,  1),
//	vec3( 1,  1,  1),
//	vec3( 1,  1, -1),
//]);

//auto indices = new VertexArray!uint(GL_ELEMENT_ARRAY_BUFFER);
//indices.Load([
//	0, 1, 2,
//	0, 2, 3,

//	4, 5, 6,
//	4, 6, 7,

//	8, 9, 10,
//	8, 10, 11,

//	12, 13, 14,
//	12, 14, 15,

//	16, 17, 18,
//	16, 18, 19,

//	20, 21, 22,
//	20, 22, 23
//]);