import std.stdio;
import std.conv;
import std.math;
import std.random;

import vector;
import quaternion;

void main(){
	try{
		auto v0 = vec4(1, 0, 0, 0);
		auto q = Quaternion.AxisAngle(vec3(0, 1, 0), PI/2);
		auto q2 = Quaternion.Point(vec3(0, 1, 0));

		writeln("v0 ", v0);
		writeln("q ", q);
		writeln("q2 ", q2);
		writeln("qi ", q.inverse);

	}catch(Exception e){
		writeln("Fuck: ", e.msg);
	}
}
