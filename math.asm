extern printf

%ifndef MATH
%define MATH

section .data
	PI: dd 3.14159265358979323846

section .text

; xmm0: angle
; xmm0: rad(angle)
deg_to_rad:
	push rbp
	mov rbp, rsp

	; calculate the degrees to radians formula
	; RAD(angle) = DEG(angle) * PI / 180

	movd xmm1, dword [PI] ; move PI into xmm0
	mov eax, 180
	cvtsi2ss xmm2, eax	; move 180.0 into xmm1

	divss xmm1, xmm2 ; PI / 180
	mulss xmm0, xmm1 ; angle * PI / 180

	mov rsp, rbp
	pop rbp

	ret

%endif
