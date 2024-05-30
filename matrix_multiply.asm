%ifndef MATRIX_MULTIPLY
%define MATRIX_MULTIPLY

section .data
	identity_matrix:
		dd 1.0, 0.0, 0.0, 0.0,
		dd 0.0, 1.0, 0.0, 0.0,
		dd 0.0, 0.0, 1.0, 0.0,
		dd 0.0, 0.0, 0.0, 1.0,

section .text

; 1: address of m1
; 2: address of m2
; 3: address of target
; 4: index 1
; 5: index 2
%macro matrix_multiply_element 5
	
	mov rsi, %5
	mov rdi, %4
	movd xmm0, [%1 + rdi + 4 * 0]
	movd xmm1, [%2 + 0   + 4 * rsi]
	mulss xmm0, xmm1
	movd xmm1, [%1 + rdi + 4 * 4]
	movd xmm2, [%2 + 4   + 4 * rsi]
	mulss xmm1, xmm2
	movd xmm2, [%1 + rdi + 4 * 8]
	movd xmm3, [%2 + 8   + 4 * rsi]
	mulss xmm2, xmm3
	movd xmm3, [%1 + rdi + 4 * 12]
	movd xmm4, [%2 + 12  + 4 * rsi]
	mulss xmm3, xmm4
	addss xmm0, xmm1
	addss xmm0, xmm2
	addss xmm0, xmm3 
	movd [%3], xmm0

%endmacro

; rcx: address of first matrix
; rdx: address of second matrix
multiply_matrices:
	push rbp
	mov rbp, rsp

	sub rsp, 128

	; load base matrix to use
	movups xmm0, [identity_matrix]
	movups [rsp], xmm0
	movups xmm0, [identity_matrix + 16]
	movups [rsp + 16], xmm0
	movups xmm0, [identity_matrix + 32]
	movups [rsp + 32], xmm0
	movups xmm0, [identity_matrix + 48]
	movups [rsp + 48], xmm0

	; multiply the matrices: index formula: j * i * 4
	lea r8, [rsp]
	matrix_multiply_element rcx, rdx, r8, dword 0, dword 0
	lea r8, [rsp + 4]
	matrix_multiply_element rcx, rdx, r8, dword 0, dword 4
	lea r8, [rsp + 8]
	matrix_multiply_element rcx, rdx, r8, dword 0, dword 8
	lea r8, [rsp + 12]
	matrix_multiply_element rcx, rdx, r8, dword 0, dword 12
	lea r8, [rsp + 16]
	matrix_multiply_element rcx, rdx, r8, dword 4, dword 0
	lea r8, [rsp + 20]
	matrix_multiply_element rcx, rdx, r8, dword 4, dword 4
	lea r8, [rsp + 24]
	matrix_multiply_element rcx, rdx, r8, dword 4, dword 8
	lea r8, [rsp + 28]
	matrix_multiply_element rcx, rdx, r8, dword 4, dword 12
	lea r8, [rsp + 32]
	matrix_multiply_element rcx, rdx, r8, dword 8, dword 0
	lea r8, [rsp + 36]
	matrix_multiply_element rcx, rdx, r8, dword 8, dword 4
	lea r8, [rsp + 40]
	matrix_multiply_element rcx, rdx, r8, dword 8, dword 8
	lea r8, [rsp + 44]
	matrix_multiply_element rcx, rdx, r8, dword 8, dword 12
	lea r8, [rsp + 48]
	matrix_multiply_element rcx, rdx, r8, dword 12, dword 0
	lea r8, [rsp + 52]
	matrix_multiply_element rcx, rdx, r8, dword 12, dword 4
	lea r8, [rsp + 56]
	matrix_multiply_element rcx, rdx, r8, dword 12, dword 8
	lea r8, [rsp + 60]
	matrix_multiply_element rcx, rdx, r8, dword 12, dword 12

	; move the base matrix into the rcx register values for the matrix
	movups xmm0, [rsp]
	movups [rcx], xmm0
	movups xmm0, [rsp + 16]
	movups [rcx + 16], xmm0
	movups xmm0, [rsp + 32]
	movups [rcx + 32], xmm0
	movups xmm0, [rsp + 48]
	movups [rcx + 48], xmm0

	add rsp, 128

	mov rsp, rbp
	pop rbp

	ret

%endif
