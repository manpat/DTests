#type vertex
#version 430

uniform vec2 transform;

in vec2 pos;

void main(){
	gl_Position = vec4(pos + transform, 0, 1);
}

#type fragment
#version 430

uniform vec4 tint;
out vec4 color;

void main(){
	color = tint;
}