#version 330
#type vertex

uniform mat4 projection;
uniform mat4 modelview;

in vec3 position;
in vec3 normal;
out vec3 vpos;
out vec3 vnorm;

void main(){
	vec4 p = modelview * vec4(position, 1f);
	gl_Position = projection * p;

	vpos = position;
	vnorm = normalize(mat3(modelview)*normal);
}

#type fragment

uniform vec3 c;

in vec3 vpos;
in vec3 vnorm;
out vec4 color;

void main(){
	vec3 dir = normalize(vec3(0,1,1)*100f-vpos);
	float d = clamp(dot(vnorm, dir), 0.3f, 1f);

	vec3 col = c*d;

	color = vec4(col, 1);
}