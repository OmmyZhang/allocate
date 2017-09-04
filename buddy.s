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

	pushl %ebx
	pushl %edi
	pushl %esi
	
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


	decl %ecx
	orl $0xfff , %ecx
	incl %ecx

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
	
	addl heap_begin , %eax
	movl %edi , (%eax)
	addl $4 , %eax
	movl %ebx , (%eax)
	addl $4 , %eax

	popl %esi
	popl %edi
	popl %ebx

	movl %ebp , %esp
	pop %ebp
	ret



.globl deallocate
.type deallocate,@function	
deallocate: # put addres in %eax
	
	pushl %ebp
	movl  %esp,%ebp

	pushl %ebx
	pushl %edi
	pushl %esi
	
	subl $8 , %eax

	movl 0(%eax) , %edi
	movl 4(%eax) , %ebx

	movl $0   , %edx
	subl %ebx , %edx
	movl %edx , 4(%eax)   
#used: [log(len)][ len] ... 
#free: [next]    [-len]  ...
	subl heap_begin , %eax

merge:
	movl %eax , %ecx
	xorl %ebx , %ecx

	addl heap_begin , %ecx
	addl %ebx , %ecx
	cmp  curr_brk , %ecx
	ja end_merge
	subl %ebx , %ecx

	movl $0 , %edx
	subl 4(%ecx) , %edx
	cmp %edx , %ebx
	jne end_merge
	subl heap_begin , %ecx

	leal head(,%edi,4) , %edx # edx is the real address
searh_buddy:
	cmp (%edx) , %ecx
	je get_buddy

	movl (%edx) , %edx
	addl heap_begin , %edx
	jmp searh_buddy

get_buddy:
	addl heap_begin , %ecx
	movl (%ecx) , %esi  # esi:temp
	subl heap_begin , %ecx
	movl %esi , (%edx)

	andl %ecx , %eax
	incl %edi
	shll $1 , %ebx
	jmp merge

end_merge:
	addl heap_begin , %eax
	
	movl $0 , %esi #esi:temp
	subl %ebx , %esi
	movl %esi , 4(%eax)
	movl head(,%edi,4) , %edx
	movl %edx , 0(%eax)

	subl heap_begin , %eax
	movl %eax , head(,%edi,4)

	popl %esi
	popl %edi
	popl %ebx

	movl %ebp , %esp
	pop %ebp
	ret

	


