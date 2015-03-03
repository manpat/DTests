import std.random;
import std.stdio;
import std.conv;
import std.math;

import shader;
import cruft;

import vertexarray;
import camera;
import input;
import gl;

import game.tilemanager;

void main(){
	try{
		InitCruft();
		scope(exit) DeinitCruft();

		auto shader = new Shader("shaders/tilerender.glsl", "draw");
		auto posAttr = shader.GetAttribute("position");
		auto colAttr = shader.GetAttribute("color");
		auto offAttr = shader.GetAttribute("offset");
		auto flagsAttr = shader.GetAttribute("flags");

		auto camera = new Camera;
		camera.SetPosition(vec3(0,0,0));
		camera.Rotate(vec3(-PI/6f, 0, 0));
		camera.Translate(vec3(0,0,-4));

		float scale = 0.03f;
		mat4 projectionMatrix = orthographic(Width*scale, Height*scale, 0.1, 500);
		shader.SetUniform("projectionMatrix", projectionMatrix);

		double dt = 0f;

		double t = 0f;
		bool running = true;

		auto tm = new TileManager(17, 17);
		auto tile = tm.GetTile(8, 8);
		tile.flags |= 1;

		SetMouseClickDelegate((uint button, uint x, uint y){
			auto t = tm.PickTile(x, y);
			if(t){
				t.flags ^= 1<<(button-1);
			}
		});

		while(running){
			SDL_Event e;
			CheckInputEvents(&e);

			if(GetKey(SDLK_ESCAPE)){
				running = false;
			}

			auto pt = SDL_GetTicks()/1000f;
			dt = pt - t;
			t = pt;

			VisitFPS(dt);

			shader.Use();

			auto cammove = vec3(0,0,0);
			enum cammovespeed = 10f;
			if(GetKey(SDLK_d)){
				cammove.x += 1f;
			}
			if(GetKey(SDLK_a)){
				cammove.x -= 1f;
			}
			if(GetKey(SDLK_w)){
				cammove.z += 1f;
			}
			if(GetKey(SDLK_s)){
				cammove.z -= 1f;
			}

			camera.TranslateGlobal(cammove.normalized * cammovespeed * dt);

			camera.Update();
			MatrixStack.top = mat4.rotation(PI/4f, 0, 1, 0);

			shader.SetUniform!float("time", t);
			shader.SetUniform("isPicking", false);
			shader.SetUniform("projectionMatrix", projectionMatrix);

			glClearColor(0.05f, 0.05f, 0.05f, 1f);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

			posAttr.Enable();
			colAttr.Enable();
			offAttr.Enable();
			flagsAttr.Enable();

			tm.Render();

			posAttr.Disable();
			colAttr.Disable();
			offAttr.Disable();
			flagsAttr.Disable();

			Swap();
		}

	}catch(Exception e){
		writeln(e.file, ":", e.line, ": ", e.msg);
	}
}

mat4 orthographic(float width, float height, float n, float f){
	enum D2R = PI/180f;
	float xs = 2f/width;
	float ys = 2f/height;

	float fn = 1f / (f-n);
	float nonf = n / (n-f);

	return mat4(xs, 0, 0, 0,
				0, ys, 0, 0,
				0, 0, fn, 0,
				0, 0, nonf, 1);
}

void VisitFPS(double dt){
	enum framecap = 100;
	static uint framecount = 0;
	static double frameaccum = 0;
	static double fps = 0;

	frameaccum += dt;
	framecount++;
	if(frameaccum >= 1f){
		fps = cast(double)framecount / frameaccum;
		frameaccum = 0;
		framecount = 0;
		writeln("FPS: " ~ to!string(fps));
		stdout.flush();
	}
}