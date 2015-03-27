module main;

import std.conv, std.stdio, std.math, std.algorithm;
import derelict.sdl2.sdl;
import eventsystem;
import cruft;

import audio;

enum NumVoices = 4;
struct AudioData {
	Instrument[NumVoices] instruments;
	double time = 0.0;
}

struct Instrument {
	Generator generator;

	LevelGen frequency;
	Envelope env;
}

void audiocomposer(float* buffer, AudioData* data, size_t framesPerBuffer){
	foreach(i; 0 .. framesPerBuffer){
		double left = 0f;
		double right = 0f;

		AudioManager.Prepare(FRAMELENGTH);

		double x = 0f;
		foreach(inst; data.instruments){
			x += AudioManager.GetValue(inst.generator.id);
		}

		x /= cast(double) (NumVoices+1f);

		left = right = x;

		*buffer++ = clamp(left, -1f, 1f);
		*buffer++ = clamp(right, -1f, 1f);
		data.time += FRAMELENGTH;
	}
}

void Go(){
	InitCruft();
	scope(exit) DeinitCruft();
	bool isRunning = true;

	auto audioManager = new AudioManager();

	Instrument GenerateInstrument(){
		Generator synth = new SquareOsc();
		Generator synth2 = new SinOsc();

		auto frequency = new LevelGen(110f);
		auto env = new AREnv();

		env.attack = 0.03f;
		env.release = 2f;

		synth.frequency = frequency;
		synth.amplitude = 0.4f;
		synth.duty = 0.2f;

		synth2.frequency = frequency*2f;
		synth2.amplitude = 0.4f;

		synth = (synth + synth2) * 0.6;

		return Instrument(env * synth, frequency, env);
	}

	AudioData audioData;

	{ // Bass
		auto e = new AREnv();
		auto f = new LevelGen(110f);
		auto s1 = new SquareOsc();
		auto s2 = new SquareOsc();
		auto s3 = new SinOsc();
		s1.frequency = f;
		s2.frequency = f/2f;
		s3.frequency = f/3f;

		s1.duty = 0.0f;
		s2.duty = 0.3f;

		auto s = (s1 + s2 + s3) * 0.4f;
		audioData.instruments[0] = Instrument(s * e, f, e);
	}

	{ // Kick
		auto e = new AREnv();
		auto f = new LevelGen(50f);
		auto s = new SinOsc();
		s.frequency = f;
		s.amplitude = 2f;
		e.attack = 0.01f;
		e.sustain = 0.0f;
		e.release = 0.3f;

		audioData.instruments[1] = Instrument(s * e, f, e);
	}

	foreach(i; 2..NumVoices){
		audioData.instruments[i] = GenerateInstrument();
	}

	InitPA!AudioData(&audiocomposer, &audioData);
	scope(exit) DeinitPA();

	void Play(double freq, uint idx = 0){
		//static uint idx = 0;
		auto ins = &audioData.instruments[idx];

		ins.env.Trigger();
		ins.frequency.level = freq;

		//idx = (idx+1u) % audioData.instruments.length;
	}

	enum C = 40;
	static double note(double n){
		return 2f.pow((n-49f)/12f) * 440f;
	}
	
	HookEventHandler((SDL_Event* e){
		if(e.type == SDL_QUIT 
			|| (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_ESCAPE)){
			isRunning = false;
		}else if(e.type == SDL_KEYDOWN){
			auto key = e.key.keysym.sym;

			if(key == SDLK_a) Play(note(C + 0), 2);
			if(key == SDLK_s) Play(note(C + 2), 2);
			if(key == SDLK_d) Play(note(C + 4), 2);
			if(key == SDLK_f) Play(note(C + 5), 2);
			if(key == SDLK_g) Play(note(C + 7), 2);
			if(key == SDLK_h) Play(note(C + 9), 2);
			if(key == SDLK_j) Play(note(C + 11), 2);
			if(key == SDLK_k) Play(note(C + 12), 2);
			if(key == SDLK_l) Play(note(C + 14), 2);

			if(key == SDLK_w) Play(note(C + 1), 2);
			if(key == SDLK_e) Play(note(C + 3), 2);

			if(key == SDLK_t) Play(note(C + 6), 2);
			if(key == SDLK_y) Play(note(C + 8), 2);
			if(key == SDLK_u) Play(note(C + 10), 2);
			if(key == SDLK_o) Play(note(C + 13), 2);
		}
	});

	auto chord(int degree){
		auto degreeToOffset = [
			0, 2, 4, 5, 7, 9, 11, 
			12, 14, 16, 17, 19, 21, 23, 24
		];
		auto len = degreeToOffset.length;

		auto notes = [
			C + degreeToOffset[(degree + 0)%len],
			C + degreeToOffset[(degree + 2)%len],
			C + degreeToOffset[(degree + 4)%len],
			//C + degreeToOffset[(degree + 5)%len],
		];

		return notes;
	}

	auto arpnotes = [
		C - 12 + 0,
		C - 12 + 7,
		C - 12 + 11,
		C - 12 + 12,
		C - 12 + 16,
		C - 12 + 12,
		C - 12 + 11,
		C - 12 + 7,

		C - 12 + 5 + 0,
		C - 12 + 5 + 7,
		C - 12 + 5 + 11,
		C - 12 + 5 + 12,
		C - 12 + 5 + 16,
		C - 12 + 5 + 12,
		C - 12 + 5 + 11,
		C - 12 + 5 + 7,

		C - 12 - 1 + 0,
		C - 12 - 1 + 7,
		C - 12 - 1 + 11,
		C - 12 - 1 + 12,
		C - 12 - 1 + 16,
		C - 12 - 1 + 12,
		C - 12 - 1 + 11,
		C - 12 - 1 + 7,

		C - 12 + 2 + 0,
		C - 12 + 2 + 7,
		C - 12 + 2 + 11,
		C - 12 + 2 + 12,
		C - 12 + 2 + 16,
		C - 12 + 2 + 12,
		C - 12 + 2 + 11,
		C - 12 + 2 + 7,
	];

	double lastBeat = -1f;
	ulong beat = 0;
	enum noteLength = 0.15;

	while(isRunning){
		CheckEvents();

		auto t = audioData.time;
		if((t - lastBeat) >= noteLength){
			auto len = arpnotes.length;
			Play(note(arpnotes[beat % len]));

			if(beat % 8 == 0)
				Play(note(arpnotes[beat % len] + 12), 2);

			if(beat % 4 == 0) Play(60f, 1);

			beat++;
			lastBeat = t;
		}

		//SDL_Delay(5);
	}
}

void main(){
	try {
		Go();

	} catch(Exception e){
		Log(e.msg);
	}
}

T clamp(T)(T val, T _min, T _max){
	return min(max(val, _min), _max);
}