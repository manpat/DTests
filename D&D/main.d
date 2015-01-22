module main;

import std.conv;
import std.stdio;
import std.random;
import std.string;

void main(){
	uint faces = 1;

	while(faces != 0){
		auto str = strip(readln());

		try{
			faces = parse!uint(str);

		}catch(Exception e){
			writeln("You fucked it\t", e.msg);
			faces = 1;
		}

		writeln(roll(faces));
	}
}

uint roll(uint numfaces = 6){
	return uniform(1, numfaces+1);
}