module audio.operator;

import audio.ugen;

class BinaryOpGen(string op) : UGen {
	UGen left;
	UGen right;

	this(UGen _left, UGen _right){
		left = _left;
		right = _right;
	}

	override double Generate(double dt){
		return mixin("left.Generate(dt) "~op~" right.Generate(dt)");
	}
}
