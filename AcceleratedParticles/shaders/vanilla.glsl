#type vertex
#version 430

uniform float time;

in vec4 position;
in vec4 color;

out vec4 vcol;

void main(){
	gl_Position = vec4(position.xyz, 1f);
	vcol = vec4(color.xyz, 1f);
}

#type fragment
#version 430

uniform float time;

in vec4 vcol;
out vec4 color;

void main(){
	color = vcol; 
}