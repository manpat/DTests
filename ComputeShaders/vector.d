module vector;

import std.stdio;
import std.math;
import std.traits;

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
		s ~= "union{elementType "~sA[i]~", "~sB[i]~", "~sC[i]~";}\n";
	}

	return "struct{"~s~"}";
}

struct vec(elementType, uint dim){
public:
	union{
		mixin(vecProperties(dim));
		elementType[dim] values;		
	}

	alias vecx = vec!(elementType, dim);

public:
	this(elementType[dim] a){
		foreach(i; 0..dim){
			values[i] = a[i];
		}
	}
	this(elementType[] a){
		assert(a.length == dim, "Vec dimension mismatch");
		foreach(i; 0..dim){
			values[i] = a[i];
		}
	}
	this(elementType[dim] a...){
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
		elementType[dim] v = -values[];
		return vecx(v);
	}
	vecx opBinary(string op)(vecx rhs){
		static if(op == "+"){
			elementType[dim] v = values[] + rhs.values[];
			return vecx(v);
		}else static if(op == "-"){
			elementType[dim] v = rhs.values[] - values[];
			return vecx(v);			
		}
	}
	vecx opBinary(string op)(elementType rhs){
		static if(op == "*"){
			elementType[dim] v = values[] * rhs;
			return vecx(v);
		}else static if(op == "/"){
			elementType[dim] v = values[] / rhs;
			return vecx(v);		
		}/*else static if(op == "+"){
			elementType[dim] v = values[] + rhs;
			return vecx(v);
		}else static if(op == "-"){
			elementType[dim] v = values.dup;
			v[] -= rhs;
			return vecx(v);			
		}*/
	}

	static uint dimensions(){
		return dim;
	}

	static if(isFloatingPoint!elementType){
		elementType magnitude(){
			elementType m = 0;
			foreach(i; 0..dim){
				m += values[i] * values[i];
			}

			return m;
		}

		vecx normalised(){
			elementType m = this.magnitude;
			if(m == 0f) return vecx();

			vecx ret = this / m;

			return ret;
		}

		vecx rotate(elementType th){
			assert(dim == 2, "Rotate only implemented for 2 dimensions");

			elementType cs = cos(th);
			elementType sn = sin(th);

			vecx ret;
			ret.x = x * cs - y * sn;
			ret.y = x * sn + y * cs;
			return ret;
		}
	}

	string toString(){
		import std.conv : to;

		return to!string(values);
	}
}

alias vec2 = vec!(float, 2);
alias vec3 = vec!(float, 3);
alias vec4 = vec!(float, 4);

alias uvec2 = vec!(uint, 2);
alias uvec3 = vec!(uint, 3);
alias uvec4 = vec!(uint, 4);

alias ivec2 = vec!(int, 2);
alias ivec3 = vec!(int, 3);
alias ivec4 = vec!(int, 4);