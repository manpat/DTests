import std.stdio;
import std.conv;
import std.math;
import std.random;

import cruft;
import shader;

import vertexarray;
import hud;
import gl;

private bool[int] keys;
private auto dlt = vec2(0,0);

bool GetKey(int k){
	return keys.get(k, false);
}

vec2 GetMouseDelta(){
	return dlt;
}

void main(){
	try{
		InitCruft();
		scope(exit) DeinitCruft();

		InitHUD();

		auto bar1 = new HUDBar!(GUIAnchor.Center)(2f, 50);
		bar1.pos = vec2(0, 0.97);
		bar1.col = vec4(1, 0, 0, 1);

		auto bar2 = new HUDBar!(GUIAnchor.Center)(2f, 50);
		bar2.pos = vec2(0, 0.91);
		bar2.col = vec4(0, 1, 0, 0.3);
		bar2.value = 1;

		auto bar3 = new HUDBar!(GUIAnchor.Center)(2f, 50);
		bar3.pos = vec2(0, 0.91 - 0.06);
		bar3.value = 0.1;

		auto radial1 = new HUDRadial!(GUIAnchor.Center)(0.5f, 0.05f, 3*PI/2, 21);
		radial1.pos = vec2(0, 0);
		radial1.col = vec4(1, 1, 0, 0.9);

		auto radial2 = new HUDRadial!(GUIAnchor.Center)(0.45f, 0.04f, 3*PI/2, 40);
		radial2.pos = vec2(0, 0);
		radial2.col = vec4(1, 0, 0, 0.8);

		auto radial3 = new HUDRadial!(GUIAnchor.Center)(0.41f, 0.03f, 3*PI/2, 50);
		radial3.pos = vec2(0, 0);
		radial3.col = vec4(1, 1, 1, 0.7);

		auto radial4 = new HUDRadial!(GUIAnchor.Center)(0.38f, 0.03f, 2*PI, 100);
		radial4.pos = vec2(0, 0);
		radial4.col = vec4(0, 0, 1, 0.9);

		double dt = 0f;
		double t = 0f;
		bool running = true;

		enum framecap = 100;
		uint framecount = 0;
		double frameaccum = 0;

		glPointSize(3);
		//glLineWidth(3);

		bool doCheckMouseMove = true;

		while(running){
			auto m = vec2(0,0);

			SDL_Event e;
			while(SDL_PollEvent(&e)){
				switch(e.type){
					case SDL_KEYDOWN:
						switch(e.key.keysym.sym){
							case SDLK_ESCAPE:
								running = false;
								break;

							case SDLK_RIGHTBRACKET:
								bar1.value = bar1.value + 0.1f;
								break;

							case SDLK_LEFTBRACKET:
								bar1.value = bar1.value - 0.1f;
								break;

							default:
								break;
						}

						keys[e.key.keysym.sym] = true;
						break;

					case SDL_KEYUP:
						keys[e.key.keysym.sym] = false;
						break;

					case SDL_MOUSEMOTION:{
						if(doCheckMouseMove){
							m = vec2(e.motion.x, e.motion.y);
							m.x = (m.x / 800f) * 2f - 1f;
							m.y = (-m.y / 600f) * 2f + 1f;
							//WarpToCenter();
						}
						
						doCheckMouseMove = !doCheckMouseMove;
						break;
					}

					default:
						break;
				}
			}

			if(doCheckMouseMove){
				dlt = m;
			}

			auto pt = SDL_GetTicks()/1000f;
			dt = pt - t;
			t = pt;

			frameaccum += dt;
			framecount++;
			if(framecount >= framecap){
				double fps = cast(double)framecount / frameaccum;
				writeln("FPS: " ~ to!string(fps));
				stdout.flush();
				frameaccum = 0;
				framecount = 0;
			}

			glClearColor(0f, 0f, 0f, 1f);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

			PrintHUD!(GUIAnchor.Center)("Things", vec2(0, 0));

			EnableHUDAttributes();

			bar1.value = sin(t)/2f + 0.5f;
			bar1.Render();
			bar2.col.a = sin(t*100f)*0.1f + 0.6f;
			bar2.Render();
			bar3.Render();

			radial1.value = sin(t)/2f + 0.5f;
			radial1.Render();

			radial2.value = sin(t)/2f + 0.5f;
			radial2.Render();

			radial3.value = sin(t)/2f + 0.5f;
			radial3.Render();

			radial4.value = sin(t)/2f + 0.5f;
			radial4.Render();

			DisableHUDAttributes();

			Swap();

		}

	}catch(Exception e){
		writeln("Fuck: ", e.msg);
	}
}