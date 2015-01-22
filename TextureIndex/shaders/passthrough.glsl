#type vertex
#version 430

uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat4 modelMatrix;

in vec3 position;
in vec2 uv;

out vec4 pos;
out vec2 vuv;

void main(){
	pos = projectionMatrix * viewMatrix * modelMatrix * vec4(position, 1.0);
	gl_Position = pos;

	vuv = uv;
}

#type fragment
#version 430

uniform float time;
uniform sampler2D indexTex;
uniform sampler2DArray texArray;

in vec4 pos;
in vec2 vuv;
out vec4 color;

void main(){
	// vec2 uv = vuv*4f;
	vec2 uv = pos.xy;

	float idx = texture(indexTex, vuv).r*255f;
	float idx1 = floor(idx);
	float idx2 = ceil(idx);
	float a = idx - idx1;

	vec3 c1 = texture(texArray, vec3(uv*2f, idx1)).xyz;
	vec3 c2 = texture(texArray, vec3(uv*2f, idx2)).xyz;
	vec3 c = c1 * (1f - a) + c2 * a;

	color = vec4(c, 1f);
}