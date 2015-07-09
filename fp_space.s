/* David @InfinitelyManic 
Demo of the Space of Floating-point representable values 
compiled: gcc -g fp_space.s -o fp_space  
machine: uname -a Linux debian-armhf 3.2.0-4-vexpress #1 SMP Debian 3.2.51-1 armv7l GNU/Linux
above is basically a QEMU environ....
Last Revision 07/08/2015
*/
.bss
.data
	fmt:	.asciz "Biased exp: %d range start: %g range end: %g \n"
	.equ 	xSPACE, (4*3)		@; multiplier should be an odd number
	.equ 	xfSPACE, 8 		@; additional space to create on stack for printing second double floating point
	.equ 	BASE, 2			@; b^n = 2^n
	.equ 	aNUM, 2			@; first biased exponent; code below assumes positive values only; else modify counters accordingly, among other things 
	.equ	zNUM, 254		@; last biased exponent
	.equ 	exp23, 23 		@; max exp value based on single precision 23 bit fraction/mantissa
	
.text
	.global main
	.func main
	.align 0
main:
	nop				@; this is just for debugging if you need to see sp value before stack adj

	sub sp, sp, #xSPACE	

	mov r1, #aNUM			@; biased exponent starting value
.base:

	mov r2, #BASE			@; always two (2) in the instance case
	vmov s11, r2
	vcvt.f32.s32 s11,s11
	vcvt.f64.f32 d2,s11		@; #BASE dbl

.one:
	mov r2, #1			@; for 1/x 
	vmov s11, r2
	vcvt.f32.s32 s11,s11
	vcvt.f64.f32 d3,s11		@; #1 dbl

.two:
	mov r2, #2			@; for (2-2^(-biased exp) range constant 
	vmov s11, r2
	vcvt.f32.s32 s11,s11
	vcvt.f64.f32 d4,s11		@; #2 dbl  


.mconstant:				@; multiplier range constant 
	mov r3, #exp23
	bl ndPwr
	vmov.f64 d5, d0 		@; save copy of 2^(-23)
	vsub.f64 d4, d5			@; multiplier constant
	
.loop0:
	mov r3, r1			@; need to set the counter based to the value of the biased exponent
	sub r3, #1			@; save one

	bl dPwr 			@; calc 2^(biased exponent; returns in d0

	vmov.f64 d1, d0			@; copy rang0 
	vmul.f64 d1, d4			@; get ending range

	bl write			@; print something	

	adds r1, #1			@; increment biased exponent 
	cmp r1, #zNUM
	ble .loop0

	add sp, sp, #xSPACE
	 
exit:
	mov r7, #1
	svc 0

write:
	push {r0-r3,lr}
	sub sp, sp, #xfSPACE		@; this is for the floating point numbers
	ldr r0, =fmt
	vmov r2, r3, d0			@; first double floating point goes into r2,r3; we skip r1
	vstr.f64 d1, [sp]		@; second floating point goes on stack, if neccessary 
	bl printf
	add sp, sp, #xfSPACE		@; restore stack
	pop {r0-r3,pc}


dPwr:	/* double floating point pwr calc	*/
	push {r0-r3, lr}
	vmov.f64 d0, d2			@; assumes param is in d2; counter in r3
	.pwr0:
		vmul.f64 d0, d0, d2	
		subs r3, #1	
		bne .pwr0
	pop {r0-r3, pc}	

ndPwr:	/* negative exponent double floating point pwr calc; e.g., 2^(-23) == 1/(2^23)  */
	push {r0-r3, lr}
	vmov.f64 d0, d2			@; assumes params are in d2 & r3
	.pwr1:
		vmul.f64 d0, d0, d2	
		subs r3, #1	
		bne .pwr1
	vdiv.f64 d0, d2, d0		@; 1/x
	pop {r0-r3, pc}	
