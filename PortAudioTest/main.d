module main;

import deimos.portaudio;
import std.conv, std.stdio, std.math;

enum SAMPLERATE = 44100;
enum FRAMELENGTH = 1.0/SAMPLERATE;
enum NUMSECONDS = 4;
enum π2 = 2.0*PI; 

struct Data{
	double t = 0;
	double left = 0, right = 0;

	double[] freqs;
}

extern(C) int sawtooth(const(void)* inputBuffer, void* outputBuffer,
							 size_t framesPerBuffer,
							 const(PaStreamCallbackTimeInfo)* timeInfo,
							 PaStreamCallbackFlags statusFlags,
							 void *userData){
	auto φ = cast(Data*)userData;
	auto pout = cast(float*)outputBuffer;

	enum vol = 0.2f;

	static float λ(double φ){
		return sin(φ) + sin(φ*2f) / 2f + sin(φ/3f) / 3f + sin(φ/2f) / 2f;
	}

	foreach(i; 0 .. framesPerBuffer) {
		auto freq = φ.freqs[cast(ulong)floor(fmod(φ.t*3f, φ.freqs.length))];

		*pout++ = vol * λ(φ.left);
		*pout++ = vol * λ(φ.right);

		φ.left  += FRAMELENGTH*freq*π2;
		φ.right += FRAMELENGTH*freq*π2;
		φ.t += FRAMELENGTH;
	}
	return 0;
}

void main(){
	PaStream* stream;
	Data data;
	data.freqs = [55.0, 110.0, 220.0, 440.0, 220.0, 110.0];

	paCheck!Pa_Initialize();

	paCheck!Pa_OpenDefaultStream(&stream,
		0, 2, // IO
		paFloat32,
		SAMPLERATE,
		paFramesPerBufferUnspecified,
		&sawtooth, &data);

	paCheck!Pa_StartStream(stream);

	Pa_Sleep(NUMSECONDS * 1000);

	paCheck!Pa_StopStream(stream);
	paCheck!Pa_CloseStream(stream);
	paCheck!Pa_Terminate();

	return;
}

void paCheck(alias func, T...)(T t){
	PaError err = func(t);
	if (err != paNoError){
		stderr.writefln("error %s", to!string(Pa_GetErrorText(err)));
		throw new Exception("PaError");
	}
}