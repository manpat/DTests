#type vertex
#version 420

in vec2 position;
out vec2 uv;

void main(){
	uv = position*0.5 + 0.5;
	gl_Position = vec4(position, 0, 1);
}

#type fragment
#version 420

uniform sampler2D fbColor;
uniform sampler2D fbDepth;
uniform float time;

in vec2 uv;
out vec4 color;

float getDepthAt(vec2 _uv){
	float d = texture2D(fbDepth, _uv).r;
	float dn = d * 2.0 - 1.0;

	float n = 1f;
	float f = 500f;
	// return (2.0 * n) / (f + n - dn * (f - n));
	return (dn * f) / (f - n);
}

vec3 gaussianBlur( vec2 centreUV, vec2 pixelOffset ) {
	vec3 colOut = vec3( 0, 0, 0 );

	////////////////////////////////////////////////
	// Kernel width 7 x 7
	//
	const int stepCount = 2;
	//
	const float gWeights[stepCount] = float[](
	   0.44908,
	   0.05092
	);
	const float gOffsets[stepCount] = float[](
	   0.53805,
	   2.06278
	);
	////////////////////////////////////////////////;

	for( int i = 0; i < stepCount; i++ ){
		vec2 texCoordOffset = gOffsets[i] * pixelOffset;
		vec3 col = texture( fbColor, centreUV + texCoordOffset ).xyz +
				   texture( fbColor, centreUV - texCoordOffset ).xyz;
		colOut += gWeights[i] * col;
	}

	return colOut;
}

vec3 blur(vec2 pos, float amt){
	vec3 c = vec3(0,0,0);

	float cnt = 2f;

	// c += texture2D(fbColor, pos).xyz;
	for(float x = -cnt; x <= cnt; x += 1f){
		for(float y = -cnt; y <= cnt; y += 1f){
			c += texture(fbColor, pos + vec2(x,y)*amt*0.01f).xyz / (4.0*cnt*cnt);
		}
	}

	return c;
}

void main(){
	float d = getDepthAt(uv);
	float blurAmt = length(uv*2f - 1f) * length(uv*2f - 1f) * 0.4f + d*0.1f;

	float amt = 0.016f;

	vec3 c = gaussianBlur(uv, amt * vec2(blurAmt, 0));
	c += gaussianBlur(uv, amt * vec2(0, blurAmt));
	c /= 2f;

	float vignetteFactor = 1.1f - length(uv*2f - 1f) * 0.4f;
	c *= vignetteFactor;

	// if(uv.x < 0.5f)
	// 	c = vec3(blurAmt);
		// c = vec3(vignetteFactor*0.5f);

	color = vec4(c, 1);
}
