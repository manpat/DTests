module main;

import std.stdio;
import std.math;

enum numValues = 1000;
enum period = 25f/numValues;

/+
 +	X_k = SUM (0..N-1) {x_n e^(-2pi i n/N k)}
 +	X_k = SUM (0..N-1) {f[n] expi(-2pi n/N k)}
 +/

real[] DFT(real[] f){
	auto XC = new creal[numValues];

	foreach(uint k; 0 .. numValues){
		creal Xk = 0.0 + 0.0i;

		foreach(uint n; 0 .. numValues){
			Xk += f[n] * expi(-2*PI * n/numValues * k);
		}

		XC[k] = Xk;
	}

	auto X = new real[numValues/2];

	X[0] = abs(XC[0])/numValues;
	foreach(uint k; 1 .. numValues/2){
		X[k] = (abs(XC[k]) + abs(XC[numValues-k]))/numValues;
		
		if(X[k] < 1e-06) X[k] = 0;
	}

	return X;
}

void main(){
	auto wave = new real[numValues];
	wave[] = 0;

	foreach(uint i; 0 .. numValues){
		wave[i] = cos(i*period*2*PI) + 1 + sin(i*period*2*PI * 3)*0.5;
	}

	auto ret = DFT(wave);
	writeln(ret);

	real sum = 0;
	real max = real.min_normal;
	uint idx = 0;
	uint midx = 0;

	foreach(real x; ret){
		sum += x;

		if(x > max && idx != 0){
			max = x;
			midx = idx;
		}

		idx++;
	}

	writeln(sum);
	writeln("fundamental freq: ", midx);
}
