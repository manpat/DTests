	.file	"output.bc"
	.section	.rodata.cst4,"aM",@progbits,4
	.align	4
.LCPI0_0:
	.long	1092616192              # float 1.000000e+01
	.text
	.globl	func
	.align	16, 0x90
	.type	func,@function
func:                                   # @func
.Ltmp1:
	.cfi_startproc
# BB#0:                                 # %entry
	pushq	%rax
.Ltmp2:
	.cfi_def_cfa_offset 16
	addss	.LCPI0_0(%rip), %xmm0
	movss	%xmm0, 4(%rsp)          # 4-byte Spill
	cvtss2sd	%xmm0, %xmm0
	movl	$__unnamed_1, %edi
	movl	$__unnamed_2, %esi
	movb	$1, %al
	callq	printf
	movss	4(%rsp), %xmm0          # 4-byte Reload
	popq	%rax
	ret
.Ltmp3:
	.size	func, .Ltmp3-func
.Ltmp4:
	.cfi_endproc
.Leh_func_end0:

	.section	.rodata.cst4,"aM",@progbits,4
	.align	4
.LCPI1_0:
	.long	1084227584              # float 5.000000e+00
	.text
	.globl	main
	.align	16, 0x90
	.type	main,@function
main:                                   # @main
.Ltmp6:
	.cfi_startproc
# BB#0:                                 # %entry
	pushq	%rax
.Ltmp7:
	.cfi_def_cfa_offset 16
	movss	.LCPI1_0(%rip), %xmm0
	callq	func
	cvtss2sd	%xmm0, %xmm0
	movl	$__unnamed_3, %edi
	movb	$1, %al
	callq	printf
	xorl	%eax, %eax
	popq	%rdx
	ret
.Ltmp8:
	.size	main, .Ltmp8-main
.Ltmp9:
	.cfi_endproc
.Leh_func_end1:

	.type	__unnamed_1,@object     # @0
	.section	.rodata.str1.1,"aMS",@progbits,1
__unnamed_1:
	.asciz	 "\nTesting %f %s\n"
	.size	__unnamed_1, 16

	.type	__unnamed_2,@object     # @1
__unnamed_2:
	.asciz	 "lel"
	.size	__unnamed_2, 4

	.type	__unnamed_3,@object     # @2
__unnamed_3:
	.asciz	 "Hello %f\n"
	.size	__unnamed_3, 10


	.section	".note.GNU-stack","",@progbits
