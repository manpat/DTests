#type compute
#version 430

layout (local_size_x = 2, local_size_y = 1) in;

struct Test {
	vec4 dat;
	vec4 dat2;
	bool d3;
};

layout (std430, binding = 0) buffer databuf {
	float data[];
};
layout (std430, binding = 1) buffer testbuf {
	Test tests[];
};

void main(){
	uvec3 gidx = gl_WorkGroupID;
	uvec3 lidx = gl_LocalInvocationID;

	data[gidx.x] = 5f;
	tests[gidx.x].dat = vec4(1, 2, 3, 4);
	tests[gidx.x].dat2 += vec4(gidx.y+1, lidx.x, lidx.y, 0);
	tests[gidx.x].dat2.w = gidx.y+1;
	tests[gidx.x].d3 = true;
}