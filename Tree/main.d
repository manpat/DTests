import std.stdio;
import std.conv;
import std.math;
import derelict.sdl2.sdl;
import derelict.opengl3.gl3;

import cruft;
import shader;

import vertexarray;
import vector;

import tree;

void main(){
	try{
		InitCruft();
		scope(exit) DeinitCruft();

		auto shader = new Shader("shaders/tree.glsl");
		auto posAttr = shader.GetAttribute("position");
		auto colAttr = shader.GetAttribute("color");

		auto testTree = new Tree(10);
		testTree.Compile();

		float t = 0f;
		bool running = true;
		while(running){
			SDL_Event e;
			while(SDL_PollEvent(&e)){
				switch(e.type){
					case SDL_KEYDOWN:
						if(e.key.keysym.sym == SDLK_ESCAPE){
							running = false;
						}else if(e.key.keysym.sym == SDLK_SPACE){
							destroy(testTree);
							testTree = new Tree(9);
							testTree.Compile();
						}
						break;
					default:
						break;
				}
			}

			t = SDL_GetTicks()/1000f;
			shader.SetUniform("time", t);

			glClearColor(0.1f, 0.3f, 0.8f, 1f);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

			posAttr.Enable();
			colAttr.Enable();
			testTree.Draw();
			posAttr.Disable();
			colAttr.Disable();

			Swap();

		}

	}catch(Exception e){
		writeln("Fuck: ", e.msg);
	}
}