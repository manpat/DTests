	global main
	extern printf

section .data
	fmt db "things %d %f %f", 0x0a, 0
	num dd 10
	fnum dd 1000.0
	dnum dq 1234.5678
	str1 db "blah blah blah %d * %d = %d", 0x0a, 0
	str2 db "func returned %d", 0x0a, 0

section .text

main:
	push ebp
	mov ebp, esp
	; stack frame init

.loop:
	push dword [dnum + 4]
	push dword [dnum]
	sub esp, byte 8 ; printf only accepts doubles
	fld dword [fnum] ; so floats have to be casted
	fstp qword [esp] ; on the fpu
	push dword [num]
	push fmt
	call printf
	add esp, 24 ; cleanup after parameters
	dec dword [num]
	cmp dword [num], 0
	jnz .loop
	push dword 4
	push dword 111
	call func
	add esp, 8 ; cleanup after parameters
	push eax
	push str2
	call printf
	add esp, 8 ; cleanup after parameters
	mov eax, 0 ; return 0
	; stack frame cleanup
	leave
	ret

func:
	push ebp
	mov ebp, esp
	sub esp, 4
	; stack frame init
	mov ecx, [ebp + 8] ; arg1 -> ecx
	imul ecx, [ebp + 12] ; ecx *= arg2
	mov dword [ebp - 4], ecx ; local = ecx
	push dword [ebp - 4]
	push dword [ebp + 12]
	push dword [ebp + 8]
	push str1
	call printf
	add esp, 16 ; cleanup after parameters
	mov eax, [ebp - 4] ; return local
	; stack frame cleanup
	add esp, 4
	leave
	ret
