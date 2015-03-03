module main;

import std.stdio;
import testing.classes;
import testing.funcs;

void set(Thing t, int x){
	t.x = x;
}

int get(Thing t){
	return t.x;
}

void times(alias func, T)(T x){
	import std.traits : arity;

	foreach(i; 0..x){
		static if(arity!func == 1){
			func(i);
		}else static if(arity!func == 0){
			func();
		}
	}
}

void main(){
	writeln("Things ", fib!0);
	writeln("Things ", fib!1);
	writeln("Things ", fib!2);
	writeln("Things ", fib!3);
	writeln("Things ", fib!4);
	writeln("Things ", fib!5);
	writeln("Things ", fib!6);
	writeln("Things ", fib!7);
	writeln("Things ", fib!8);
	writeln("Things ", fib!9);
	writeln();

	scope (exit) writeln("Scope Exit");
	scope (success) writeln("Scope Success");
	scope (failure) writeln("Scope Fail");

	IThing thing = new Thing1();
	thing.S();
	thing = new Thing2();
	thing.S(); 

	auto oldthing = thing;

	thing = new Thing(3);
	thing.S();

	Thing t = cast(Thing) thing;
	Thing t2 = new Thing(4);
	t2.S();

	destroy(oldthing);

	writeln("t + t2 = ", t + t2);

	t.set(5);
	writeln("t + t2 = ", t + t2);

	writeln(t.get);

	simdTest();

	int asmTest(int x){
		asm {
			mov EAX, x;
			imul EAX, 2;
		}
	}

	writeln("asmTest: ", asmTest(3));

	7.times!( { writeln("lel"); } );
	7.times!( (int x){writeln(x);} );
	7.times!( (int x) => writeln(x) );
}