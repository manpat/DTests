module cruft;

import derelict.util.exception;
import deimos.portaudio;
import std.stdio;
import gl;

private ShouldThrow handleDerelictsProblems(string symbolName) {
	writeln("Failed to load ", symbolName, ", ignoring this.");
	return ShouldThrow.No;
}

private {
	SDL_Window* win = null;
	SDL_GLContext glctx = null;
	GLuint vao = 0;
}

private enum {
	Width = 800,
	Height = 600,
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
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
	SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);

	win = SDL_CreateWindow("", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, Width, Height, 
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

	glEnable(GL_CULL_FACE);
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	assert(CheckGLError());

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

void WarpToCenter(){
	SDL_WarpMouseInWindow(win, Width/2, Height/2);
}

///////////////////////////////////////////////////////////////////

private {
	PaStream* stream = null;

	struct UserData(T){
		alias Callback = void function(float*, T*, size_t);

		T* ud;
		Callback callback;

		void Call(float* fd, size_t s){
			callback(fd, ud, s);
		}
	}
}

enum SAMPLERATE = 44100;
enum FRAMELENGTH = 1.0/SAMPLERATE;

private extern(C) int audioGen(D)(const(void)*, void* outputBuffer,
	size_t framesPerBuffer, const(PaStreamCallbackTimeInfo)*,
	PaStreamCallbackFlags, void *userData){

	auto dat = cast(UserData!D*) userData;
	auto dataout = cast(float*) outputBuffer;

	dat.Call(dataout, framesPerBuffer);

	return 0;
}

void InitPA(T)(UserData!T.Callback composerFunc, T* data){
	paCheck!Pa_Initialize();

	paCheck!Pa_OpenDefaultStream(&stream,
		0, 2, // IO
		paFloat32,
		SAMPLERATE,
		paFramesPerBufferUnspecified,
		&audioGen!T, 
		new UserData!T(data, composerFunc));

	paCheck!Pa_StartStream(stream);
}

void DeinitPA(){
	paCheck!Pa_StopStream(stream);
	paCheck!Pa_CloseStream(stream);
	paCheck!Pa_Terminate();
}

void paCheck(alias func, T...)(T t){
	PaError err = func(t);
	if (err != paNoError){
		stderr.writefln("error %s", to!string(Pa_GetErrorText(err)));
		throw new Exception("PaError");
	}
}