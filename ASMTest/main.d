module main;

import std.stdio, std.file;
import std.conv;
import std.process;

void main(string[] args){
	try {
		Compile(args[1]);
	} catch(Exception e) {
		writeln(e.msg);
	}
}

char[] buffer;

void Compile(string fname){
	WriteLine(`global main`);
	WriteLine(`extern printf`);

	StartSection(".data");
	auto fmt = DeclareData(`fmt`, Width.Byte, Type.String, `"things %d %f %f", 0x0a, 0`.dup);
	auto num = DeclareData(`num`, Width.DWord, Type.Int, `10`.dup);
	auto fnum= DeclareData(`fnum`, Width.DWord, Type.Float, `1000.0`.dup);
	auto dnum= DeclareData(`dnum`, Width.QWord, Type.Float, `1234.5678`.dup);
	auto str = DeclareData(`str1`, Width.Byte, Type.String, `"blah blah blah %d * %d = %d", 0x0a, 0`.dup);
	auto str2 = DeclareData(`str2`, Width.Byte, Type.String, `"func returned %d", 0x0a, 0`.dup);

	StartSection(".text");
	Label("main");
	EnterStackFrame();

	Label(".loop");
	Call("printf", fmt, num, fnum, dnum);

	WriteLine(`dec ` ~ num.Value());
	WriteLine(`cmp ` ~ num.Value() ~ `, 0`);
	WriteLine(`jnz .loop`);

	Call("func", 111, 4);
	Call("printf", str2, `eax`);

	WriteLine(`mov eax, 0 ; return 0`);

	LeaveStackFrameAndReturn();

	// Func ////////////////////
	Label("func");
	EnterStackFrame(4);

	WriteLine(`mov ecx, `~Arg(0)~` ; arg1 -> ecx`); 
	WriteLine(`imul ecx, `~Arg(1)~` ; ecx *= arg2`);
	WriteLine(`mov dword `~Local(0)~`, ecx ; local = ecx`);

	Call("printf", str, `dword `~Arg(0), `dword `~Arg(1), `dword `~Local(0));

	WriteLine(`mov eax, `~Local(0)~` ; return local`); 
	LeaveStackFrameAndReturn(4);

	std.file.write(fname~".s", buffer);

	auto asmstage = execute([`nasm`, `-f`, `elf`, fname~`.s`]);
	if(asmstage.status != 0){
		throw new Exception("ASM stage failed: " ~ asmstage.output);
	}

	auto linkstage = execute([`gcc`, `-m32`, fname~`.o`, `-o`, fname~`.build`]);
	if(linkstage.status != 0){
		throw new Exception("Link stage failed: " ~ linkstage.output);
	}

	execute(["rm", fname~".o"]);
}

void StartSection(string sec){
	buffer ~= "\nsection "~sec~"\n";
}

void WriteLine(T)(T l){
	buffer ~= "\t" ~ l ~ "\n";
}

void Label(string l){
	buffer ~= "\n" ~ l ~ ":\n";
}

void EnterStackFrame(uint size = 0){
	WriteLine(`push ebp`);
	WriteLine(`mov ebp, esp`);
	if(size > 0) WriteLine(`sub esp, ` ~ to!string(size));
	WriteLine("; stack frame init");
}

void LeaveStackFrameAndReturn(uint size = 0){
	WriteLine("; stack frame cleanup");
	if(size > 0) WriteLine(`add esp, ` ~ to!string(size));
	WriteLine(`leave`);
	WriteLine(`ret`);
}

string Arg(uint i){
	return "[ebp + " ~ to!string(i*4 + 8) ~ "]";
}

string Local(uint i){
	return "[ebp - " ~ to!string((i+1)*4) ~ "]";
}

void Call(T...)(string func, T args){
	uint pushed = 0;
	foreach_reverse(a; args){
		static if(is(typeof(a) : DeclareData)){
			pushed += a.WritePush();

		}else static if(is(typeof(a) : string)){
			WriteLine(`push ` ~ a);
			pushed += 4; // big assumption

		}else static if(is(typeof(a) : int)){
			WriteLine(`push dword ` ~ to!string(a));
			pushed += 4; // big assumption
		}else{
			static assert(0, "Fuck");
		}
	}

	WriteLine(`call ` ~ func);
	WriteLine(`add esp, ` ~ to!string(pushed) ~ ` ; cleanup after parameters`);
}

enum Width {
	Byte, Word, 
	DWord, QWord, TWord
}

enum Type {
	Byte,
	String,
	Int,
	Float
}

struct DeclareData {
	string name;
	Width width;
	Type type;

	union {
		char[] byteArray;
		//int intVal;
		//uint uintVal;
		//float floatVal;
		//double doubleVal;
	}

	this(string _name, Width _width, Type _type, char[] _ba){
		name = _name;
		width = _width;
		type = _type;
		byteArray = _ba;

		WriteDataDecl();
	}

	this(string _name, Width _width, Type _type, size_t _size = 1){
		name = _name;
		width = _width;
		type = _type;

		WriteDataRes(_size*WidthToI(width));
	}

	string Address(){
		return name;
	}

	string Value(int off = 0){
		if(off > 0){
			return WidthToS(width) ~ " [" ~ name ~ " + " ~ to!string(off) ~ "]";
		}else if(off < 0){
			return WidthToS(width) ~ " [" ~ name ~ " - " ~ to!string(-off) ~ "]";
		}

		return WidthToS(width) ~ " [" ~ name ~ "]";
	}

	void WriteDataDecl(){
		char[] l = name.dup ~ " ";
		switch(width){
			case Width.Byte:
				l ~= "db";
				break;
			case Width.Word:
				l ~= "dw";
				break;
			case Width.DWord:
				l ~= "dd";
				break;
			case Width.QWord:
				l ~= "dq";
				break;
			case Width.TWord:
				l ~= "dt";
				break;
			default:
				l ~= "Fuck";
		}

		l ~= " " ~ byteArray;
		WriteLine(l);
	}

	void WriteDataRes(size_t size){
		char[] l = name.dup ~ " ";
		switch(width){
			case Width.Byte:
				l ~= "resb";
				break;
			case Width.Word:
				l ~= "resw";
				break;
			case Width.DWord:
				l ~= "resd";
				break;
			case Width.QWord:
				l ~= "resq";
				break;
			case Width.TWord:
				l ~= "rest";
				break;
			default:
				l ~= "Fuck";
		}

		l ~= " " ~ to!string(size);
		WriteLine(l);
	}

	uint WritePush(){
		if(type == Type.Int){
			WriteLine("push " ~ Value());
			return WidthToI(width);

		}else if(type == Type.Float){ // Always casts to double because printf
			if(width == Width.DWord){
				WriteLine(`sub esp, byte 8 ; printf only accepts doubles`);
				WriteLine("fld " ~ Value() ~ " ; so floats have to be casted");
				WriteLine("fstp qword [esp] ; on the fpu");

			}else if(width == Width.QWord){ // double
				WriteLine("push dword [" ~ name ~ " + 4]");
				WriteLine("push dword [" ~ name ~ ']');
			}else{
				throw new Exception("WritePush unimplemented width " ~ to!string(width));
			}

			return WidthToI(Width.QWord);

		}else if(type == Type.String){
			WriteLine(`push ` ~ Address());
			return WidthToI(Width.DWord); // ptr size
		}

		return 0;
	}
}

string WidthToS(Width w){
	switch(w){
		case Width.Byte:
			return "byte";
		case Width.Word:
			return "word";
		case Width.DWord:
			return "dword";
		case Width.QWord:
			return "qword";
		case Width.TWord:
			return "tword";
		default:
			return "Fuck";
	}
}
uint WidthToI(Width w){
	switch(w){
		case Width.Byte:
			return 1;
		case Width.Word:
			return 2;
		case Width.DWord:
			return 4;
		case Width.QWord:
			return 8;
		case Width.TWord:
			return 10;
		default:
			return 0;
	}
}