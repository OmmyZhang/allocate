.equ LINUX_SYSCALL,0x80
.equ SYS_EXIT,1
.data
adr:
	.long 0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0

.text
.globl _start
_start:

	call alloc_init

	movl $3 , %eax
	call allocate

	pushl %eax

	movl $1000000 , %eax
	call allocate

_delete:

	popl %eax
	call deallocate

	movl $1000000 , %eax
	call allocate

another_test:
	movl $3 , %eax
	call allocate
	movl $1 , %edi
	movl %eax , adr(,%edi,4)
fir:
	movl $3 , %eax
	call allocate
	movl $2 , %edi
	movl %eax , adr(,%edi,4)
sec:	
	movl $20 , %eax
	call allocate
	movl $3 , %edi
	movl %eax , adr(,%edi,4)
thir:	
	movl $3 , %eax
	call allocate
	movl $4 , %edi
	movl %eax , adr(,%edi,4)
four:	
	movl $3 , %eax
	call allocate
	movl $5 , %edi
	movl %eax , adr(,%edi,4)
fif:	
	movl $1 , %edi
	movl adr(,%edi,4) , %eax
	call deallocate
six:
	movl $5 , %edi
	movl adr(,%edi,4) , %eax
	call deallocate
sev:
	movl $4 , %edi
	movl adr(,%edi,4) , %eax
	call deallocate
eig:
	movl $2 , %edi
	movl adr(,%edi,4), %eax
	call deallocate
nin:
	movl $20 , %eax
	call allocate
_exit:
	movl $SYS_EXIT , %eax
	movl $0 , %ebx
	int $LINUX_SYSCALL


