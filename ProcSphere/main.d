import std.stdio;
import std.conv;
import std.math;
import std.random;
import derelict.sdl2.sdl;

import cruft;
import shader;

import model;
import vertexarray;
import camera;
import gl;

void main(){
	try{
		InitCruft();
		scope(exit) DeinitCruft();

		auto shader = new Shader("shaders/vanilla.glsl", "draw");
		auto posAttr = shader.GetAttribute("position");

		auto camera = new Camera;
		camera.SetPosition(vec3(0, 0, -11));

		auto base = new Icosahedron(0, 1);
		auto shape = new Icosahedron(1, 2);
		auto shape2 = new Icosahedron(1, 3);

		float aspect = 8f/6f;
		mat4 projectionMatrix = projection(60f, aspect, 0.1, 1000);
		shader.SetUniform("projectionMatrix", projectionMatrix);

		double dt = 0f;

		double t = 0f;
		bool running = true;
		bool emit = false;

		enum framecap = 100;
		uint framecount = 0;
		double frameaccum = 0;
		vec3 prevm;
		bool doRotateCamera = false;

		glPointSize(3);

		int tessLevel = 1;
		shader.SetUniform("tessLevel", tessLevel);

		float speed = 1f;

		bool[int] keys;

		while(running){
			SDL_Event e;
			while(SDL_PollEvent(&e)){
				switch(e.type){
					case SDL_KEYDOWN:
						if(e.key.keysym.sym == SDLK_ESCAPE){
							running = false;
						}else if(e.key.keysym.sym == SDLK_r){
							tessLevel += 1;
							shader.SetUniform("tessLevel", tessLevel);
						}else if(e.key.keysym.sym == SDLK_f){
							tessLevel = max(1, tessLevel-1);
							shader.SetUniform("tessLevel", tessLevel);
						}
						keys[e.key.keysym.sym] = true;
						break;

					case SDL_KEYUP:
						keys[e.key.keysym.sym] = false;
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

				writeln(camera.eyepos);
			}

			float nspeed = keys.get(SDLK_LSHIFT, false)? speed*5f : speed;

			if(keys.get(SDLK_w, false)){
				camera.Translate(vec3(0, 0, nspeed)*dt);
			}else if(keys.get(SDLK_s, false)){
				camera.Translate(vec3(0, 0,-nspeed)*dt);
			}

			if(keys.get(SDLK_a, false)){
				camera.Translate(vec3(-nspeed, 0, 0)*dt);
			}else if(keys.get(SDLK_d, false)){
				camera.Translate(vec3(nspeed, 0, 0)*dt);
			}

			camera.Update();

			shader.Use();
			shader.SetUniform!float("time", t);

			glClearColor(0f, 0f, 0f, 1f);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

			posAttr.Enable();

			MatrixStack.Push();
				MatrixStack.top = MatrixStack.top *
					mat4.rotation(PI/2f, 0f, 0f, 1f) * 
					mat4.translation(10, 0, 0);

				shape2.Render(posAttr);
				shape.Render(posAttr);
				base.Render(posAttr);

			MatrixStack.Pop();

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
	float fn = 1f / (f-n);

	return mat4(-xs, 0, 0, 0,
				0,-ys, 0, 0,
				0, 0, -(f+n)*fn,-2*f*n*fn,
				0, 0, -1, 0);
/*
	return mat4(
		n, 0, 0, 0,
		0, n, 0, 0,
		0, 0, -(f+n)*fn, -2*f*n*fn,
		0, 0, -1, 0
		);*/
}

mat4 orthographic(float l, float r, float t, float b, float n, float f){
	float rtl = r - t;
	float ttb = t - b;
	float ftn = f - n;

	//return mat4(
	//	2f/rtl, 0, 0, -(r+l)/rtl,
	//	0, 2f/ttb, 0, -(t+b)/ttb,
	//	0, 0, -2f/ftn, (f+n)/ftn,
	//	0, 0, 0, 1
	//	);

	return mat4(
		-1/3f, 0, 0, 0,
		0, 1/3f, 0, 0,
		0, 0, 0, 0,
		0, 0, -1, 1
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