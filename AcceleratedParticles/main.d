import std.stdio;
import std.conv;
import std.math;
import std.random;
import derelict.sdl2.sdl;
import derelict.opengl3.gl3;

import cruft;
import shader;

import vertexarray;
import vector;

import particle;

void main(){
	try{
		InitCruft();
		scope(exit) DeinitCruft();

		auto shader = new Shader("shaders/vanilla.glsl", "draw");
		auto posAttr = shader.GetAttribute("position");
		auto colAttr = shader.GetAttribute("color");

		auto psys = new ParticleSystem(1_000_000);
		auto str = 1f;
		psys.AddAttractor(vec3(0, 0, 0), str);

		vec3 prevm;

		glPointSize(2);

		double dt = 0f;

		double t = 0f;
		bool running = true;
		bool emit = false;
		float attractorPlaceTimer = 0f;

		enum framecap = 100;
		uint framecount = 0;
		double frameaccum = 0;

		while(running){
			SDL_Event e;
			while(SDL_PollEvent(&e)){
				switch(e.type){
					case SDL_KEYDOWN:
						if(e.key.keysym.sym == SDLK_ESCAPE){
							running = false;
						}else if(e.key.keysym.sym == SDLK_SPACE){
							psys.ClearAttractors();
							//psys.AddAttractor(vec3(0, 0, 0), str);
						}else if(e.key.keysym.sym == SDLK_c){
							psys.ClearParticles();
						}
						break;

					case SDL_MOUSEBUTTONDOWN:
						if(e.button.button == SDL_BUTTON_RIGHT && attractorPlaceTimer <= 0f){
							psys.AddAttractor(prevm, str);
							attractorPlaceTimer = 0.5f;
						}else{
							emit = true;
						}
						break;
					case SDL_MOUSEBUTTONUP:
						emit = false;
						break;

					case SDL_MOUSEMOTION:{
						auto m = vec3(e.motion.x, e.motion.y, 0f);
						m.x = (m.x / 800f) * 2f - 1f;
						m.y = (-m.y / 600f) * 2f + 1f;
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
			attractorPlaceTimer -= dt;

			frameaccum += dt;
			framecount++;
			if(framecount >= framecap){
				writeln("FPS: " ~ to!string(cast(double)framecount / frameaccum));
				stdout.flush();
				frameaccum = 0;
				framecount = 0;
			}

			if(emit) foreach(i; 0..200){ psys.Emit(prevm, vec3(0, 1, 0) * uniform(5.0, 20.0) * 0.04);}
			psys.Update(1.0/120.0);

			shader.Use();
			shader.SetUniform("time", t);

			glClearColor(0f, 0f, 0f, 1f);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

			posAttr.Enable();
			colAttr.Enable();
			psys.Draw();
			colAttr.Disable();
			posAttr.Disable();

			Swap();

		}

	}catch(Exception e){
		writeln("Fuck: ", e.msg);
	}
}