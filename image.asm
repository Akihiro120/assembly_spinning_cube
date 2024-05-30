%ifndef IMAGE
%define IMAGE

%include "opengl.asm"

extern ExitProcess
extern printf
extern stbi_load
extern stbi_image_free

section .data
	texture_id: dd 0
	texture_loc: db "container.jpg", 0x00
	width: dd 0
	height: dd 0
	num_channels: dd 0
	data: db 0
	error_message: db "Failed to Load Image", 0x0A, 0x00
	success_message: db "Successfully Loaded Image", 0x0A, 0x00

section .text

load_texture:
	push rbp
	mov rbp, rsp

	sub rsp, 128

	; load image
	sub rsp, 64
	lea rcx, [texture_loc]
	lea rdx, [width]
	lea r8, [height]
	lea r9, [num_channels]
	mov [rsp + 32], dword 0
	call stbi_load
	mov [data], rax
	add rsp, 64

	mov rcx, [data]
	cmp rcx, 0
	je image_load_fail
	jmp image_load_success

image_load_fail:
	mov rcx, error_message
	mov rdx, 0
	call printf
	xor rax, rax

	add rsp, 128
	mov rsp, rbp
	pop rbp

	mov rcx, 1
	call ExitProcess

image_load_success:
	mov rcx, success_message
	mov rdx, 0
	call printf

	; generate texture
	mov rcx, 1
	lea rdx, [texture_id]
	call [glad_glGenTextures]

	; bind texture
	mov rcx, GL_TEXTURE_2D
	mov rdx, [texture_id]
	call [glad_glBindTexture]

	mov rcx, GL_TEXTURE_2D
	mov rdx, GL_TEXTURE_WRAP_S
	mov r8, GL_REPEAT
	call [glad_glTexParameteri]
	mov rdx, GL_TEXTURE_WRAP_T
	call [glad_glTexParameteri]
	mov rcx, GL_TEXTURE_MIN_FILTER
	mov rdx, GL_LINEAR_MIPMAP_LINEAR
	call [glad_glTexParameteri]
	mov rcx, GL_TEXTURE_MAG_FILTER
	mov rdx, GL_LINEAR
	call [glad_glTexParameteri]

	; load into opengl
	sub rsp, 128
	mov rcx, GL_TEXTURE_2D
	mov rdx, 0
	mov r8, GL_RGB
	mov r9, [width]
	mov rax, [height]
	mov [rsp + 32], rax
	mov [rsp + 40], dword 0
	mov [rsp + 48], dword GL_RGB
	mov [rsp + 56], dword GL_UNSIGNED_BYTE
	mov rax, [data]
	mov [rsp + 64], rax
	call [glad_glTexImage2D]
	add rsp, 128

	; generate mipmaps
	mov rcx, GL_TEXTURE_2D
	call [glad_glGenerateMipmap]

	add rsp, 128

	mov rcx, [data]
	call stbi_image_free

	mov rsp, rbp
	pop rbp

	ret

%endif
