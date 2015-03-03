module audio.osc;

import std.math;
import audio.ugen;

enum defaultFreq = 220f;
enum defaultAmp = 0.7f;

class SinOsc : UGen {
	private {
		double phase = 0f;
	}

	override double Generate(double dt){
		auto freq = OptionalGenerate("frequency", dt, defaultFreq);
		auto amp = OptionalGenerate("amplitude", dt, defaultAmp);
		auto phaseoffset = OptionalGenerate("phase", dt, 0.0);

		phase += freq * 2.0 * PI * dt + phaseoffset;
		return sin(phase) * amp;
	}
}

class SquareOsc : UGen {
	private {
		double phase = 0f;
	}

	override double Generate(double dt){
		auto freq = OptionalGenerate("frequency", dt, defaultFreq);
		auto amp = OptionalGenerate("amplitude", dt, defaultAmp);
		auto duty = OptionalGenerate("duty", dt, 0.0);

		phase += freq * 2.0 * PI * dt;
		return sgn(sin(phase) + duty) * amp;
	}
}