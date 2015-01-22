module input;

import std.stdio;
import std.math;
import std.string;
import cruft : WarpToCenter;
import gl;

private {
	bool[int] keys;
	auto dlt = vec2(0,0);

	SDL_GameController* joy = null;

	float[Axis] axis;
	bool[Button] buttons;

	bool doCheckMouseMove = true;
}

enum Button {
	A = SDL_CONTROLLER_BUTTON_A, 
	B = SDL_CONTROLLER_BUTTON_B, 
	X = SDL_CONTROLLER_BUTTON_X, 
	Y = SDL_CONTROLLER_BUTTON_Y,
	Back = SDL_CONTROLLER_BUTTON_BACK, 
	Guide = SDL_CONTROLLER_BUTTON_GUIDE,
	Start = SDL_CONTROLLER_BUTTON_START,
	LeftStick = SDL_CONTROLLER_BUTTON_LEFTSTICK,
	RightStick = SDL_CONTROLLER_BUTTON_RIGHTSTICK,
	LeftShoulder = SDL_CONTROLLER_BUTTON_LEFTSHOULDER,
	RightShoulder = SDL_CONTROLLER_BUTTON_RIGHTSHOULDER,
	DPadUp = SDL_CONTROLLER_BUTTON_DPAD_UP,
	DPadDown = SDL_CONTROLLER_BUTTON_DPAD_DOWN,
	DPadLeft = SDL_CONTROLLER_BUTTON_DPAD_LEFT,
	DPadRight = SDL_CONTROLLER_BUTTON_DPAD_RIGHT,
}

enum Axis {
	LeftX = SDL_CONTROLLER_AXIS_LEFTX,
	LeftY = SDL_CONTROLLER_AXIS_LEFTY,
	LeftTrigger = SDL_CONTROLLER_AXIS_TRIGGERLEFT,
	RightX = SDL_CONTROLLER_AXIS_RIGHTX,
	RightY = SDL_CONTROLLER_AXIS_RIGHTY,
	RightTrigger = SDL_CONTROLLER_AXIS_TRIGGERRIGHT,
}

void InitInput(){
	if(SDL_NumJoysticks() > 0){
		writeln("Joystick available");
		joy = SDL_GameControllerOpen(0);

		if(joy){
			writeln("Joystick open");
		}
	}
}

void CheckInputEvents(SDL_Event* e){
	dlt = vec2(0,0);

	while(SDL_PollEvent(e)){
		switch(e.type){
			case SDL_KEYDOWN:
				keys[e.key.keysym.sym] = true;
				break;

			case SDL_KEYUP:
				keys[e.key.keysym.sym] = false;
				break;

			case SDL_MOUSEMOTION:{
				if(doCheckMouseMove){
					dlt = vec2(e.motion.x, e.motion.y);
					dlt.x = ( dlt.x / 800f) * 2f - 1f;
					dlt.y = (-dlt.y / 600f) * 2f + 1f;
					WarpToCenter();
				}
				
				doCheckMouseMove = !doCheckMouseMove;
				break;
			}

			case SDL_CONTROLLERAXISMOTION:{
				auto j = e.caxis;
				auto ax = cast(Axis) j.axis;

				if(abs(cast(int) j.value) < 5000) {
					axis[ax] = 0f;
				}else{
					axis[ax] = (cast(double) j.value + 0.5) / 32767.5;
				}

				if(ax == Axis.LeftY){
					writeln(ax, "\t", axis[ax], "\t", j.value);
					stdout.flush();
				}

				break;
			}

			case SDL_CONTROLLERBUTTONDOWN:
			case SDL_CONTROLLERBUTTONUP:{
				auto j = e.cbutton;
				buttons[cast(Button) j.button] = j.state == SDL_PRESSED;
				writeln(cast(Button) j.button);
				stdout.flush();
				break;
			}

			default:
				break;
		}
	}
}

bool JoystickActive(){
	return cast(bool) joy;
}

bool GetKey(int k){
	return keys.get(k, false);
}

vec2 GetMouseDelta(){
	return dlt;
}

float GetAxis(Axis a){
	return axis.get(a, 0f);
}

bool GetButton(Button b){
	return buttons.get(b, false);
}