module audio.ugen;

import std.math;
import audio.operator;

class UGen {
	protected {
		UGen[string] inputs;
	}

	void SetParameter(string p, UGen u){
		inputs[p] = u;
	}

	void SetParameter(string p, float c){
		inputs[p] = new LevelGen(c);
	}

	UGen opBinary(string s)(UGen rhs){
		return new BinaryOpGen!s(this, rhs);
	}

	UGen opBinary(string s)(float rhs){
		return new BinaryOpGen!s(this, new LevelGen(rhs));
	}

	@property opDispatch(string param, T)(T u){
		SetParameter(param, u);
	}

	abstract double Generate(double dt);

	protected {
		double OptionalGenerate(string param, double dt, double defaultVal){
			auto gen = inputs.get(param, null);
			return gen? gen.Generate(dt) : defaultVal;
		}
	}
}

class LevelGen : UGen {
	double level;

	this(double _level){
		level = _level;
	}

	override double Generate(double dt){
		return level;
	}
}