build:
	nasm -f win64 main.asm
	nasm -f win64 glfw.asm
	nasm -f win64 opengl.asm
	nasm -f win64 matrices.asm
	nasm -f win64 matrix_multiply.asm
	nasm -f win64 math.asm
	nasm -f win64 image.asm
	gcc main.obj glfw.obj opengl.obj matrices.obj matrix_multiply.obj math.obj image.obj -o main.exe glad.c stb_image.c -I"includes\glfw" -I"includes" -L"lib" -lglfw3 -lopengl32 -lgdi32 -luser32 -lkernel32 -lshell32 -lole32 -ladvapi32 -lws2_32
	main.exe

link:
	gcc -c glad.c -o glad.o

c:
	gcc main.c -o c.exe glad.c -I"includes\glfw" -I"includes" -L"lib" -lglfw3 -lopengl32 -lgdi32 -luser32 -lkernel32 -lshell32 -lole32 -ladvapi32
	c.exe

c_asm:
	gcc -S main.c -o c.asm
