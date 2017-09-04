.equ LINUX_SYSCALL,0x80
.equ SYS_EXIT,1
.data
td:
	.long 5

.text
.globl _start
_start:

	call alloc_init
	

	movl $40 , %eax
	call allocate
sec:
	movl $2 , %eax
	call allocate
th:
	movl $40 , %eax
	call allocate

_exit:
	movl $SYS_EXIT , %eax
	movl $0 , %ebx
	int $LINUX_SYSCALL
