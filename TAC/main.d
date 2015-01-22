module main;

import std.stdio;
import tac;
import ast;

void main(){
	try{
		auto tree = ConstructTree();
		auto chunk = ParseAST(tree);

		foreach(inst; chunk.list){
			writeln(inst.GenerateText());
		}

	}catch(Exception e){
		writeln(e.msg);
	}
}

Node ConstructTree(){
	auto op1 = new Operation(
		new Literal("1".dup),
		new Literal("2".dup),
		"*".dup
	);
	auto op2 = new Operation(
		new Literal("3".dup),
		new Literal("4".dup),
		"*".dup
	);

	return new Assignment(
		new Identifier("a".dup),
		new Operation(
			op1,
			op2,
			"+".dup
		) 
	);
}