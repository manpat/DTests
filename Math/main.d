module main;

import std.stdio;
import math.vector;
import math.matrix;

void main(){
	writeln("Thing");
	auto v = vec4(1, 2, 3, 4);
	auto v2 = vec4.one;
	v.g = 3;
	v.a = 8;

	writeln(-v + v2 * 2f, " ", v.x, " ", v.y, " ", v.z, " ", v.w, " ", v.magnitude);
	writeln(vec2.one);
	writeln(vec3.one);
	writeln(vec4.one);

	writeln("right cross up ", vec3.right.cross(vec3.up));
	writeln("up cross right ", vec3.up.cross(vec3.right));

	writeln("right dot up ", vec3.right.dot(vec3.up));
	writeln("right dot right ", vec3.right.dot(vec3.right));
	writeln("right dot (right+up) ", vec3.right.dot((vec3.right + vec3.up).normalised));

	v = vec4(1, 2, 3, 4);
	writeln(v, " ", v.wwwwwwwwwwwwwwwwwwwwwwww);
	v.zyx = v.rgb;
	writeln(v);

	v.yx = vec2.up; 
	writeln(v);

	auto m1 = mat4.identity;
	m1[0, 3] = 2f;
	m1[1, 3] = 3f;

	auto m2 = mat4.identity;
	m2[1, 1] = 0f;
	m2[2, 2] = 0f;
	m2[1, 2] = 1f;
	m2[2, 1] = 1f;
	m2[3, 2] = 1f;

	writeln("\n", m1, "\n");
	writeln(m2, "\n");
	writeln(m1 * m2);
}