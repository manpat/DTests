module cruft;

import derelict.util.exception;
import deimos.portaudio;
import derelict.sdl2.sdl;
import std.stdio;
import std.conv : to;

private ShouldThrow handleDerelictsProblems(string symbolName) {
	writeln("Failed to load ", symbolName, ", ignoring this.");
	return ShouldThrow.No;
}

private {
	SDL_Window* win = null;
}

private enum {
	Width = 100,
	Height = 100,
}

void InitCruft(){
	DerelictSDL2.missingSymbolCallback = &handleDerelictsProblems;
	DerelictSDL2.load();

	scope(failure) SDL_Quit();
	if(SDL_Init(SDL_INIT_EVERYTHING) < 0){
		throw new Exception("SDL Init failed");
	}

	win = SDL_CreateWindow("", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, Width, Height, 
		SDL_WINDOW_SHOWN);

	scope(failure) SDL_DestroyWindow(win); 
	if(!win){
		throw new Exception("Window create failed");
	}
}

void DeinitCruft(){
	SDL_DestroyWindow(win); 

	SDL_Quit(); 
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

enum SAMPLERATE = 22050;
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