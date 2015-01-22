#type vertex
#version 430

uniform float time;
in vec3 position;
out vec4 vpos;

void main(){
	vpos = vec4(position, 1.0);
}

#type tesscontrol
#version 430

layout(vertices = 3) out;

in vec4[] vpos;
out vec4[] tcpos;

void main(){
	tcpos[gl_InvocationID] = vpos[gl_InvocationID];

	if(gl_InvocationID == 0){
		int tl = 4;
		gl_TessLevelInner[0] = tl;
		gl_TessLevelOuter[0] = tl;
		gl_TessLevelOuter[1] = tl;
		gl_TessLevelOuter[2] = tl;
	}
}

#type tesseval
#version 430

layout(triangles, equal_spacing, ccw) in;

in vec4[] tcpos;
out vec4 tepos;

void main(){
	vec4 p0 = gl_TessCoord.x * tcpos[0];
	vec4 p1 = gl_TessCoord.y * tcpos[1];
	vec4 p2 = gl_TessCoord.z * tcpos[2];
	tepos = p0+p1+p2;
}

#type geometry
#version 430

layout(triangles) in;
layout(triangle_strip, max_vertices=3) out;
// layout(line_strip, max_vertices=3) out;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

uniform float time;

in vec4[] tepos;
out vec3 normal;
out float posLength;

vec4 mutate(vec4 v){
	vec3 x = v.xyz;

	x *= sin(x.y*x.x*20f + time/2f) * 0.1f + 1f;
	x *= sin(x.z*20f + sin(x.x*10f + time)) * 0.1f + 1f;

	x.x += sin(x.y*10f)*0.08f;
	x.z += sin(x.x*10f)*0.08f;
	x.y += sin(x.z + sin(x.z*4f + sin(x.x*8f + time)*0.5f)*2f)*0.2f;

	x.x *= x.y*x.y + x.z*x.z + 0.05f;
	x.z += x.x*x.x*(-x.z);
	x.y += x.x*x.x*(-x.y);
	x.x *= 1.5f;

	return vec4(x, v.w);
}

void v(vec4 v, vec3 norm){
	normal = norm;
	gl_Position = projectionMatrix * viewMatrix * modelMatrix * v;
	posLength = length(v);
	EmitVertex();
}

void main(){
	vec4 v0 = mutate(tepos[0]);
	vec4 v1 = mutate(tepos[1]);
	vec4 v2 = mutate(tepos[2]);

	vec3 a = (v2 - v0).xyz;
	vec3 b = (v1 - v0).xyz;
	vec3 norm = mat3(viewMatrix * modelMatrix) * normalize(cross(a, b));

	v(v0, norm);
	v(v1, norm);
	v(v2, norm);
	EndPrimitive();
}

#type fragment
#version 430

in vec3 normal;
in float posLength;
out vec4 color;

void main(){
	vec3 ldir = -normalize(vec3(-1f, 1f, 1f));
	float d = dot(normalize(normal), ldir);
	d = d*0.5 + 0.5;

	float pl = posLength*0.6f;
	vec3 c = vec3(pl*pl*pl, 1f-pl, 1f-pl*pl) - normal*0.2f;

	color = vec4(c*d, 1f);
}