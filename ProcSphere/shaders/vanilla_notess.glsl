#type vertex
#version 430

uniform float time;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

in vec3 position;

out vec3 vpos;
out vec3 vcol;

void main(){
	vpos = position;
	vcol = position.xyz*0.5f + 0.5f;
}

#type geometry
#version 430

layout(triangles) in;
layout(/*points */ triangle_strip, max_vertices=3) out;

uniform float time;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

in vec3 vpos[];
in vec3 vcol[];

out vec3 gpos;
out vec3 gcol;
out vec3 gnorm;

void v(int i, vec3 norm){
	gpos = vpos[i];
	gcol = vcol[i];
	gnorm = norm;

	gl_Position = projectionMatrix * modelViewMatrix * vec4(gpos, 1f);
	EmitVertex();
}

void main(){
	vec3 a = vpos[2] - vpos[0];
	vec3 b = vpos[1] - vpos[0];
	vec3 norm = mat3(modelViewMatrix) * normalize(cross(a, b));

	v(0, norm);
	v(1, norm);
	v(2, norm);
	EndPrimitive();
}

#type fragment
#version 430

uniform float time;

in vec3 gpos;
in vec3 gcol;
in vec3 gnorm;
out vec4 color;

void main(){
	vec3 l = normalize(-vec3(1, 0.5, -1));
	vec3 n = normalize(gnorm);
	float ndl = max(dot(n, l), 0);

	color = vec4(gcol * (ndl + 0.1f), 1f); 
	// color = vec4(gpos*0.8f + 0.2f, 1f);
	// color = vec4(gnorm*0.8f + 0.2f, 1f);
}