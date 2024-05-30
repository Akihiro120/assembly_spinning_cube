extern printf
extern ExitProcess

; includes
%include "glfw.asm"
%include "opengl.asm"
%include "matrices.asm"
%include "math.asm"
%include "image.asm"

section .data
	; print data
	print_double: db "%lf", 0x0A, 0x00
	print_float: db "%f", 0x0A, 0x00
	; pi: dd 3.141

	; windowing
	window_dimensions:
		dd 1280
		dd 720
	window_title: db "Spinning Cube", 0
	
	clear_color: dd 0.2, 0.3, 0.3, 1.0

	; vertices and indices
	vertex_array_object: dd 0
	vertex_buffer_object: dd 0
	element_buffer_object: dd 0
	shader_program: dd 0
	vertices: 
		dd -0.5, -0.5, -0.5,  0.0, 0.0,
    dd 0.5, -0.5, -0.5,  1.0, 0.0,
    dd 0.5,  0.5, -0.5,  1.0, 1.0,
    dd 0.5,  0.5, -0.5,  1.0, 1.0,
    dd -0.5,  0.5, -0.5,  0.0, 1.0,
    dd -0.5, -0.5, -0.5,  0.0, 0.0,

    dd -0.5, -0.5,  0.5,  0.0, 0.0,
    dd 0.5, -0.5,  0.5,  1.0, 0.0,
    dd 0.5,  0.5,  0.5,  1.0, 1.0,
    dd 0.5,  0.5,  0.5,  1.0, 1.0,
    dd -0.5,  0.5,  0.5,  0.0, 1.0,
    dd -0.5, -0.5,  0.5,  0.0, 0.0,

    dd -0.5,  0.5,  0.5,  1.0, 0.0,
    dd -0.5,  0.5, -0.5,  1.0, 1.0,
    dd -0.5, -0.5, -0.5,  0.0, 1.0,
    dd -0.5, -0.5, -0.5,  0.0, 1.0,
    dd -0.5, -0.5,  0.5,  0.0, 0.0,
    dd -0.5,  0.5,  0.5,  1.0, 0.0,

    dd 0.5,  0.5,  0.5,  1.0, 0.0,
    dd 0.5,  0.5, -0.5,  1.0, 1.0,
    dd 0.5, -0.5, -0.5,  0.0, 1.0,
    dd 0.5, -0.5, -0.5,  0.0, 1.0,
    dd 0.5, -0.5,  0.5,  0.0, 0.0,
    dd 0.5,  0.5,  0.5,  1.0, 0.0,

    dd -0.5, -0.5, -0.5,  0.0, 1.0,
    dd 0.5, -0.5, -0.5,  1.0, 1.0,
    dd 0.5, -0.5,  0.5,  1.0, 0.0,
    dd 0.5, -0.5,  0.5,  1.0, 0.0,
    dd -0.5, -0.5,  0.5,  0.0, 0.0,
    dd -0.5, -0.5, -0.5,  0.0, 1.0,

    dd -0.5,  0.5, -0.5,  0.0, 1.0,
    dd 0.5,  0.5, -0.5,  1.0, 1.0,
    dd 0.5,  0.5,  0.5,  1.0, 0.0,
    dd 0.5,  0.5,  0.5,  1.0, 0.0,
    dd -0.5,  0.5,  0.5,  0.0, 0.0,
    dd -0.5,  0.5, -0.5,  0.0, 1.0
	vertices_size: equ $-vertices
	indices: 
		dd 0, 1, 3, 3, 1, 2
	indices_size: equ $-indices
	
	vertex_shader_source: 
		db "#version 460 core", 0x0A,
    db "layout (location = 0) in vec3 aPos;", 0x0A
		db "layout (location = 1) in vec2 aTexCoords;", 0x0A
		db "uniform mat4 proj;", 0x0A
		db "uniform mat4 view;", 0x0A
		db "uniform mat4 model;", 0x0A
		db "out vec2 texCoords;", 0x0A
    db "void main()", 0x0A
    db "{", 0x0A
    db "  gl_Position = proj * view * model * vec4(aPos, 1.0);", 0x0A
		db "	texCoords = aTexCoords;", 0x0A
    db "}", 0, 0
	fragment_shader_source: 
		db "#version 460 core", 0x0A
    db "out vec4 FragColor;", 0x0A
		db "uniform sampler2D ourTexture;"
		db "in vec2 texCoords;", 0x0A
    db "void main()", 0x0A
    db "{", 0x0A
    db "   FragColor = texture(ourTexture, texCoords);", 0x0A
    db "}", 0, 0
	vertex_status: db "Error: Vertex Shader: %s", 10, 0x00
  fragment_status: db "Error: Fragment Shader: %s", 10, 0
	success: dd 0

	; uniform locations
	projection_uniform_location: db "proj", 0x00
	view_uniform_location: db "view", 0x00
	model_uniform_location: db "model", 0x00
	texture_uniform_location: db "ourTexture", 0x00

section .bss
	; window handle
	window_handle: resq 1
	
	; shader error handling
	info_log: resb 512

	; shaders
	vertex_shader: resq 1
	vertex_shader_pointer: resq 1
	fragment_shader: resq 1
	fragment_shader_pointer: resq 1

section .text
global main

main:
	; create new stack frame
	push rbp
	mov rbp, rsp

	; initialize glfw
	mov rcx, 0
	call glfwInit

	; window hints
	mov rcx, GLFW_CONTEXT_VERSION_MAJOR
	mov rdx, 4
	call glfwWindowHint
	mov rcx, GLFW_CONTEXT_VERSION_MINOR
	mov rdx, 6
	call glfwWindowHint
	mov rcx, GLFW_OPENGL_PROFILE
	mov rdx, GLFW_OPENGL_CORE_PROFILE
	call glfwWindowHint
	
	; create window
	sub rsp, 32
	mov ecx, dword [window_dimensions]
	mov edx, dword [window_dimensions + 4]
	lea r8, [window_title]
	mov r9, 0
	mov rax, 0
	mov [rsp + 32], qword rax
	call glfwCreateWindow
	mov [window_handle], rax
	add rsp, 32
	
	mov rcx, [window_handle]
	call glfwMakeContextCurrent

	mov rcx, 0
	call glfwSwapInterval

	; initialize opengl
	call gladLoadGL

	mov rcx, GL_DEPTH_TEST
	call [glad_glEnable]

	; generate vertex arrays
	mov rcx, 1
	lea rdx, [vertex_array_object]
	call [glad_glGenVertexArrays]

	; generate vertex buffers
	mov rcx, 1
	lea rdx, [vertex_buffer_object]
	call [glad_glGenBuffers]

	; generate element buffers
	mov rcx, 1
	lea rdx, [element_buffer_object]
	call [glad_glGenBuffers]

	; bind vertex arrays
	mov rcx, [vertex_array_object]
	call [glad_glBindVertexArray]

	; create vertex buffer
	mov rcx, GL_ARRAY_BUFFER
	mov rdx, [vertex_buffer_object]
	call [glad_glBindBuffer]

	mov rcx, GL_ARRAY_BUFFER
	mov rdx, vertices_size
	lea r8, [vertices]
	mov r9, GL_STATIC_DRAW
	call [glad_glBufferData]

	; create element buffer
	mov rcx, GL_ELEMENT_ARRAY_BUFFER
	mov rdx, [element_buffer_object]
	call [glad_glBindBuffer]

	mov rcx, GL_ELEMENT_ARRAY_BUFFER
	mov rdx, indices_size
	lea r8, [indices]
	mov r9, GL_STATIC_DRAW
	call [glad_glBufferData]

	; vertex attribs
	mov rcx, 0
	call [glad_glEnableVertexAttribArray]

	sub rsp, 64
	mov rcx, 0
	mov rdx, 3
	mov r8, GL_FLOAT
	mov r9, GL_FALSE
	mov [rsp + 32], dword 20
	mov [rsp + 40], dword 0
	call [glad_glVertexAttribPointer]
	add rsp, 64

	mov rcx, 1
	call [glad_glEnableVertexAttribArray]

	sub rsp, 64
	mov rcx, 1
	mov rdx, 2
	mov r8, GL_FLOAT
	mov r9, GL_FALSE
	mov [rsp + 32], dword 20
	mov [rsp + 40], dword 12
	call [glad_glVertexAttribPointer]
	add rsp, 64

	; create shaders
	; vertex shader
	sub rsp, 32
	mov rcx, GL_VERTEX_SHADER
	call [glad_glCreateShader]
	mov [vertex_shader], rax
	
	mov rcx, [vertex_shader]
	mov rdx, 1
	mov rax, vertex_shader_source
	mov [vertex_shader_pointer], rax
	lea r8, [vertex_shader_pointer]
	mov r9, 0
	call [glad_glShaderSource]

	mov rcx, [vertex_shader]
	call [glad_glCompileShader]

	mov rcx, [vertex_shader]
  mov rdx, GL_COMPILE_STATUS
  lea r8d, dword [success]
  call [glad_glGetShaderiv]

  mov rcx, [vertex_shader]
  mov rdx, 512
  mov r8, 0
  lea r9, [info_log]
  call [glad_glGetShaderInfoLog]

  mov rcx, vertex_status
  lea rdx, [info_log]
  call printf
  xor rax, rax

	; fragment shader
	mov rcx, GL_FRAGMENT_SHADER
	call [glad_glCreateShader]
	mov [fragment_shader], rax

	mov rcx, [fragment_shader]
	mov rdx, 1
	mov rax, fragment_shader_source
	mov [fragment_shader_pointer], rax
	lea r8, [fragment_shader_pointer]
	mov r9, 0
	call [glad_glShaderSource]

	mov rcx, [fragment_shader]
	call [glad_glCompileShader]

	mov rcx, [fragment_shader]
  mov rdx, GL_COMPILE_STATUS
  lea r8d, dword [success]
  call [glad_glGetShaderiv]

  mov rcx, [fragment_shader]
  mov rdx, 512
  mov r8, 0
  lea r9, [info_log]
  call [glad_glGetShaderInfoLog]

  mov rcx, fragment_status
  lea rdx, [info_log]
  call printf
  xor rax, rax
	
	; shader program
	xor rcx, rcx
	call [glad_glCreateProgram]
	mov [shader_program], rax

	mov rcx, [shader_program]
	mov rdx, [vertex_shader]
	call [glad_glAttachShader]

	mov rcx, [shader_program]
	mov rdx, [fragment_shader]
	call [glad_glAttachShader]

	mov rcx, [shader_program]
	call [glad_glLinkProgram]
	add rsp, 32

	; image
	call load_texture

	; render loop
	jmp render_loop
render_loop:
	; should the window close
	mov rcx, [window_handle]
	call glfwWindowShouldClose
	cmp rax, 0
	jne end_render_loop

	; set the viewport
	mov rcx, 0
	mov rdx, 0
	mov r8d, dword [window_dimensions]
	mov r9d, dword [window_dimensions + 4]
	call [glad_glViewport]

	; set the clear color
	movd xmm0, dword [clear_color]
	movd xmm1, dword [clear_color + 4]
	movd xmm2, dword [clear_color + 8]
	movd xmm3, dword [clear_color + 12]
	call [glad_glClearColor]
	mov rcx, GL_COLOR_BUFFER_BIT
	mov rdx, GL_DEPTH_BUFFER_BIT
	or rcx, rdx
	call [glad_glClear]

	; draw
	mov rcx, [shader_program]
	call [glad_glUseProgram]

	mov rcx, [vertex_array_object]
	call [glad_glBindVertexArray]

	; update matrices
	call build_perspective_matrix
	call build_view_matrix
	call build_model_matrix

	; matrix uniforms
	mov rcx, [shader_program]
	lea rdx, [projection_uniform_location]
	call [glad_glGetUniformLocation]
	mov rcx, rax
	mov rdx, 1
	mov r8, GL_FALSE
	lea r9, [perspective_matrix]
	call [glad_glUniformMatrix4fv]

	mov rcx, [shader_program]
	lea rdx, [view_uniform_location]
	call [glad_glGetUniformLocation]
	mov rcx, rax
	mov rdx, 1
	mov r8, GL_FALSE
	lea r9, [view_matrix]
	call [glad_glUniformMatrix4fv]

	mov rcx, [shader_program]
	lea rdx, [model_uniform_location]
	call [glad_glGetUniformLocation]
	mov rcx, rax
	mov rdx, 1
	mov r8, GL_FALSE
	lea r9, [model_matrix]
	call [glad_glUniformMatrix4fv]

	mov rcx, GL_TEXTURE0
	call [glad_glActiveTexture]
	mov rcx, GL_TEXTURE_2D
	mov rdx, [texture_id]
	call [glad_glBindTexture]

	mov rcx, [shader_program]
	lea rdx, [texture_uniform_location]
	call [glad_glGetUniformLocation]
	mov rcx, rax
	mov rdx, 0
	call [glad_glUniform1i]

	mov rcx, GL_TRIANGLES
	mov rdx, 0
	mov r8, 36
	call [glad_glDrawArrays]

	; poll and swap buffers
	call glfwPollEvents
	mov rcx, [window_handle]
	call glfwSwapBuffers

	; loop the render loop
	jmp render_loop

end_render_loop:
	; destroy window
	mov rcx, [window_handle]
	call glfwDestroyWindow
	; terminate glfw
	call glfwTerminate
	
	mov rcx, [fragment_shader]
	call [glad_glDeleteShader]
	mov rcx, [vertex_shader]
	call [glad_glDeleteShader]
	mov rcx, [shader_program]
	call [glad_glDeleteProgram]

	; exit the program
	mov rcx, 0
	call ExitProcess
	
	; clear the stack frame
	mov rsp, rbp
	pop rbp
