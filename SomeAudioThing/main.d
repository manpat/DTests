module main;

import std.conv, std.stdio, std.math, std.algorithm;
import eventsystem;
import generators;
import keyboard;
import cruft;
import gl;

struct Data {
	Voice[8] voices;
	uint i = 0;
	double t = 0.0;

	DelayBuffer delay;
}

struct DelayBuffer {
	float[] buffer;
	uint i = 0;

	void Push(float val){
		buffer[i] = val;
		i = (i+1)%buffer.length;
	}

	float Get(size_t delayAmt = size_t.max){
		delayAmt = min(delayAmt, buffer.length-1);
		size_t ii = i + buffer.length - delayAmt; 
		return buffer[ii % buffer.length];
	}
}

float lerp(float a, float b, float x){
	return a*x + b*(1f-x);
}

void audiocomposer(float* buffer, Data* data, size_t framesPerBuffer){
	foreach(i; 0 .. framesPerBuffer){
		float left = 0f;
		float right = 0f;
		enum delayratio = 0.5;
		enum delayamt = 15000;
		enum delayoff = 2000;

		foreach(voice; data.voices){
			left += voice.Generate(FRAMELENGTH);
		}

		right = lerp(data.delay.Get(delayamt), left, delayratio);
		left  = lerp(data.delay.Get(delayamt+delayoff), left, delayratio);

		data.delay.Push(left);

		auto numgens = 1f / cast(float) data.voices.length;
		left *= numgens;
		right *= numgens;

		*buffer++ = clamp(left, -1f, 1f);
		*buffer++ = clamp(right, -1f, 1f);

		data.t += FRAMELENGTH;
	}
}

void main(){
	InitCruft();
	scope(exit) DeinitCruft();
	bool isRunning = true;

	HookEventHandler((SDL_Event* e){
		if(e.type == SDL_QUIT 
			|| (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_ESCAPE)){
			isRunning = false;
		}
	});

	Data data;

	data.delay.buffer = new float[10240*4];
	data.delay.buffer[] = 0;

	foreach(i; 0..data.voices.length){
		data.voices[i] = new Voice(
			new SinGen(0), 
			new ADSREnv(0.1, 0.1, 0.7, 1));
	}

	InitPA!Data(&audiocomposer, &data);
	scope(exit) DeinitPA();

	auto keyb = new Keyboard(&data);

	while(isRunning){
		CheckEvents();
	}
}