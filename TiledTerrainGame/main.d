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
		auto postshader = new Shader("shaders/post.glsl", "post");

		auto posAttr = shader.GetAttribute("position");
		auto normAttr = shader.GetAttribute("normal");
		auto colAttr = shader.GetAttribute("color");
		auto offAttr = shader.GetAttribute("offset");
		auto flagsAttr = shader.GetAttribute("flags");
		shader.Use();

		auto camera = new Camera;
		camera.SetPosition(vec3(0,0,0));
		camera.Rotate(vec3(-PI/6f, 0, 0));
		camera.Translate(vec3(0,0,-300));

		enum aspect = cast(float) Width/cast(float) Height;
		enum scale = 30;
		mat4 projectionMatrix = orthographic(scale*aspect, scale, 1, 500);
		shader.SetUniform("projectionMatrix", projectionMatrix);

		double dt = 0f;

		double t = 0f;
		bool running = true;

		auto tm = new TileManager(scale+1, scale+1);

		auto center = vec2((tm.width-1)/2f, (tm.height-1)/2f);
		foreach(x; 0..tm.width)
			foreach(y; 0..tm.height){
				auto tile = tm.GetTile(x, y);
				auto p = vec2(x, y);
				auto diff = (center - p);
				auto dist = max(abs(diff.x), abs(diff.y));

				enum step = 0.5f;

				auto height = scale/6f - dist*0.4f + uniform(-0.1f, 0.1f)*0.5f;
				height = clamp(height, -1f, 10f);
				height = floor(height/step) *step;

				if(height < 0f) {
					tile.isWater = true;
				}else if(height < 1f){
					tile.position.y = height;
					tile.color = vec3(1f, 1f, 0.4f);

				}else{
					tile.position.y = height*1.5f;
					tile.color = vec3(0.2f, 0.7f, 0.3f) * (1.5f - clamp(height/5f, 0f, 1f));
				}
			}

		SetMouseClickDelegate((uint button, uint x, uint y){
			auto t = tm.PickTile(x, y);
			if(t && !t.isWater){
				t.toggleflag(button-1);
			}
		});

		uint framebuffer;
		uint fbColorBuffer;
		uint fbDepthBuffer;

		cgl!glGenFramebuffers(1, &framebuffer);
		scope(exit) cgl!glDeleteFramebuffers(1, &framebuffer);

		cgl!glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
			cgl!glGenTextures(1, &fbColorBuffer);
			cgl!glBindTexture(GL_TEXTURE_2D, fbColorBuffer);
			cgl!glTexStorage2D(GL_TEXTURE_2D, 1, GL_RGB8, Width, Height);
			cgl!glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			cgl!glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			cgl!glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
			cgl!glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

			cgl!glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, fbColorBuffer, 0);
			cgl!glBindTexture(GL_TEXTURE_2D, 0);

			cgl!glGenTextures(1, &fbDepthBuffer);
			cgl!glBindTexture(GL_TEXTURE_2D, fbDepthBuffer);
			cgl!glTexStorage2D(GL_TEXTURE_2D, 1, GL_DEPTH_COMPONENT24, Width, Height);
			cgl!glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			cgl!glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

			cgl!glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, fbDepthBuffer, 0);
			cgl!glBindTexture(GL_TEXTURE_2D, 0);
		cgl!glBindFramebuffer(GL_FRAMEBUFFER, 0);

		auto fsQuad = new VertexArray!vec2();
		fsQuad.Load([
			vec2(-1, -1),
			vec2( 1,  1),
			vec2(-1,  1),

			vec2(-1, -1),
			vec2( 1, -1),
			vec2( 1,  1),
		]);

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
			MatrixStack.top = mat4.rotation(-PI/4f, 0, 1, 0);

			// x-axis points bottom-right
			// z-axis points bottom-left

			shader.SetUniform!float("time", t);
			shader.SetUniform("isPicking", false);
			shader.SetUniform("projectionMatrix", projectionMatrix);

			posAttr.Enable();
			colAttr.Enable();
			offAttr.Enable();
			normAttr.Enable();
			flagsAttr.Enable();

			cgl!glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);

			//glClearColor(0.05f, 0.05f, 0.05f, 1f);
			glClearColor(0.3f, 0.7f, 1f, 1f);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			tm.Render();

			cgl!glBindFramebuffer(GL_FRAMEBUFFER, 0);

			posAttr.Disable();
			colAttr.Disable();
			offAttr.Disable();
			normAttr.Disable();
			flagsAttr.Disable();

			postshader.Use();

			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			posAttr.Enable(); // Hack, kind of. posAttr is assumed to be zero
			fsQuad.Bind(posAttr);
			cgl!glActiveTexture(GL_TEXTURE0);
			cgl!glBindTexture(GL_TEXTURE_2D, fbColorBuffer);

			cgl!glActiveTexture(GL_TEXTURE1);
			cgl!glBindTexture(GL_TEXTURE_2D, fbDepthBuffer);

			postshader.SetUniform("fbColor", 0);
			postshader.SetUniform("fbDepth", 1);
			postshader.SetUniform!float("time", t);

			cgl!glDrawArrays(GL_TRIANGLES, 0, 6);

			cgl!glBindTexture(GL_TEXTURE_2D, 0);
			fsQuad.Unbind();
			posAttr.Disable();
			glEnable(GL_DEPTH_TEST);

			shader.Use();

			Swap();
		}

	}catch(Exception e){
		writeln(e.file, ":", e.line, ": ", e.msg);
	}
}

mat4 orthographic(float width, float height, float n, float f){
	enum D2R = PI/180f;
	float xs = 1f/width;
	float ys = 1f/height;

	float fn = 2f / (f-n);
	float nonf = (f+n) / (n-f);

	return mat4(xs, 0, 0, 0,
				0, ys, 0, 0,
				0, 0, fn, nonf,
				0, 0, 0, 1);
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