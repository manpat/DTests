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

void main(){
	try{
		InitCruft();
		scope(exit) DeinitCruft();

		auto shader = new Shader("shaders/vanilla.glsl", "draw");
		auto posAttr = shader.GetAttribute("position");

		double dt = 0f;
		double t = 0f;
		bool running = true;

		enum framecap = 100;
		uint framecount = 0;
		double frameaccum = 0;

		auto quad = new VertexArray!vec2();
		quad.Load([
			vec2(-1, -1),
			vec2(-1,  1),
			vec2( 1,  1),
			vec2( 1, -1),
		]);

		while(running){
			SDL_Event e;
			while(SDL_PollEvent(&e)){
				switch(e.type){
					case SDL_KEYDOWN:
						if(e.key.keysym.sym == SDLK_ESCAPE){
							running = false;
						}else if(e.key.keysym.sym == SDLK_F5){
							shader.Reload();

							SDL_Delay(250);
						}
						break;

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

			shader.Use();
			shader.SetUniform!float("time", t);

			glClearColor(0f, 0f, 0f, 1f);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

			posAttr.Enable();
			quad.Bind(posAttr);
			glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
			quad.Unbind();
			posAttr.Disable();

			Swap();
		}

	}catch(Exception e){
		writeln("Fuck: ", e.msg);
	}
}