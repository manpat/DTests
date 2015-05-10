#version 330
#type vertex

uniform mat4 projection;
uniform mat4 modelview;

in vec3 position;

void main(){
	vec4 p = modelview * vec4(position, 1f);
	gl_Position = projection * p;
}

#type fragment

uniform vec3 c;

out vec4 color;

void main(){
	color = vec4(c, 1);
}