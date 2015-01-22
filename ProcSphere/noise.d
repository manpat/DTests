module noise;

import std.random;
import std.stdio;
import std.range;
import std.array;
import std.math;
import gl;

private {
	vec3[] gradients = [
		vec3(1,1,0), vec3(-1,1,0), vec3(1,-1,0), vec3(-1,-1,0),
		vec3(1,0,1), vec3(-1,0,1), vec3(1,0,-1), vec3(-1,0,-1),
		vec3(0,1,1), vec3(0,-1,1), vec3(0,1,-1), vec3(0,-1,-1),
		vec3(1,1,0), vec3(0,-1,1), vec3(-1,1,0), vec3(0,-1,-1),
	];
}

class PerlinNoise {
	Random gen;
	int[] permutations;

	this(uint seed = 237){
		gen.seed(seed);

		permutations = array(iota(0, 255));
		randomShuffle(permutations, gen);

		writeln(permutations);
	}

	double GetRandom(){
		return uniform01(gen);
	}

}