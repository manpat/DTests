/**
 *	This module implements tests for D classes
 */

 module testing.classes;

import std.stdio;

interface IThing {
	void S();
}

class Thing : IThing {
	this(){ 
		this(0);
	}

	this(int i) {
		x = i;
	}

	~this(){
		writeln("Thing ", x, " destroyed");
	}

	void S(){
		writeln("I am thing ", x);
	}

	int opBinary(string op)(Thing rhs){
		return mixin("x "~op~" rhs.x");
	}

	int x;
}

class Thing1 : IThing {
	~this(){
		writeln("Thing1 destroyed");
	}

	void S(){
		writeln("Thing1");
	}
}

class Thing2 : IThing {
	~this(){
		writeln("Thing2 destroyed");
	}

	void S(){
		writeln("Thing2");
	}
}