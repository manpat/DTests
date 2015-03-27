module audio.manager;

import audio.common;
import std.math;

class AudioManager {
	__gshared AudioManager main = null; 
	private Generator[] generators = [];
	private double[] generatedValues = []; // NaN if not generated
	private double dt = 0f;

	this(){
		main = this;
	}

	static void Add(Generator g){
		g.id = main.generators.length;
		main.generators ~= g;
		main.generatedValues ~= double.nan;
		Log(main.generatedValues.length);
	}

	static double GetValue(ulong id){
		if(id >= main.generatedValues.length) {
			Log("AudioManager out of range");
			throw new Exception("AudioManager out of range");
		}

		if(main.generatedValues[id].isNaN) 
			main.generatedValues[id] = main.generators[id].Generate(main.dt);

		return main.generatedValues[id];
	}

	static void Prepare(double _dt){
		main.generatedValues[] = double.nan;
		main.dt = _dt;
	}
}