as --32 test.s -o test.o
as --32 buddy.s -o buddy.o
ld -m elf_i386 test.o buddy.o -o test
./test
