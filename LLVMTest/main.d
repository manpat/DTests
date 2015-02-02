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

	auto floatType = typeTable["float"];
	auto doubleType = typeTable["double"];
	auto i32Type = typeTable["i32"];
	auto i8pType = typeTable["i8*"];
	auto voidType = typeTable["void"];

	auto llprintf = LLVMAddFunction(context.mod, "printf", LLVMFunctionType(i32Type, [i8pType].ptr, 1, 1));
	LLVMSetLinkage(llprintf, LLVMLinkage.External);
	symbolTable["printf"] = llprintf;

	auto func = LLVMAddFunction(context.mod, "func", LLVMFunctionType(floatType, [floatType].ptr, 1, 0));
	LLVMSetFunctionCallConv(func, LLVMCallConv.C);
	auto bb = LLVMAppendBasicBlock(func, "entry");
	symbolTable["func"] = func;

	auto p0 = LLVMGetParam(func, 0);
	auto c = LLVMConstReal(floatType, 10.0);

	LLVMPositionBuilderAtEnd(context.builder, bb);
	auto ret = LLVMBuildFAdd(context.builder, p0, c, "addtmp".toStringz);
	LLVMBuildCall(context.builder, llprintf, 
		[LLVMBuildGlobalStringPtr(context.builder, "\nTesting %f\n".toStringz, "thing".toStringz), 
		LLVMBuildFPCast(context.builder, ret, doubleType, "printcast".toStringz)].ptr, 
		2, "".toStringz);

	LLVMBuildRet(context.builder, ret);

	auto mainNode = new FunctionNode("main", "i32", [], false);
	mainNode.SetBody(cast(Node[]) [
		new CallNode("printf", cast(Node[]) [
			new ConstNode!string("i8*", "Hello %f\n"),
			new CastNode(
				new CallNode("func", cast(Node[]) [new ConstNode!float("float", 5f)])
				, "double")
			]),
		new ReturnNode(new ConstNode!int("i32", 0)),
	]);

	mainNode.GenerateCode(context);

	//auto mainf = LLVMAddFunction(context.mod, "main", LLVMFunctionType(i32Type, [voidType].ptr, 0, 0));
	//auto mainbb = LLVMAppendBasicBlock(mainf, "entry");
	//LLVMPositionBuilderAtEnd(context.builder, mainbb);
	//auto fret = LLVMBuildCall(context.builder, func, [LLVMConstReal(floatType, 5.0)].ptr, 1u, "ret".toStringz);
	//LLVMBuildCall(context.builder, llprintf, 
	//	[LLVMBuildGlobalStringPtr(context.builder, "Inmain %f\n".toStringz, "thing".toStringz), 
	//	LLVMBuildFPCast(context.builder, fret, doubleType, "printcast".toStringz)].ptr, 
	//	2, "".toStringz);
	//LLVMBuildRet(context.builder, LLVMConstInt(i32Type, 0, 0));

	LLVMDumpModule(context.mod);
	LLVMWriteBitcodeToFile(context.mod, "output.bc\0".dup.ptr);

	//auto res = LLVMRunFunction(engine, func, 1, [LLVMCreateGenericValueOfFloat(floatType, 5.0)].ptr);
	//writeln(LLVMGenericValueToFloat(floatType, res));
}