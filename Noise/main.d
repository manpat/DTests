import std.stdio;
import std.conv;
import std.math;
import std.random;

import cruft;
import shader;

import vertexarray;
import hud;
import gl;

void main(){
	try{
		InitCruft();
		scope(exit) DeinitCruft();

		InitHUD();

		auto shader = new Shader("shaders/passthrough.glsl");

		double dt = 0f;
		double t = 0f;
		bool running = true;

		enum framecap = 100;
		uint framecount = 0;
		double frameaccum = 0;

		glPointSize(3);
		//glLineWidth(3);

		auto as = 6f/8f;
		auto quad = new VertexArray!vec2();
		quad.Load([
			vec2(-as, -1),
			vec2( as,  1),
			vec2(-as,  1),
			
			vec2(-as, -1),
			vec2( as, -1),
			vec2( as,  1),
		]);

		auto quaduv = new VertexArray!vec2();
		quaduv.Load([
			vec2( 0,  1),
			vec2( 1,  0),
			vec2( 0,  0),
			
			vec2( 0,  1),
			vec2( 1,  1),
			vec2( 1,  0),
		]);
		auto posAttr = shader.GetAttribute("pos");
		auto uvAttr = shader.GetAttribute("uv");

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

							default:
								break;
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
				double fps = cast(double)framecount / frameaccum;
				writeln("FPS: " ~ to!string(fps));
				stdout.flush();
				frameaccum = 0;
				framecount = 0;
			}

			glClearColor(0f, 0f, 0f, 1f);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			//PrintHUD!(GUIAnchor.Center)("Things", vec2(0, 0));

			shader.Use();

			posAttr.Enable();
			uvAttr.Enable();

			quad.Bind(posAttr);
			quaduv.Bind(uvAttr);

			glDrawArrays(GL_TRIANGLES, 0, quad.length);

			quad.Unbind();
			quaduv.Unbind();

			uvAttr.Disable();
			posAttr.Disable();

			Swap();

		}

	}catch(Exception e){
		writeln("Fuck: ", e.msg);
	}
}