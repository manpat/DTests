global main
extern printf

; uninitialised space / static data
section .bss

; constants, literals. writable
; db - declare byte (8-bit) 1B
; dw - declare word (16-bit) 2B
; dd - declare dword (32-bit) 4B
; dq - declare quad (64-bit) 8B
; dt - declare ten bytes (80-bit) 10B

section .data
	nl equ 0xa

	nfloat dd 12.0
	ndouble dq 12.5
	msg	db "Things", 0
	fmt	db "%s and more things %.2f + %.2f = %.2f", nl, nl, 0

; code
section .text
main:
	; this sets up the stack frame
	push ebp
	mov ebp, esp

	sub esp, 16 ; alloc 24 bytes of stack

	fld dword [nfloat] ; load float
	fst qword [esp] ; cast to double and store in stack
	fld qword [ndouble] ; load double
	
	faddp
	fstp qword [esp + 8]

	push dword [ndouble + 4]
	push dword [ndouble]
	push msg
	push fmt

	call printf

	; add esp, 32 ; free up stack

	; destroy stack frame
	leave

	mov eax, 0 ; return value (0)
	ret