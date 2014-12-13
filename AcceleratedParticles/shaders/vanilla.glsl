#type vertex
#version 430

uniform float time;
uniform bool drawcols;

in vec4 position;
in vec4 color;

out vec4 vcol;

void main(){
	// float a = time * pi() / 2f;

	gl_Position = vec4(position.xyz, 1f);
	
	if(drawcols){
		vcol = vec4(color.xyz, 1f);
	}else{
		vcol = vec4(1f, 0f, 0f, 1f);
	}
}

#type fragment
#version 430

uniform float time;

in vec4 vcol;
out vec4 color;

void main(){
	color = vcol; 
}