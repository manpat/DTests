/**
 *	This module implements tests for D functions
 */

module testing.funcs;

import std.stdio;
import core.simd;

/++ 
 +	A compile time executed function for calculating the ficonacci sequence
 +/
template fib(int x){
	static if(x > 1)
		enum fib = fib!(x-1) + fib!(x-2);
	else
		enum fib = 1;
}

/++
 + Swizzles elements in a float4
 +
 + Bug: doesn't work in dmd
 +/
float4 swizzle(char[4] e)(float4 v) {
	version(DigitalMars){
		return [0,0,0,0];
	}
	version(GNU){
		return [
			mixin("v.array["~e[0]~"]"),
			mixin("v.array["~e[1]~"]"),
			mixin("v.array["~e[2]~"]"),
			mixin("v.array["~e[3]~"]")
		];
	}
}

void simdTest(){
	float4 v1 = [1, 2, 3, 4];
	float4 v2 = [2, 3, 4, 3];

	v1 = v1.swizzle!"0132";
	writeln(v1.array);

	auto v3 = v1 + v2;
	writeln(v3.array);

	auto v4 = v3 / 2.0;
	writeln(v4.array);
}
