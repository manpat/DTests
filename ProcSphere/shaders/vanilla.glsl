#type vertex
#version 430

uniform float time;

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

in vec3[] vpos;
in vec3[] vcol;

out vec3[] tcpos;
out vec3[] tccol;

void main(){
	tcpos[gl_InvocationID] = vpos[gl_InvocationID];
	tccol[gl_InvocationID] = vcol[gl_InvocationID];

	if(gl_InvocationID == 0){
		int tin = 7;
		int tout = 7;
		gl_TessLevelInner[0] = tin;
        gl_TessLevelOuter[0] = tout;
        gl_TessLevelOuter[1] = tout;
        gl_TessLevelOuter[2] = tout;
	}
}

#type tesseval
#version 430

layout(triangles, equal_spacing, cw) in;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

in vec3[] tcpos;
in vec3[] tccol;

out vec3 tepos;
out vec3 tecol;
out vec3 tepatchdist;

void main(){
	vec3 p0 = gl_TessCoord.x * tcpos[0];
	vec3 p1 = gl_TessCoord.y * tcpos[1];
	vec3 p2 = gl_TessCoord.z * tcpos[2];
	tepatchdist = gl_TessCoord;
	tepos = normalize(p0+p1+p2);
	tecol = tccol[0];
	gl_Position = projectionMatrix * modelViewMatrix * vec4(tepos, 1f);
}

#type geometry
#version 430

layout(triangles) in;
layout(/* points */ triangle_strip, max_vertices = 3) out;

uniform float time;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

in vec3[] tepos;
in vec3[] tecol;
in vec3[] tepatchdist;
out vec3 gpos;
out vec3 gcol;
out vec3 gnorm;
out vec3 gpdist;

void v(uint i){
	gl_Position = gl_in[i].gl_Position;
	gpos = tepos[i].xyz;
	gcol = tecol[i];
	gpdist = tepatchdist[i];
	EmitVertex();
}

vec3 mid(vec3 v1, vec3 v2){
	return normalize((v1+v2)/2f);
}

void main(){
	vec3 a = tepos[2] - tepos[0];
	vec3 b = tepos[1] - tepos[0];
	gnorm = mat3(modelViewMatrix) * normalize(cross(a, b));

	v(0);
	v(1);
	v(2);
	EndPrimitive();
}

#type fragment
#version 430

uniform float time;

in vec3 gpos;
in vec3 gcol;
in vec3 gnorm;
in vec3 gpdist;
out vec4 color;

void main(){
	vec3 l = normalize(vec3(1, 0, -1));
	vec3 n = normalize(gnorm);
	float ndl = max(dot(n, l), 0);

	color = vec4(gcol * (ndl + 0.1f) + gpdist * 0.2f, 1f); 
}