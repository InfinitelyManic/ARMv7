/*	David @InfinitelyManic
	Using some ARM brute force to solve simple puzzle in:
	https://benvitalenum3ers.wordpress.com/2015/07/30/solve-a5-b5-c3-d3-e2-f2-n-for-positive-integers/
	A^5 - B^5 = C^3 - D^3 = E^2 - F^2 = N
	e.g., 4^5 - 2^5 = 10^3 - 2^3 = 39^2 - 23^2 = 992
	gcc -g puzzle_ABCDEFN.s -o puzzle_ABCDEFN
	$ uname -a
	Linux debian-armhf 3.2.0-4-vexpress #1 SMP Debian 3.2.51-1 armv7l GNU/Linux
	Using emulated ARM arch via QEMU running Debian armhf OS
	Date 07/31/2015
*/

.bss
.data
	fmt:	.asciz	"%d^5 - %d^5 == %d^3 - %d^3 == %d^2 - %d^2\n"
	.equ 	BEG, 	0x4
	.equ	END,	0xff
	.equ 	AEND, 	100
.text
	.global main
	.func main

	/* create floating point double pwr calculator */
	.macro dnPwr n, p
	vmov.f64.f64 d0, \n		@; save base param in Dx
	vmov.f64.f64 d10, \n		@; copy dx
	mov r10, \p			@; save exp param in Rx
	sub r10, r10, #1		@; offset the counter 
	.pwr\@:
		vmul.f64 d0, d10
		subs r10, #1
		bne .pwr\@
	.endm 

main:
	nop
	/*
	r1 = A
	r2 = B
	r3 = C
	r4 = D
	r5 = E
	r6 = F
	r7 = 5 as in A^5 - B^5
	r8 = 3 as in C^3 - D^3
	r9 = 2 as in E^2 = F^2
	r10 = counter for dnPwr macro 
	d1 = A double
	d2 = B "
	d3 = C "
	d4 = D "
	d5 = E "
	d6 = F "
	d10 = base for n^p
	*/
	mov r7, #5
	mov r8, #3
	mov r9, #2

	mov r1, #BEG		
	.loop1:
		mov r2, #BEG		
		.loop2:
			mov r3, #BEG		
			.loop3:
				mov r4, #BEG		
				.loop4:
					mov r5, #BEG	
					.loop5:
						mov r6, #BEG		
						.loop6:
						/* since we are doing A^5 - B^5; C^3 - D^3; E^2 - F^2, we need A>B, C>D, E>F */
						cmp r1, r2
						ble .skip0			@; A>B
					
						cmp r3, r4			@; C>D
						ble .skip0

						cmp r5, r6			@; E>F
						ble .skip0

						/*--do something -----------*/
						/* copy Rx values into Dx convert to doubles for the sake of potentially large solutions */
						vmov s0, r1 
						vcvt.f32.s32 s0, s0
						vcvt.f64.f32 d1, s0	@; A
 
						vmov s0, r2 
						vcvt.f32.s32 s0, s0
						vcvt.f64.f32 d2, s0	@; B
						
						vmov s0, r3 
						vcvt.f32.s32 s0, s0
						vcvt.f64.f32 d3, s0	@; C

						vmov s0, r4 
						vcvt.f32.s32 s0, s0
						vcvt.f64.f32 d4, s0	@; D

						vmov s0, r5 
						vcvt.f32.s32 s0, s0
						vcvt.f64.f32 d5, s0	@; E

						vmov s0, r6 
						vcvt.f32.s32 s0, s0
						vcvt.f64.f32 d6, s0	@; F
.stop0:
					
						/* calculate pwrs and place values in orignal Dx regs */
						dnPwr d1, r7
						vmov.f64 d1, d0		@; A^5

						dnPwr d2, r7
						vmov.f64 d2, d0		@; B^5
						
						dnPwr d3, r8
						vmov.f64 d3, d0		@; C^3

						dnPwr d4, r8
						vmov.f64 d4, d0		@; D^3
						
						dnPwr d5, r9
						vmov.f64 d5, d0		@; E^2

						dnPwr d6, r9
						vmov.f64 d6, d0		@; F^2

						vsub.f64 d1, d1, d2	@; A^5 - B^5
						vsub.f64 d3, d3, d4	@; C^3 - D^3
						vsub.f64 d5, d5, d6	@; E^2 - F^2
.stop1:

						vcmp.f64 d1, d3		@; A^5 - B^5 == C^3 - D^3 	
						vmrs apsr_nzcv, fpscr
						bne .skip0

						vcmp.f64 d3, d5		@; C^3 - D^3 == E^2 - F^2
						vmrs apsr_nzcv, fpscr
						bne .skip0
						
						bl write

.skip0:
						/*--done something ---------- */
						add r6, #1
						cmp r6, #END
						ble .loop6 
					add r5, #1
					cmp r5, #END	
					ble .loop5 
				add r4, #1
				cmp r4, #END
				ble .loop4 
			add r3, #1
			cmp r3, #END	
			ble .loop3 
		add r2, #1
		cmp r2, #END	
		ble .loop2 
	add r1, #1
	cmp r1, #AEND
	ble .loop1 


exit:
	mov r7, #1
	svc 0

write:
	push {r0-r3,lr}	
	ldr r0,=fmt
	sub sp, sp, #4
	push {r7}		@; this may not be neccesary; just concered about ordering push {r4-r7} may work
	push {r6}
	push {r5}
	push {r4}
	bl printf 
	pop {r4}
	pop {r5}
	pop {r6}
	pop {r7}
	add sp, sp, #4
	pop {r0-r3,pc}

.print "All done!"

