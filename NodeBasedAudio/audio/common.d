module audio.common;

public import audio.manager;
import audio.operator;

void Log(T...)(T t){
	import std.stdio;

	writeln("[Log] ", t);
	stdout.flush();
}

interface Triggerable {
	abstract void Trigger();
}

class Generator {
	public ulong id = 0;
	protected ulong[string] inputs;

	this(){
		AudioManager.Add(this);
		Log("Generator ", id);
	}

	void SetParameter(string p, Generator u){
		inputs[p] = u.id;
	}

	void SetParameter(string p, double c){
		inputs[p] = (new LevelGen(c)).id;
	}

	Generator opUnary(string s)(){
		return new UnaryOpGen!s(this);
	}

	Generator opBinary(string s)(Generator rhs){
		return new BinaryOpGen!s(this, rhs);
	}

	Generator opBinary(string s)(double rhs){
		return new BinaryOpGen!s(this, new LevelGen(rhs));
	}
	Generator opBinaryRight(string s)(double lhs){
		return new BinaryOpGen!s(new LevelGen(lhs), this);
	}

	@property opDispatch(string param, T)(T u){
		SetParameter(param, u);
	}

	abstract double Generate(double dt);

	protected {
		double OptionalGenerate(string param, double defaultVal){
			auto genid = param in inputs;
			return genid? AudioManager.GetValue(*genid) : defaultVal;
		}
	}
}


class LevelGen : Generator {
	double level;

	this(double _level){
		level = _level;
		Log("LevelGen ", level);
	}

	override double Generate(double dt){
		return level;
	}
}