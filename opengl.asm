extern gladLoadGL
extern glad_glViewport
extern glad_glClear
extern glad_glClearColor
extern glad_glGenBuffers
extern glad_glBindBuffer
extern glad_glBufferData
extern glad_glGenVertexArrays
extern glad_glBindVertexArray
extern glad_glCreateShader
extern glad_glShaderSource
extern glad_glCompileShader
extern glad_glGetShaderiv
extern glad_glGetShaderInfoLog
extern glad_glCreateProgram
extern glad_glAttachShader
extern glad_glAttachShader
extern glad_glLinkProgram
extern glad_glUseProgram
extern glad_glDeleteShader
extern glad_glDeleteBuffers
extern glad_glDeleteProgram
extern glad_glVertexAttribPointer
extern glad_glEnableVertexAttribArray
extern glad_glDrawArrays
extern glad_glDrawElements
extern glad_glGetUniformLocation
extern glad_glUniformMatrix4fv
extern glad_glGenTextures
extern glad_glBindTexture
extern glad_glTexImage2D
extern glad_glGenerateMipmap
extern glad_glTexParameteri
extern glad_glActiveTexture
extern glad_glUniform1i
extern glad_glEnable

section .data
	; opengl constants
	GL_COLOR_BUFFER_BIT:     equ 0x00004000
	GL_DEPTH_BUFFER_BIT: equ 0x100
	GL_DEPTH_TEST: equ 	0xb71
	GL_ARRAY_BUFFER:         equ 0x00008892
	GL_ELEMENT_ARRAY_BUFFER: equ 0x00008893
	GL_STATIC_DRAW:          equ 0x000088e4
	GL_FLOAT:                equ 0x1406
	GL_FALSE:                equ 0x0
	GL_UNSIGNED_INT:         equ 0x00001405
	GL_TRIANGLES:            equ 0x00000004
	GL_VERTEX_SHADER:        equ 0x8b31
	GL_FRAGMENT_SHADER:      equ 0x8b30
	GL_COMPILE_STATUS:       equ 0x8b81
	GL_DOUBLE:               equ 0x140a
	GL_TEXTURE_2D            equ 0xde1
	GL_UNSIGNED_BYTE         equ 0x1401
	GL_RGB                   equ 0x1907
	GL_TEXTURE_WRAP_S: equ 0x2802
	GL_TEXTURE_WRAP_T: equ 0x2803
	GL_TEXTURE_MIN_FILTER: equ 0x2801
	GL_TEXTURE_MAG_FILTER: equ 0x2800
	GL_REPEAT: equ 	0x2901
	GL_LINEAR: equ 	0x2601
	GL_LINEAR_MIPMAP_LINEAR: equ 0x2703
	GL_TEXTURE0: equ 0x84c0
