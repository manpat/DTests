module main;

import std.stdio;
import std.conv;
import std.string;

import llvm.Ext;
import llvm.c.Core;
import llvm.c.ExecutionEngine;
import llvm.c.Target;
import llvm.c.BitWriter;
import llvm.c.transforms.Scalar;

import node;

class Context{
	LLVMModuleRef mod;
	LLVMBuilderRef builder;
}

Context context;

void main(){
	context = new Context;
	context.mod = LLVMModuleCreateWithName("The main module");
	context.builder = LLVMCreateBuilder();

	LLVMInitializeNativeTarget();
	LLVMLinkInJIT();

	LLVMExecutionEngineRef engine;

	char* msg = null;
	if(LLVMCreateExecutionEngineForModule(&engine, context.mod, &msg) == 1){
		writeln(fromStringz(msg));
		LLVMDisposeMessage(msg);
		return;
	}

	typeTable["float"] = LLVMFloatType();
	typeTable["double"] = LLVMDoubleType();
	typeTable["i32"] = LLVMInt32Type();
	typeTable["i8*"] = LLVMPointerType(LLVMInt8Type(), 0);
	typeTable["void"] = LLVMVoidType();

	auto printNode = new ExternNode("printf", "i32", ["i8*"], true);
	printNode.GenerateCode(context);

	auto funcNode = new FunctionNode("func", "float", ["float"], false);

	Node[] funcBody;

	// ComputeOnce should never really be needed
	auto ret = new ComputeOnceNode(new FloatAddNode(
			new GetFunctionParamNode(0), 
			new ConstNode!"float"("10.0")));

	funcBody ~= new CallNode("printf", cast(Node[]) [
		new ConstNode!"i8*"("\nTesting %f %s\n"),
		new CastNode(ret, "double"),
		new ConstNode!"i8*"("lel")
	]);

	funcBody ~= new ReturnNode(ret);
	funcNode.SetBody(funcBody);
	funcNode.GenerateCode(context);

	auto mainNode = new FunctionNode("main", "i32", [], false);
	mainNode.SetBody(cast(Node[]) [
		new CallNode("printf", cast(Node[]) [
			new ConstNode!"i8*"("Hello %f\n"),
			new CastNode(
				new CallNode("func", cast(Node[]) [new ConstNode!"float"("5.0")])
				, "double")
			]),

		
		new ReturnNode(new ConstNode!"i32"("0")),
	]);

	mainNode.GenerateCode(context);

	LLVMDumpModule(context.mod);
	LLVMWriteBitcodeToFile(context.mod, "output.bc\0".dup.ptr);

	//auto res = LLVMRunFunction(engine, func, 1, [LLVMCreateGenericValueOfFloat(floatType, 5.0)].ptr);
	//writeln(LLVMGenericValueToFloat(floatType, res));
	writeln("Compilation done\n");
}