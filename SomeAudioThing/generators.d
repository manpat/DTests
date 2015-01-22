module generators;

import std.math;

enum π2 = 2.0*PI;

interface SignalGenerator {
	float Generate(double inc);
	void SetFrequency(double ƒ);
}

class SinGen : SignalGenerator {
	private {
		double ƒ = 220.0;
		double φ = 0.0;
	}

	this(double _ƒ = 220.0){
		ƒ = _ƒ;
	}

	float Generate(double inc){
		φ += inc * ƒ * π2;
		return sin(φ);
	}

	void SetFrequency(double _ƒ){
		ƒ = _ƒ;
	}
}

interface Envelope {
	float Generate(double inc, bool held = false);
	void Trigger();
}

class ADSREnv : Envelope {
	private {
		double a;
		double d;
		double s;
		double r;

		double φ = double.max;
	}

	this(double _a, double _d, double _s, double _r){
		a = _a;
		d = _d;
		s = _s;
		r = _r;
	}

	float Generate(double inc, bool held){
		float x = φ;
		float y = φ;
		φ += inc;

		if(x < a) return x/a;

		x -= a;
		if(x < d) return (1f-s)*(d-x)/d + s;

		x -= d;
		if(held) {
			φ = y;
			return s;
		}

		if(x < r) return s*(r-x)/r;

		return 0;
	}

	void Trigger(){
		φ = 0.0;
	}
}

class Voice {
	SignalGenerator generator;
	Envelope envelope;

	private bool playing = false; 

	this(SignalGenerator _gen, Envelope _env){
		generator = _gen;
		envelope = _env;
	}

	float Generate(double inc){
		return generator.Generate(inc) * envelope.Generate(inc, playing);
	}

	void Play(double ƒ){
		generator.SetFrequency(ƒ);
		envelope.Trigger();
		playing = true;
	}

	void Stop(){
		playing = false;
	}

	bool IsPlaying(){
		return playing;
	}
}