module vector;

import std.stdio;
import std.math;

private immutable string elementNamesA = "xyzw";
private immutable string elementNamesB = "stuv";
private immutable string elementNamesC = "rgba";

private string vecProperties(uint numProps) pure 
in{
	assert(numProps >= 2 && numProps <= 4, "Vector must have between 2 and 4 elements");
}body{
	string sA = elementNamesA[0..numProps];
	string sB = elementNamesB[0..numProps];
	string sC = elementNamesC[0..numProps];

	char[] s;

	foreach(i; 0..numProps){
		s ~= "union{float "~sA[i]~", "~sB[i]~", "~sC[i]~";}\n";
	}

	return "struct{"~s~"}";
}

struct vec(uint dim){
public:
	union{
		mixin(vecProperties(dim));
		float[dim] values;		
	}

	alias vecx = vec!dim;

public:
	this(float[dim] a){
		foreach(i; 0..dim){
			values[i] = a[i];
		}
	}
	this(float[] a){
		assert(a.length == dim, "Vec dimension mismatch");
		foreach(i; 0..dim){
			values[i] = a[i];
		}
	}
	this(float[dim] a...){
		foreach(i; 0..dim){
			values[i] = a[i];
		}
	}

	void opAssign(T)(T[dim] a){
		foreach(i; 0..dim){
			values[i] = a[i];
		}
	}

	vecx opUnary(string op)() if(op == "-"){
		float[dim] v = -values[];
		return vecx(v);
	}
	vecx opBinary(string op)(vecx rhs){
		static if(op == "+"){
			float[dim] v = values[] + rhs.values[];
			return vecx(v);
		}else static if(op == "-"){
			float[dim] v = rhs.values[] - values[];
			return vecx(v);			
		}
	}
	vecx opBinary(string op)(float rhs){
		static if(op == "*"){
			float[dim] v = values[] * rhs;
			return vecx(v);
		}else static if(op == "/"){
			float[dim] v = values[] / rhs;
			return vecx(v);		
		}/*else static if(op == "+"){
			float[dim] v = values[] + rhs;
			return vecx(v);
		}else static if(op == "-"){
			float[dim] v = values.dup;
			v[] -= rhs;
			return vecx(v);			
		}*/
	}

	static uint dimensions(){
		return dim;
	}

	float magnitude(){
		float m = 0;
		foreach(i; 0..dim){
			m += values[i] * values[i];
		}

		return m;
	}

	vecx normalised(){
		float m = this.magnitude;
		if(m == 0f) return vecx();

		vecx ret = this / m;

		return ret;
	}

	vecx rotate(float th){
		assert(dim == 2, "Rotate only implemented for 2 dimensions");

		float cs = cos(th);
		float sn = sin(th);

		vecx ret;
		ret.x = x * cs - y * sn;
		ret.y = x * sn + y * cs;
		return ret;
	}

	string toString(){
		import std.conv : to;

		return to!string(values);
	}
}

alias vec2 = vec!2;
alias vec3 = vec!3;
alias vec4 = vec!4;