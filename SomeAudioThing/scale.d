module scale;

import std.math;

double ntof(int note){
	immutable base = pow(2.0, 1.0/12.0);
	return 110.0 * pow(base, (cast(double) note + 3.0));
}

class Scale {
	private {
		static int[7] semitones = [0, 2, 4, 5, 7, 9, 11];
		double[7] freqs;
	}

	this(){
		foreach(i; 0..semitones.length){
			freqs[i] = ntof(semitones[i]);
		}
	}

	double GetNote(int degree, int octave = 0){
		auto sl = cast(int) semitones.length;

		float coctave = 0;
		if(degree > 0){
			coctave += degree/sl;
		}else{
			coctave -= (sl-degree-1)/sl;
		}

		degree -= coctave*sl;
		octave += coctave;

		assert(degree >= 0 && degree < sl);
		auto freq = freqs[degree];

		if(octave != 0) freq *= pow(2.0, octave);

		return freq;
	}
}