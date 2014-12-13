#type vertex
#version 430

uniform float time;
uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

in vec3 position;

out vec3 vpos;
out vec3 vcol;

void main(){
	vpos = position;
	vcol = position.xyz*0.5f + 0.5f;
}

#type tesscontrol
#version 430

layout(vertices = 3) out;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform int tessLevel;
uniform vec3 eyepos;

in vec3[] vpos;
in vec3[] vcol;

out vec3[] tcpos;
out vec3[] tccol;

vec3 hsv2rgb(vec3 c){
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float level(vec3 p1, vec3 p2){
	float d = distance(p1, p2);

	return clamp(
		100f/(d), 
		1, 100);
}

void main(){
	tcpos[gl_InvocationID] = vpos[gl_InvocationID];
	tccol[gl_InvocationID] = vcol[gl_InvocationID];

	if(gl_InvocationID == 0){
		vec4 v0 = modelMatrix * vec4(vpos[0], 1f);
		vec4 v1 = modelMatrix * vec4(vpos[1], 1f);
		vec4 v2 = modelMatrix * vec4(vpos[2], 1f);

		vec3 d0 = (v1 + (v2 - v1)/2f).xyz;
		vec3 d1 = (v0 + (v2 - v0)/2f).xyz;
		vec3 d2 = (v0 + (v1 - v0)/2f).xyz;

		float e0 = level(d0, -eyepos);
		float e1 = level(d1, -eyepos);
		float e2 = level(d2, -eyepos);

		float m = min(e0, min(e1, e2));
		tccol[gl_InvocationID] = hsv2rgb(vec3(1f - clamp(distance(v0.xyz, -eyepos), 0, 10)/10f, 1f, 1f)); // vec3(m/10f, m/20f, sin(m));
		// tccol[gl_InvocationID] = vec3(e0/20f, e1/20f, e2/20f);
		// tccol[1] = vec3(0.4f);
		// tccol[2] = vec3(0.4f);

		// int tin = tessLevel + LOD;
		// int tout = tessLevel + LOD;
		gl_TessLevelInner[0] = tessLevel + floor( (min(e0, min(e1, e2)) + max(e0, max(e1, e2)))/2f );
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
in vec3[] tccol;

out vec3 tepos;
out vec3 tecol;

void main(){
	vec3 p0 = gl_TessCoord.x * tcpos[0];
	vec3 p1 = gl_TessCoord.y * tcpos[1];
	vec3 p2 = gl_TessCoord.z * tcpos[2];
	vec3 sum = p0+p1+p2;
	tepos = normalize(sum) * (sum/3).length;
	tecol = tccol[0];
}

#type geometry
#version 430

layout(triangles) in;
// layout(triangle_strip, max_vertices=3) out;
layout(points, max_vertices=3) out;

uniform float time;
uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

in vec3[] tepos;
in vec3[] tecol;
out vec3 gpos;
out vec3 gcol;
out vec3 gnorm;

void v(uint i, vec3 norm){
	gpos = tepos[i];
	gcol = tecol[i];
	gnorm = norm;

	gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(gpos, 1f);
	EmitVertex();
}

void main(){
	vec3 a = tepos[2] - tepos[0];
	vec3 b = tepos[1] - tepos[0];
	vec3 norm = mat3(viewMatrix * modelMatrix) * normalize(cross(a, b));

	v(0, norm);
	v(1, norm);
	v(2, norm);
	EndPrimitive();
}

#type fragment
#version 430

uniform float time;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform vec3 eyepos;

in vec3 gpos;
in vec3 gcol;
in vec3 gnorm;
out vec4 color;

void main(){
	vec3 l = normalize(-vec3(1, 0.5, -1));
	vec3 n = normalize(gnorm);
	float ndl = max(dot(n, l), 0);
	// float ndl = dot(n, l);

	// color = vec4(gcol * ndl * 0.8f + 0.2f, 1f); 
	color = vec4(gcol + 0.5f, 1f);
}