module hud.text;

import std.string;
import std.stdio;
import gl;
import shader;
import vertexarray;
import hud.stuff;

private { 
	TTF_Font* font;
	uint ftex;
	Shader textShader;

	VertexArray!vec2 quadVertices;
	VertexArray!vec2 quadUVs;

	Attribute posAttr;
	Attribute uvAttr;
}

void InitHUDText(){
	font = TTF_OpenFont("arial.ttf", 36);

	if(!font){
		throw new Exception("GUIText.font init failed");
	}
	textShader = GetShader("text");

	glGenTextures(1, &ftex);
	glBindTexture(GL_TEXTURE_2D, ftex);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glBindTexture(GL_TEXTURE_2D, 0);

	posAttr = textShader.GetAttribute("pos");
	uvAttr = textShader.GetAttribute("uv");

	quadVertices = new VertexArray!vec2();
	quadUVs = new VertexArray!vec2();

	quadUVs.Load([
		vec2(0, 1),
		vec2(1, 0),
		vec2(0, 0),

		vec2(0, 1),
		vec2(1, 1),
		vec2(1, 0),
	]);
}

void PrintHUD(GUIAnchor anchor = GUIAnchor.Left, T)(T s, vec2 pos){
	static SDL_Color white = {255, 255, 255, 1};
	SDL_Surface* surf = TTF_RenderUTF8_Blended(font, s.toStringz, white);

	if(!surf){
		writeln("TTF_RenderText_Blended failed");
		return;
	}
	scope(exit) SDL_FreeSurface(surf);

	glDisable(GL_DEPTH_TEST);
	glEnable(GL_TEXTURE_2D);

	glBindTexture(GL_TEXTURE_2D, ftex);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, surf.w, surf.h, 0, GL_RGBA, GL_UNSIGNED_BYTE, surf.pixels);

	vec2 size = vec2(surf.w/800.0, surf.h/600.0);

	static if(anchor == GUIAnchor.Right){
		pos -= vec2(size.x, 0);
	}else static if(anchor == GUIAnchor.Center){
		pos -= vec2(size.x/2f, 0);
	}

	quadVertices.Load([
		pos,
		pos + vec2(size.x, size.y),
		pos + vec2(0, size.y),

		pos,
		pos + vec2(size.x, 0),
		pos + vec2(size.x, size.y),
	]);
	
	RenderText();

	glBindTexture(GL_TEXTURE_2D, 0);
	glDisable(GL_TEXTURE_2D);
	glEnable(GL_DEPTH_TEST);
}

private void RenderText(){
	auto sh = GetActiveShader();

	textShader.Use();
	textShader.SetUniform("fonttex", ftex);

	posAttr.Enable();
	uvAttr.Enable();

	quadVertices.Bind(posAttr);
	quadUVs.Bind(uvAttr);

	glDrawArrays(GL_TRIANGLES, 0, quadVertices.length);

	quadVertices.Unbind();
	quadUVs.Unbind();

	posAttr.Disable();
	uvAttr.Disable();

	sh.Use();
}