extern glfwInit
extern glfwTerminate
extern glfwWindowHint
extern glfwMakeContextCurrent
extern glfwPollEvents
extern glfwSwapBuffers
extern glfwCreateWindow
extern glfwWindowShouldClose
extern glfwDestroyWindow
extern glfwGetTime
extern glfwSwapInterval

section .data
	; glfw constants
	GLFW_CONTEXT_VERSION_MAJOR: equ 0x00022002
	GLFW_CONTEXT_VERSION_MINOR: equ 0x00022003
	GLFW_OPENGL_PROFILE:        equ 0x00022008
	GLFW_OPENGL_CORE_PROFILE:   equ 0x00032001
