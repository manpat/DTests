module main;

import std.conv, std.stdio, std.math, std.algorithm;
import derelict.sdl2.sdl;
import eventsystem;
import cruft;

import audio;

void audiocomposer(float* buffer, UGen* data, size_t framesPerBuffer){
	foreach(i; 0 .. framesPerBuffer){
		float left = 0f;
		float right = 0f;

		right = left = data.Generate(FRAMELENGTH);

		*buffer++ = clamp(left, -1f, 1f);
		*buffer++ = clamp(right, -1f, 1f);
	}
}

void main(){
	InitCruft();
	scope(exit) DeinitCruft();
	bool isRunning = true;

	auto env = new AREnv();
	env.attack = 0.5f;
	env.release = 1f;

	auto bend = new AREnv();
	bend.attack = 0.1f;
	bend.release = 0.25f;

	auto bend2 = new AREnv();
	bend2.attack = 0.1f;
	bend2.release = 0.75f;
	
	HookEventHandler((SDL_Event* e){
		if(e.type == SDL_QUIT 
			|| (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_ESCAPE)){
			isRunning = false;
		}else if(e.type == SDL_KEYDOWN){
			auto key = e.key.keysym.sym;

			if(key == SDLK_a) env.Trigger();
			if(key == SDLK_s) bend.Trigger();
			if(key == SDLK_d) bend2.Trigger();
		}
	});

	UGen synth1 = new SinOsc();
	UGen synth2 = new SquareOsc();
	UGen mod1 = new SinOsc();
	UGen mod2 = new SinOsc();

	mod1.frequency = 3.0;
	mod1.amplitude = 10.0;

	mod2.frequency = 0.5;
	mod2.amplitude = 1.0;

	synth1.frequency = mod1 + 440f + bend * 200f;
	synth1.amplitude = 1f;

	synth2.frequency = bend2 * 20f + 110f;
	synth2.amplitude = 0.2f;
	synth2.duty = mod2;

	auto comp = env * (synth1 + synth2) / 2f;

	//env.Trigger();

	InitPA!UGen(&audiocomposer, &comp);
	scope(exit) DeinitPA();

	while(isRunning){
		CheckEvents();
		SDL_Delay(10);
	}
}

T clamp(T)(T val, T _min, T _max){
	return min(max(val, _min), _max);
}