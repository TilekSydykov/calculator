section .data
	FEW_ARGS: db "Too Few Arguments", 0xA
	INVALID_OPERATOR: db "Invalid Operator", 0xA
	INVALID_OPERAND: db "Invalid Operand", 0XA
	BYTE_BUFFER: times 10 db 0
section .text
	global _start
_start:
	pop rdx
	cmp rdx, 4
	jne few_args
	add rsp, 8
	pop rsi

	cmp byte[rsi], 0x2A ; '*'
	je multiplication
	cmp byte[rsi], 0x2B ; '+'
	je addition
	cmp byte[rsi], 0x2D ; '-'
	je subtraction
	cmp byte[rsi], 0x2F ;'/'
	je division
	cmp byte[rsi], 0x25 ;'%'
	je mod
	jmp invalid_operator

addition:
	pop rsi
	call char_to_int
	mov r10, rax
	pop rsi
	call char_to_int
	add rax, r10
	jmp print_result

subtraction:
	pop rsi
	call char_to_int
	mov r10, rax
	pop rsi
	call char_to_int
	sub r10, rax
	mov rax, r10
	jmp print_result

multiplication:
	pop rsi
	call char_to_int
	mov r10, rax
	pop rsi
	call char_to_int
	mul r10
	jmp print_result

division:
	pop rsi
	call char_to_int
	mov r10, rax
	pop rsi
	call char_to_int
	mov r11, rax
	mov rax, r10
	mov rdx, 0
	div r11
	jmp print_result

mod:
	pop rsi
	call char_to_int
	mov r10, rax
	pop rsi
	call char_to_int
	mov r11, rax
    mov rax, r10
    mov rdx, 0
    div r11
    mov rax, rdx
    jmp print_result
print_result:
	call int_to_char
	mov rax, 1
	mov rdi, 1
	mov rsi, r9
	mov rdx, r11
	syscall
	jmp exit

few_args:
	mov rdi, FEW_ARGS
	call print_error

invalid_operator:
	mov rdi, INVALID_OPERATOR
	call print_error

invalid_operand:
	mov rdi, INVALID_OPERAND
	call print_error

print_error:
	push rdi
	call strlen
	mov rdi, 2
	pop rsi
	mov rdx, rax
	mov rax, 1
	syscall
	call error_exit
	ret

strlen:
	xor rax, rax
.strlen_loop:
	cmp BYTE [rdi + rax], 0xA
	je .strlen_break
	inc rax
	jmp .strlen_loop
.strlen_break:
	inc rax
	ret
char_to_int:
	xor ax, ax
	xor cx, cx
	mov bx, 10

.loop_block:

	mov cl, [rsi]
	cmp cl, byte 0
	je .return_block
	cmp cl, 0x30
	jl invalid_operand
	cmp cl, 0x39
	jg invalid_operand
	sub cl, 48
	mul bx
	add ax, cx
	inc rsi
	jmp .loop_block

.return_block:
	ret
int_to_char:
	mov rbx, 10
	mov r9, BYTE_BUFFER+10
	mov [r9], byte 0
	dec r9
	mov [r9], byte 0XA
	dec r9
	mov r11, 0x2e

.loop_block:
	mov rdx, 0
	div rbx
	cmp rax, 0
	je .return_block
	add dl, 48
	mov [r9], dl
	dec r9
	inc r11
	jmp .loop_block

.return_block:
	add dl, 48
	mov [r9], dl
	dec r9
	inc r11
	ret
error_exit:
	mov rax, 60
	mov rdi, 1
	syscall
exit:
	mov rax, 60
	mov rdi, 0
	syscall