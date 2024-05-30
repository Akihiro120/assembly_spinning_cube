extern sinf
extern cosf
extern tanf
extern printf

%ifndef MATRICES
%define MATRICES

%include "math.asm"
%include "glfw.asm"
%include "matrix_multiply.asm"

section .data
	perspective_matrix:
		dd 1.0, 0.0, 0.0, 0.0,
		dd 0.0, 1.0, 0.0, 0.0,
		dd 0.0, 0.0, 1.0, 0.0,
		dd 0.0, 0.0, 0.0, 0.0,

	view_matrix:
		dd 1.0, 0.0, 0.0, 0.0,
		dd 0.0, 1.0, 0.0, 0.0,
		dd 0.0, 0.0, 1.0, 0.0,
		dd 0.0, 0.0, 0.0, 1.0,

	model_matrix:
		dd 1.0, 0.0, 0.0, 0.0,
		dd 0.0, 1.0, 0.0, 0.0,
		dd 0.0, 0.0, 1.0, 0.0,
		dd 0.0, 0.0, 0.0, 1.0,

	negative_one: dd -1.0

	translation_coords: dd 0.5, -0.5, 0.0
	view_translation_coords: dd 0.0, 0.0, -3.0

	; perspective
	fov: dd 45.0
	near_plane: dd 0.1
	far_plane: dd 100.0

section .text

build_perspective_matrix:
	push rbp
	mov rbp, rsp

	sub rsp, 32

	; fov to radians
	movd xmm0, dword [fov]
	call deg_to_rad
	movd [rsp], xmm0

	; aspect ratio
	mov rax, 1280
	cvtsi2ss xmm0, rax
	mov rax, 720
	cvtsi2ss xmm1, rax
	divss xmm0, xmm1
	movd [rsp + 4], xmm0

	; tan(fov / 2)
	movd xmm0, dword [rsp]
	mov rax, 2
	cvtsi2ss xmm1, rax
	divss xmm0, xmm1
	call tanf
	movd [rsp + 8], xmm0

	movd xmm0, [rsp + 4]
	movd xmm1, [rsp + 8]
	mulss xmm0, xmm1
	mov rax, 1
	cvtsi2ss xmm2, rax
	divss xmm2, xmm0
	movd [perspective_matrix + 0 + 4 * 0], xmm2

	movd xmm0, [rsp + 8]
	mov rax, 1
	cvtsi2ss xmm1, rax
	divss xmm1, xmm0
	movd [perspective_matrix + 4 + 4 * 4], xmm1

	movd xmm0, [far_plane]
	movd xmm1, [near_plane]
	movd xmm2, dword [negative_one]
	addss xmm0, xmm1
	mulss xmm0, xmm2
	movd xmm1, [far_plane]
	movd xmm2, [near_plane]
	subss xmm1, xmm2
	divss xmm0, xmm1
	movd [perspective_matrix + 8 + 4 * 8], xmm0

	movd xmm0, dword [negative_one]
	movd [perspective_matrix + 12 + 4 * 8], xmm0

	mov rax, 2
	cvtsi2ss xmm0, rax
	movd xmm1, [far_plane]
	movd xmm2, [near_plane]
	movd xmm3, [negative_one]
	mulss xmm0, xmm1
	mulss xmm0, xmm2
	mulss xmm0, xmm3
	movd xmm1, [far_plane]
	movd xmm2, [near_plane]
	subss xmm1, xmm2
	divss xmm0, xmm1
	movd [perspective_matrix + 8 + 4 * 12], xmm0

	add rsp, 32

	mov rsp, rbp
	pop rbp

	ret

build_view_matrix:
	push rbp
	mov rbp, rsp

	sub rsp, 32

	; identity
	lea rcx, [view_matrix]
	call make_identity

	; translate
	movd xmm0, dword [view_translation_coords]
	movd xmm1, dword [view_translation_coords + 4]
	movd xmm2, dword [view_translation_coords + 8]
	lea rcx, [view_matrix]
	call translate_matrix

	add rsp, 32

	mov rsp, rbp
	pop rbp
	
	ret

; xmm0: Rad(angle)
rotate_matrix_z:
	push rbp
	mov rbp, rsp

	movss xmm3, xmm0

	sub rsp, 256
	; identity matrix
	movups xmm0, [identity_matrix]
	movups [rsp], xmm0
	movups xmm0, [identity_matrix + 16]
	movups [rsp + 16], xmm0
	movups xmm0, [identity_matrix + 32]
	movups [rsp + 32], xmm0
	movups xmm0, [identity_matrix + 48]
	movups [rsp + 48], xmm0

	; m0
	movss xmm0, xmm3
	call cosf
	movd [rsp], xmm0
	; m1
	movss xmm0, xmm3
	call sinf
	movd xmm1, dword [negative_one]	
	mulss xmm0, xmm1
	movd [rsp + 4], xmm0
	; m4
	movss xmm0, xmm3
	call sinf
	movd [rsp + 16], xmm0
	; m5
	movss xmm0, xmm3
	call cosf
	movd [rsp + 20], xmm0

	; multiply matrix
	; model_matrix * rotation
	lea rcx, [model_matrix]
	lea rdx, [rsp]
	call multiply_matrices
	
	add rsp, 256

	mov rsp, rbp
	pop rbp

	ret

; xmm0: rad(angle)
rotate_matrix_x:
	push rbp
	mov rbp, rsp

	; move value into xmm3
	movss xmm3, xmm0

	sub rsp, 128

	; identity matrix
	movups xmm0, [identity_matrix]
	movups [rsp], xmm0
	movups xmm0, [identity_matrix + 16]
	movups [rsp + 16], xmm0
	movups xmm0, [identity_matrix + 32]
	movups [rsp + 32], xmm0
	movups xmm0, [identity_matrix + 48]
	movups [rsp + 48], xmm0

	; rotation matrix
	movss xmm0, xmm3
	call cosf
	movd [rsp + 20], xmm0

	movss xmm0, xmm3
	call sinf
	movd xmm1, [negative_one]
	mulss xmm0, xmm1
	movd [rsp + 24], xmm0

	movss xmm0, xmm3
	call sinf
	movd [rsp + 36], xmm0

	movss xmm0, xmm3
	call cosf
	movd [rsp + 40], xmm0

	; multiply
	lea rcx, [model_matrix]
	lea rdx, [rsp]
	call multiply_matrices

	add rsp, 128

	mov rsp, rbp
	pop rbp

	ret

; xmm0: x
; xmm1: y
; xmm2: z
; rcx: matrix
translate_matrix:	
	push rbp
	mov rbp, rsp

	movss xmm3, xmm0
	movss xmm4, xmm1
	movss xmm5, xmm2

	sub rsp, 128

	; identity matrix
	movups xmm0, [identity_matrix]
	movups [rsp], xmm0
	movups xmm0, [identity_matrix + 16]
	movups [rsp + 16], xmm0
	movups xmm0, [identity_matrix + 32]
	movups [rsp + 32], xmm0
	movups xmm0, [identity_matrix + 48]
	movups [rsp + 48], xmm0

	; translate
	movd [rsp + 12], xmm3
	movd [rsp + 28], xmm4
	movd [rsp + 44], xmm5

	; multiply
	lea rcx, [rcx]
	lea rdx, [rsp]
	call multiply_matrices

	add rsp, 128

	mov rsp, rbp
	pop rbp

	ret

; rcx: address of matrix
make_identity:
	push rbp
	mov rbp, rsp

	movups xmm0, [identity_matrix]
	movups [rcx], xmm0
	movups xmm0, [identity_matrix + 16]
	movups [rcx + 16], xmm0
	movups xmm0, [identity_matrix + 32]
	movups [rcx + 32], xmm0
	movups xmm0, [identity_matrix + 48]
	movups [rcx + 48], xmm0

	mov rsp, rbp
	pop rbp

	ret

build_model_matrix:
	push rbp
	mov rbp, rsp

	; create an empty identity matrix
	lea rcx, [model_matrix]
	call make_identity	

	mov rax, 60
	cvtsi2ss xmm1, rax

	; rotate the matrix on x axis
	call glfwGetTime
	cvtsd2ss xmm0, xmm0
	mulss xmm0, xmm1
	call deg_to_rad
	call rotate_matrix_x	

	mov rax, 60
	cvtsi2ss xmm1, rax
	
	; rotate the matrix on z axis
	call glfwGetTime
	cvtsd2ss xmm0, xmm0
	mulss xmm0, xmm1
	call deg_to_rad
	call rotate_matrix_z

	mov rsp, rbp
	pop rbp

	ret

%endif
