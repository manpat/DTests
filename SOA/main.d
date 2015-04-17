module main;

import std.conv;
import std.stdio;
import std.datetime;

enum dataSize = 50_000;
enum tests = 100;
enum iterations = 1000;

void main(){
	writeln("AOS vs SOA vs D Vector");

	auto result = benchmark!(AOSBench, SOABench, VectorBench)(tests);
	writeln("Data count: ", dataSize);
	writeln("Benchmarks run: ", tests);
	writeln("Iterations: ", iterations);
	writeln("AOS: ", to!Duration(result[0]));
	writeln("SOA: ", to!Duration(result[1]));
	writeln("Vec: ", to!Duration(result[2]));
}

struct S{
	float x;
	float v;
	float a;
}

struct SOA{
	float[dataSize] x;
	float[dataSize] v;
	float[dataSize] a;
}

S[dataSize] aos;
SOA soa;

enum dt = 0.01f;

void AOSBench(){
	for(uint i = 0; i < dataSize; i++){
		aos[i].x = 0f;
		aos[i].v = 0f;
		aos[i].a = i * 0.01f;
	}

	for(uint i = 0; i < dataSize; i++){
		for(uint t = 0; t < iterations; t++){
			aos[i].v += aos[i].a * dt;
			aos[i].x += aos[i].v * dt;
		}
	}
}

void SOABench(){
	for(uint i = 0; i < dataSize; i++){
		soa.x[i] = 0f;
		soa.v[i] = 0f;
		soa.a[i] = i * 0.01f;
	}

	for(uint i = 0; i < dataSize; i++){
		for(uint t = 0; t < iterations; t++){
			soa.v[i] += soa.a[i] * dt;
			soa.x[i] += soa.v[i] * dt;
		}
	}
}

void VectorBench(){
	for(uint i = 0; i < dataSize; i++){
		soa.x[i] = 0f;
		soa.v[i] = 0f;
		soa.a[i] = i * 0.01f;
	}

	for(uint t = 0; t < iterations; t++){
		soa.v[] += soa.a[] * dt;
		soa.x[] += soa.v[] * dt;
	}
}
