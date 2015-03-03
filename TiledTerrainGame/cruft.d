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

enum {
	Width = 800,
	Height = 600
}

void InitCruft(){
	DerelictSDL2.missingSymbolCallback = &handleDerelictsProblems;
	DerelictSDL2ttf.load();
	DerelictSDL2Image.load();
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

	cgl!glEnable(GL_DEBUG_OUTPUT);
	cgl!glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);

	cgl!glDebugMessageCallback(&DebugFunc, cast(const(void)*) null);

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

extern(C)
void DebugFunc(GLenum source, GLenum type, GLuint id,
	GLenum severity, GLsizei length, const (GLchar)* message,
	GLvoid* userParam) nothrow{

	import std.string;

	try {
		writeln(GLDebugEnumsToString(source, type, severity), "\t\tid: ", id, "\n\t", message.fromStringz);
	}catch(Exception e){

	}
}

private string GLDebugEnumsToString(GLenum source, GLenum type, GLenum severity){
	string ret = "";

	switch(severity){
		case GL_DEBUG_SEVERITY_HIGH: ret ~= "[high]"; break;
		case GL_DEBUG_SEVERITY_MEDIUM: ret ~= "[medium]"; break;
		case GL_DEBUG_SEVERITY_LOW: ret ~= "[low]"; break;
		case GL_DEBUG_SEVERITY_NOTIFICATION: ret ~= "[notification]"; break;
		default: ret ~= "[unknown]";
	}

	ret ~= "\tsrc:";

	switch(source){
		case GL_DEBUG_SOURCE_API: ret ~= " API"; break;
		case GL_DEBUG_SOURCE_WINDOW_SYSTEM: ret ~= " WINDOW_SYSTEM"; break;
		case GL_DEBUG_SOURCE_SHADER_COMPILER: ret ~= " SHADER_COMPILER"; break;
		case GL_DEBUG_SOURCE_THIRD_PARTY: ret ~= " THIRD_PARTY"; break;
		case GL_DEBUG_SOURCE_APPLICATION: ret ~= " APPLICATION"; break;
		case GL_DEBUG_SOURCE_OTHER: ret ~= " OTHER"; break;
		default: ret ~= " unknown";
	}

	ret ~= "\ttype:";

	switch(type){
		case GL_DEBUG_TYPE_ERROR: ret ~= " error"; break;
		case GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR: ret ~= " deprecated behaviour"; break;
		case GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR: ret ~= " undefined behaviour"; break;
		case GL_DEBUG_TYPE_PORTABILITY: ret ~= " portability issue"; break;
		case GL_DEBUG_TYPE_PERFORMANCE: ret ~= " performance issue"; break;
		case GL_DEBUG_TYPE_MARKER: ret ~= " marker"; break;
		case GL_DEBUG_TYPE_PUSH_GROUP: ret ~= " push group"; break;
		case GL_DEBUG_TYPE_POP_GROUP: ret ~= " pop group"; break;
		case GL_DEBUG_TYPE_OTHER: ret ~= " other"; break;
		default: ret ~= " unknown";
	}

	return ret;
}