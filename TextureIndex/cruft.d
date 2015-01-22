module cruft;

import std.stdio;
import derelict.util.exception;
import gl;

private ShouldThrow handleDerelictsProblems(string symbolName) {
	writeln("Failed to load ", symbolName, ", ignoring this.");
	return ShouldThrow.No;
}

private SDL_Window* win = null;
private SDL_GLContext glctx = null;
private GLuint vao = 0;

private enum {
	Width = 800,
	Height = 600
}

void InitCruft(){
	DerelictSDL2.missingSymbolCallback = &handleDerelictsProblems;
	DerelictSDL2ttf.load();
	DerelictSDL2.load();
	DerelictGL3.load();

	scope(failure) SDL_Quit();
	if(SDL_Init(SDL_INIT_EVERYTHING) < 0){
		throw new Exception("SDL Init failed");
	}

	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 4);
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
	SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);

	win = SDL_CreateWindow("", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, Width, Height, 
		SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL);

	scope(failure) SDL_DestroyWindow(win); 
	if(!win){
		throw new Exception("Window create failed");
	}

	scope(failure) SDL_GL_DeleteContext(glctx);
	glctx = SDL_GL_CreateContext(win);

	if(!glctx) throw new Exception("GL context creation failed");

	DerelictGL3.reload();

	cgl!glGenVertexArrays(1, &vao);
	cgl!glBindVertexArray(vao);

	cgl!glEnable(GL_CULL_FACE);
	cgl!glEnable(GL_DEPTH_TEST);
	cgl!glEnable(GL_BLEND);
	cgl!glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	if(TTF_Init() < 0){
		throw new Exception("SDL_TTF init failed");
	}
}

void DeinitCruft(){
	glDeleteVertexArrays(1, &vao);

	SDL_GL_DeleteContext(glctx);
	SDL_DestroyWindow(win); 

	SDL_Quit(); 
}

void Swap(){
	SDL_GL_SwapWindow(win);
}

void WarpToCenter(){
	SDL_WarpMouseInWindow(win, Width/2, Height/2);
}