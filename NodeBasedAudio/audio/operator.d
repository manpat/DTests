module audio.operator;

import audio.common;

class BinaryOpGen(string op) : Generator {
	ulong left;
	ulong right;

	this(Generator _left, Generator _right){
		left = _left.id;
		right = _right.id;
	}

	override double Generate(double dt){
		return mixin("AudioManager.GetValue(left) "~op~" AudioManager.GetValue(right)");
	}
}

class UnaryOpGen(string op) : Generator {
	ulong operand;

	this(Generator _operand) {
		Log("UNARY OP ", op);
		operand = _operand.id;
	}

	override double Generate(double dt){
		return mixin(op ~ "AudioManager.GetValue(operand)");
	}
}