module audio.osc;

import std.math;
import audio.common;

enum defaultFreq = 220f;
enum defaultAmp = 0.7f;

class SinOsc : Generator {
	private {
		double phase = 0f;
	}

	override double Generate(double dt){
		auto freq = OptionalGenerate("frequency", defaultFreq);
		auto amp = OptionalGenerate("amplitude", defaultAmp);
		auto phaseoffset = OptionalGenerate("phase", 0.0);

		phase += freq * 2.0 * PI * dt + phaseoffset;
		return sin(phase) * amp;
	}
}

class SquareOsc : Generator {
	private {
		double phase = 0f;
	}

	override double Generate(double dt){
		auto freq = OptionalGenerate("frequency", defaultFreq);
		auto amp = OptionalGenerate("amplitude", defaultAmp);
		auto duty = OptionalGenerate("duty", 0.0);

		phase += freq * 2.0 * PI * dt;
		return sgn(sin(phase) + duty) * amp;
	}
}