/* David @InfinitelyManic
gcc -g gcd.s -o gcd
GCD e.g. reducing branches with conditionals from ARM Assembly Language 2nd, W Hohl, C Hinds 
*/

.bss
.data
	fmt:	.asciz "%d\n"
	
.text
	.global main
	.func	main
main:
	nop
	mov r1, #99
	mov r2, #65

gcd:	
	cmp 	r1, r2		@; r1 - r2 set cpsr 
	subgt 	r1, r1, r2	@; sub if r1 > r2 and put result in r1
	sublt	r2, r2, r1	@; else sub if r2 < r1 and put result in r2
	bne gcd 	
	
	bl  write
stop:

exit:
	mov r7, #1
	swi 0

write:
	push {lr}
	ldr r0, =fmt
	bl printf
	pop {pc}
		
