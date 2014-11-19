#type compute
#version 430

layout (local_size_x = 1, local_size_y = 1) in;

uniform double dt;

struct Particle{
	dvec4 pos;
	dvec4 vel;
	dvec4 col;
};

struct Attractor{
	dvec4 pos;
	double strength;
};

layout (std430, binding = 0) buffer pbuf{
	Particle particles[];
};
layout (std430, binding = 1) buffer abuf{
	Attractor attractors[];
};

void main(){
	uvec3 gidx = gl_WorkGroupID;
	uint idx = gidx.z * gl_NumWorkGroups.y * gl_NumWorkGroups.x + gidx.y * gl_NumWorkGroups.x + gidx.x;

	if(particles[idx].vel.w == 0f) return;

	dvec4 acc = dvec4(0);

	for(uint i = 0; i < attractors.length(); i++){
		dvec4 diff = attractors[i].pos - particles[idx].pos;
		dvec4 dir = normalize(diff);
		double d = length(diff);
		double force = 1f/(d);

		acc += dir * force * attractors[i].strength;
	}

	particles[idx].vel += acc * dt;
	dvec4 vel = particles[idx].vel;
	particles[idx].pos += vel * dt;
	particles[idx].pos.w = 0f;
	particles[idx].col = dvec4(vel.x, vel.y, 1f-vel.x, 1f);

	if(length(particles[idx].pos) > 3f) particles[idx].vel.w = 0f;
}