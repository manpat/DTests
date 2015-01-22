module keyboard;

import generators : Voice;
import eventsystem;
import main : Data;
import scale;
import gl;

class Keyboard {
	private Scale scale; 
	private Data* data;
	private Voice[uint] playing;

	this(Data* _data){
		data = _data;
		scale = new Scale;
		HookEventHandler(&Handler);
	}

	private Voice GetNextVoice(){
		for(uint i = 0; i < data.voices.length; i++){
			auto ii = (i+data.i)%data.voices.length;
			auto v = data.voices[ii];
			if(!v.IsPlaying()) {
				data.i = cast(uint) ii + 1;
				return v;
			}
		}

		return null;
	}

	private void Handler(SDL_Event* e){
		if(e.type == SDL_KEYDOWN && e.key.repeat == 0){
			switch(e.key.keysym.sym){
				case SDLK_a: Play(SDLK_a, 1); break;
				case SDLK_s: Play(SDLK_s, 2); break;
				case SDLK_d: Play(SDLK_d, 3); break;
				case SDLK_f: Play(SDLK_f, 4); break;
				case SDLK_g: Play(SDLK_g, 5); break;
				case SDLK_h: Play(SDLK_h, 6); break;
				case SDLK_j: Play(SDLK_j, 7); break;
				case SDLK_k: Play(SDLK_k, 8); break;
				case SDLK_l: Play(SDLK_l, 9); break;

				case SDLK_q: Play(SDLK_q, 8 ); break;
				case SDLK_w: Play(SDLK_w, 9 ); break;
				case SDLK_e: Play(SDLK_e, 10); break;
				case SDLK_r: Play(SDLK_r, 11); break;
				case SDLK_t: Play(SDLK_t, 12); break;
				case SDLK_y: Play(SDLK_y, 13); break;
				case SDLK_u: Play(SDLK_u, 14); break;
				case SDLK_i: Play(SDLK_i, 15); break;
				case SDLK_o: Play(SDLK_o, 16); break;
				case SDLK_p: Play(SDLK_p, 17); break;

				case SDLK_z: Play(SDLK_z, 1,-1); break;
				case SDLK_x: Play(SDLK_x, 2,-1); break;
				case SDLK_c: Play(SDLK_c, 3,-1); break;
				case SDLK_v: Play(SDLK_v, 4,-1); break;
				case SDLK_b: Play(SDLK_b, 5,-1); break;
				case SDLK_n: Play(SDLK_n, 6,-1); break;
				case SDLK_m: Play(SDLK_m, 7,-1); break;
				case SDLK_COMMA: Play(SDLK_COMMA, 8,-1); break;
				case SDLK_PERIOD: Play(SDLK_PERIOD, 9,-1); break;
				default: break;
			}
		}else if(e.type == SDL_KEYUP){
			Stop(e.key.keysym.sym);
		}
	}

	private void Play(uint key, int degree, int octave = 0){
		auto v = GetNextVoice();
		if(!v) return;

		v.Play(scale.GetNote(degree-1, octave));
		playing[key] = v;
	}

	private void Stop(uint key){
		auto v = playing.get(key, null);
		if(v) v.Stop();
	}
}