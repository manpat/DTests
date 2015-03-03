module audio.envelope;

import audio.ugen;
import main : clamp;

class Envelope : UGen {
	abstract void Trigger();
}

class LinearEnv : Envelope {
	private {
		double phase = 0.0f;
	}

	override void Trigger(){
		phase = 1.0f;
	}

	override double Generate(double dt){
		auto rate = OptionalGenerate("decayRate", dt, 1.0);

		phase -= dt * rate;
		return clamp(phase, 0.0, 1.0);
	}
}

class AREnv : Envelope {
	private {
		double phase = float.infinity;
	}

	override void Trigger(){
		phase = 0f;
	}

	override double Generate(double dt){
		auto attack = OptionalGenerate("attack", dt, 0.1);
		auto release = OptionalGenerate("release", dt, 0.6);
		auto totalTime = attack + release;
		auto val = 0.0;

		if(phase > totalTime) return val;

		if(phase < attack){
			val = phase/attack;
		}else if(phase-attack < release){
			auto rstart = phase-attack;
			val = 1.0 - rstart/release;
		}

		phase += dt;
		return clamp(val, 0.0, 1.0);
	}
}