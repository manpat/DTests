	.file	"output.bc"
	.text
	.globl	main
	.align	16, 0x90
	.type	main,@function
main:                                   # @main
.Ltmp1:
	.cfi_startproc
# BB#0:                                 # %entry
	pushq	%rax
.Ltmp2:
	.cfi_def_cfa_offset 16
	movl	$__unnamed_1, %edi
	xorb	%al, %al
	callq	printf
	xorl	%eax, %eax
	popq	%rdx
	ret
.Ltmp3:
	.size	main, .Ltmp3-main
.Ltmp4:
	.cfi_endproc
.Leh_func_end0:

	.type	__unnamed_1,@object     # @0
	.section	.rodata.str1.1,"aMS",@progbits,1
__unnamed_1:
	.asciz	 "Lol\n"
	.size	__unnamed_1, 5


	.section	".note.GNU-stack","",@progbits
