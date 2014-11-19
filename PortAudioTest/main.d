module main;

import deimos.portaudio;
import std.conv, std.stdio, std.math;

enum SAMPLERATE = 44100;
enum FRAMELENGTH = 2.0/SAMPLERATE;
enum NUMSECONDS = 4;

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
	auto phase = cast(Data*)userData;
	auto pout = cast(float*)outputBuffer;

	enum vol = 0.2f;
	enum spread = 3f;

	foreach(i; 0 .. framesPerBuffer) {
		auto freq = phase.freqs[cast(ulong)floor(fmod(phase.t, phase.freqs.length))];

		*pout++ = vol * sin(phase.left);
		*pout++ = vol * sin(phase.right);

		phase.left  += FRAMELENGTH*(freq - sin(phase.t)*spread + sin(phase.t*32f)*8f);
		phase.right += FRAMELENGTH*(freq + sin(phase.t)*spread + sin(phase.t*32f)*8f);
		phase.t += FRAMELENGTH;
	}
	return 0;
}

void main(){
	PaStream* stream;
	Data data;
	data.freqs = [80f, 110f, 220f, 440f];

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