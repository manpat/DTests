#type vertex
#version 430

in vec2 pos;
in vec2 uv;

out vec2 vuv;

void main(){
	gl_Position = vec4(pos, 0, 1);

	vuv = uv;
}

#type fragment
#version 430

uniform sampler2D fonttex;

in vec2 vuv;

out vec4 color;

void main(){
	color = texture2D(fonttex, vuv);
}