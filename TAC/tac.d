module tac;

import std.stdio;
import std.conv;
import ast;

alias tos = to!(char[]);

interface TACAddress {
	char[] GenerateText();
}

interface TACInstruction {
	char[] GenerateText();
}

//////////////////////////////////////////////

class TACTemporary : TACAddress {
	static ulong count = 0;
	const ulong id;

	this(){
		id = count++;
	}

	char[] GenerateText(){
		return "t" ~ tos(id);
	}
}

class TACName : TACAddress {
	char[] name;

	this(T)(T _name){
		name = tos(_name);
	}

	char[] GenerateText(){
		return name; // look up or something
	}
}

// Not an address, shut up
class TACLiteral : TACAddress {
	char[] text;

	this(T)(T _text){
		text = tos(_text);
	}

	char[] GenerateText(){
		return text;
	}
}

class TACLabel : TACAddress {
	static ulong count = 0;
	const ulong id;

	this(){
		id = count++;
	}

	char[] GenerateText() {
		return "L" ~ tos(id);
	}
}

//////////////////////////////////////////////

class TACAssignment : TACInstruction {
	TACAddress target;
	TACAddress source;

	this(TACAddress _target, TACAddress _source){
		target = _target;
		source = _source;
	}

	char[] GenerateText(){
		return target.GenerateText() ~ " = " ~ source.GenerateText();
	}
}

class TACOperation : TACInstruction {
	TACAddress target;
	TACAddress left;
	TACAddress right;
	char[] op;

	this(T)(TACAddress _target, TACAddress _left, TACAddress _right, T _op){
		target = _target;
		left = _left;
		right = _right;
		op = tos(_op);
	}

	char[] GenerateText(){
		return target.GenerateText() ~ " = " ~ left.GenerateText() ~ " " ~ op ~ " " ~ right.GenerateText();
	}
}

///////////////////////////////////////////////////////////////

struct TACCodeChunk {
	TACInstruction[] list;
	TACAddress result;
}

TACCodeChunk ParseAST(Node root){
	TACCodeChunk chunk;

	switch(root.type){
		case Type.Assignment:{
			auto left = ParseAST(root.first);
			auto right = ParseAST(root.second);
			chunk.list = right.list;

			auto ass = new TACAssignment(
				left.result,
				right.result
			);

			chunk.list ~= ass;
			chunk.result = right.result;

			break;
		}

		case Type.Operation: {
			auto n = cast(Operation) root;
			auto left = ParseAST(n.first);
			auto right = ParseAST(n.second);
			auto result = new TACTemporary();

			chunk.list ~= left.list;
			chunk.list ~= right.list;
			chunk.list ~= new TACOperation(
				result, 
				left.result,
				right.result,
				n.op
			);

			chunk.result = result;

			break;
		}

		case Type.Literal: {
			auto n = cast(Literal) root;
			chunk.result = new TACLiteral(n.text);
			
			break;
		}
		case Type.Identifier: {
			auto n = cast(Identifier) root;
			chunk.result = new TACName(n.name);
			
			break;
		}

		default: 
			throw new Exception("Unimplemented: " ~ to!string(root.type));
	}

	return chunk;
}