module quaternion;

import std.math;
import vector;

struct Quaternion {
	float w;

	union {
		struct{
			float x, y, z;
		}
		vec3 v;
	}

	static Quaternion AxisAngle(vec3 v, float th){
		Quaternion ret; 
		ret.w = cos(th/2);
		ret.v = v * sin(th/2);
		return ret;
	}

	static Quaternion Point(vec3 v){
		Quaternion ret; 
		ret.w = 0;
		ret.v = v;
		return ret;
	}

	Quaternion add(const Quaternion o) const{
		Quaternion r;
		r.w = w + o.w;
		r.v = v + o.v;
		return r;
	}

	Quaternion inverse() const{
		Quaternion r;
		r.w = w;
		r.v = -v; 
		return r;
	}

	Quaternion mul(const Quaternion o) const{
		Quaternion r;
		//r.w = w + o.w;
		//r.v = v + o.v;
		return r;
	}

	Quaternion opBinary(string op)(Quaternion o){
		static if(op == "*"){
			return mul(o);
		}
	}

	string toString() const {
		import std.format;
		import std.array : appender;

		auto writer = appender!string();
		writer.formattedWrite("[%s, %s, %s, %s]", w, x, y, z);

		return writer.data();
	}
}