module hud.stuff;

import shader;
import gl;
import hud;

enum GUIAnchor {
	Left,
	Center,
	Right,
}

private {
	Shader simpleShader;
	Attribute posAttr;
}

void EnableHUDAttributes(){
	simpleShader.Use();
	SetHUDPos(vec2(0,0));
	SetHUDCol(vec4(1,1,1,1));
	posAttr.Enable();
}

void SetHUDPos(vec2 pos){
	simpleShader.SetUniform("transform", pos);
}

void SetHUDCol(vec4 col){
	simpleShader.SetUniform("tint", col);
}

Attribute GetHUDPosAttr(){
	return posAttr;
}

void DisableHUDAttributes(){
	posAttr.Disable();
}

void InitHUD(){
	new Shader("shaders/text.glsl", "text");
	simpleShader = new Shader("shaders/hud.glsl", "hud");

	posAttr = simpleShader.GetAttribute("pos");

	InitHUDText();
}