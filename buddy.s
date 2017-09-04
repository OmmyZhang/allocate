.equ LINUX_SYSCALL , 0x80
.equ SYS_BRK , 45

.data 
curr_brk:
	.long  0
heap_begin:
	.long 0
head:
	.rept 31
	.long -1
	.endr
	.long 0 # 2^0 ~ 2^31

.text
.globl alloc_init
.type alloc_init,@function	
alloc_init:
	pushl %ebp
	movl  %esp , %ebp
	
	movl $SYS_BRK , %eax
	movl $0 , %ebx
	int  $LINUX_SYSCALL

	movl %eax , curr_brk
	movl %eax , heap_begin

	movl %ebp , %esp
	popl %ebp
	ret

.globl allocate
.type allocate,@function
allocate:  # push the size in %eax
	pushl %ebp
	movl  %esp,%ebp

	addl $8 , %eax

	movl $3 , %edi
	movl $8 , %ebx # ebx = 2^edi

get_bigger:
	incl %edi
	shll $1 , %ebx

	cmpl %eax , %ebx
	jl get_bigger

	movl %edi , %esi

find_space:	
	cmpl $-1 , head(, %esi,4)
	jne use_space
	incl %esi
	shll $1 , %ebx
	jmp find_space

use_space:
	movl head(,%esi,4) , %eax    # __next__ __len__ __useful__
	movl $-1 , head(,%esi,4)

	leal (%eax,%ebx) , %ecx
	addl heap_begin , %ecx
	cmpl  curr_brk , %ecx
	jae get_fit_size

	addl heap_begin , %eax
	movl 0(%eax) , %edx
	subl heap_begin , %eax
	addl heap_begin , %edx
	movl %edx , head(,%esi,4)

get_fit_size:
	cmpl %esi , %edi
	je check_brk

	decl %esi
	shrl %ebx 

	leal (%eax,%ebx) , %ecx
	movl %ecx , head(,%esi,4)

	leal (%eax,%ebx,2) , %ecx
	addl heap_begin , %ecx
	cmpl curr_brk , %ecx
	jae get_fit_size

	leal (%eax,%ebx) , %ecx
	addl heap_begin , %ecx
	movl $-1 , 0(%ecx)
	jmp get_fit_size

check_brk:
	leal (%eax,%ebx) , %ecx
	addl heap_begin , %ecx
	cmpl curr_brk , %ecx
	jb get_space
	pushl %eax
	pushl %ebx

	movl $SYS_BRK , %eax
	movl %ecx , %ebx
	int $LINUX_SYSCALL

	movl curr_brk , %ecx
fill:
	cmp %ecx , %eax
	je finish_fill
	movl $-1 , (%ecx)
	addl $4 , %ecx
	jmp fill

finish_fill:
	movl %eax , curr_brk

	popl %ebx
	popl %eax



get_space:
	addl $4 , %eax
	addl heap_begin , %eax
	movl %ebx , (%eax)

	addl $4 , %eax

	movl %ebp , %esp
	pop %ebp
	ret




