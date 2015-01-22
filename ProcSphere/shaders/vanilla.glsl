#type vertex
#version 430

uniform float time;
uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

in vec3 position;
out vec3 vpos;

void main(){
	vpos = position;
}

#type tesscontrol
#version 430

layout(vertices = 3) out;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform int tessLevel;

in vec3[] vpos;
out vec3[] tcpos;

vec3 hsv2rgb(vec3 c){
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float level(vec4 p, float tsize){
	float d = length(p);
	d = d/tsize;
	float l = 1.0 / (d*d*d);

	return clamp(
		1000f*l, 
		0, 4000f);
}

void main(){
	tcpos[gl_InvocationID] = vpos[gl_InvocationID];

	if(gl_InvocationID == 0){
		vec4 v0 = viewMatrix * modelMatrix * vec4(vpos[0], 1f);
		vec4 v1 = viewMatrix * modelMatrix * vec4(vpos[1], 1f);
		vec4 v2 = viewMatrix * modelMatrix * vec4(vpos[2], 1f);

		vec4 d0 = (v1 + (v2 - v1)/2f); // Half way v1 - v2
		vec4 d1 = (v0 + (v2 - v0)/2f); // Half way v0 - v2
		vec4 d2 = (v0 + (v1 - v0)/2f); // Half way v1 - v0
		vec4 dc = (v0 + (d0 - v0)/2f); // Center

		float tsize = (length(v0-v1) + length(v0-v2) + length(v1-v2))/3f;

		float e0 = level(d0, tsize);
		float e1 = level(d1, tsize);
		float e2 = level(d2, tsize);

		float mn = min(e0, min(e1, e2));
		float mx = max(e0, max(e1, e2));

		gl_TessLevelInner[0] = tessLevel + floor((mx));
		gl_TessLevelOuter[0] = tessLevel + e0;
		gl_TessLevelOuter[1] = tessLevel + e1;
		gl_TessLevelOuter[2] = tessLevel + e2;
	}
}

#type tesseval
#version 430

layout(triangles, equal_spacing, cw) in;
uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

in vec3[] tcpos;
out vec3 tepos;

float sinnoise(float x){
	return abs(fract( sin(x) * 999f));
}

float sinnoise3(vec3 p){
	return sinnoise(p.x) + sinnoise(p.y) + sinnoise(p.z);
}

float smoothnoise(vec3 p){
	return sinnoise3(p) * smoothstep(0, 1, p) + sinnoise3(p-1) * smoothstep(0, 1, 1-p);
}

float noise(vec3 p){
	const int it = 5;
	float d = 0f;

	for(int i = 1; i < it; i++){
		d += smoothnoise(p / float(i));
	}

	d /= float(it);

	return d;
}

void main(){
	vec3 p0 = gl_TessCoord.x * tcpos[0];
	vec3 p1 = gl_TessCoord.y * tcpos[1];
	vec3 p2 = gl_TessCoord.z * tcpos[2];
	tepos = normalize(p0+p1+p2);

	float height = 0.003f;
	vec3 npos = tepos;

	tepos += noise(npos)*tepos*height;
	tepos += noise(npos*2f)/2f*tepos*height;
	tepos += noise(npos*3f)/3f*tepos*height;
	tepos += noise(npos*4f)/4f*tepos*height;
	tepos += noise(npos*8f)/8f*tepos*height;
}

#type geometry
#version 430

layout(triangles) in;
layout(triangle_strip, max_vertices=3) out;
// layout(points, max_vertices=3) out;
// layout(line_strip, max_vertices=6) out;

uniform float time;
uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

in vec3[] tepos;
out vec3 gpos;
out vec3 gnorm;

void v(uint i, vec3 norm){
	gpos = tepos[i];
	gnorm = norm;

	float far = 5000000;
	float res = 0.01;

	gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(gpos, 1f);
	gl_Position.z = 2.0*log(gl_Position.w*res + 1)/log(far*res + 1) - 1;
	gl_Position.z *= gl_Position.w;

	EmitVertex();
}

void main(){
	vec3 a = tepos[2] - tepos[0];
	vec3 b = tepos[1] - tepos[0];
	vec3 norm = mat3(viewMatrix * modelMatrix) * normalize(cross(a, b));

	v(1, norm);
	v(0, norm);
	v(2, norm);
	EndPrimitive();

	// v(0, norm);
	// v(1, norm);
	// EndPrimitive();
	// v(2, norm);
	// v(1, norm);
	// EndPrimitive();
	// v(0, norm);
	// v(2, norm);
	// EndPrimitive();
}

#type fragment
#version 430

uniform float time;
uniform vec3 planetcol;
uniform vec3 sunpos;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform vec3 eyepos;

in vec3 gpos;
in vec3 gnorm;
out vec4 color;

void main(){
	// vec3 l = normalize( mat3(viewMatrix) * (eyepos) - mat3(viewMatrix * modelMatrix) * vec3(0,0,0) );
	vec3 l = normalize( mat3(viewMatrix) * vec3(-1, 1, 1) );
	vec3 n = normalize(gnorm);
	float ndl = max(dot(n, l), 0);

	color = vec4(planetcol * ndl * 0.7f + 0.3f * planetcol, 1f);
}