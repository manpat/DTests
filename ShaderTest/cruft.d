module cruft;

import std.stdio;
import derelict.util.exception;
import derelict.sdl2.sdl;
import derelict.opengl3.gl3;

private ShouldThrow handleDerelictsProblems(string symbolName) {
	writeln("Failed to load ", symbolName, ", ignoring this.");
	return ShouldThrow.No;
}

private SDL_Window* win = null;
private SDL_GLContext glctx = null;
private GLuint vao = 0;

void InitCruft(){
	DerelictSDL2.missingSymbolCallback = &handleDerelictsProblems;
	DerelictSDL2.load();
	DerelictGL3.load();

	scope(failure) SDL_Quit();
	if(SDL_Init(SDL_INIT_EVERYTHING) < 0){
		throw new Exception("SDL Init failed");
	}

	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
	SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);

	win = SDL_CreateWindow("Particles", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 800, 600, 
		SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL | SDL_WINDOW_BORDERLESS*0);

	scope(failure) SDL_DestroyWindow(win); 
	if(!win){
		throw new Exception("Window create failed");
	}

	scope(failure) SDL_GL_DeleteContext(glctx);
	glctx = SDL_GL_CreateContext(win);

	if(!glctx) throw new Exception("GL context creation failed");

	DerelictGL3.reload();

	glGenVertexArrays(1, &vao);
	glBindVertexArray(vao);
	assert(CheckGLError());
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

bool CheckGLError(){
	GLuint error = glGetError();
	switch(error){
		case GL_INVALID_ENUM:
			writeln("InvalidEnum");
			break;

		case GL_INVALID_VALUE:
			writeln("InvalidValue");
			break;

		case GL_INVALID_OPERATION:
			writeln("InvalidOperation");
			break;

		case GL_INVALID_FRAMEBUFFER_OPERATION:
			writeln("InvalidFramebufferOperation");
			break;

		case GL_OUT_OF_MEMORY:
			writeln("OutOfMemory");
			break;

		case GL_NO_ERROR:
		default:
			return true;
	}

	stdout.flush();
	return false;
}