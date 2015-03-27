module audio.envelope;

import audio.common;
import main : clamp;
import std.algorithm : max;

class Envelope : Generator, Triggerable {
	abstract void Trigger();
	// Generate overridden in base classes
}

class LinearEnv : Envelope {
	private {
		double phase = 0.0f;
	}

	override void Trigger(){
		phase = 1.0f;
	}

	override double Generate(double dt){
		auto rate = OptionalGenerate("decayRate", 1.0);

		phase -= dt * rate;
		return clamp(phase, 0.0, 1.0);
	}
}

class AREnv : Envelope {
	private {
		double phase = double.infinity;
		double value = 0f;
	}

	override void Trigger(){
		phase = 0f;
	}

	override double Generate(double dt){
		auto attack = OptionalGenerate("attack", 0.1);
		auto release = OptionalGenerate("release", 0.6);
		auto totalTime = attack + release;

		if(phase > totalTime) {
			value = 0.0;
			return 0.0;
		}

		if(phase < attack){
			value = max(phase/attack, value);
		}else if(phase-attack < release){
			auto rstart = phase-attack;
			value = 1.0 - rstart/release;
		}

		phase += dt;
		return clamp(value, 0.0, 1.0);
	}
}