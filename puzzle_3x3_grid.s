/* David @InfinitelyManic
https://benvitalenum3ers.wordpress.com/2012/03/31/3x3-grid-digits-1-to-9/
To arrange the digits 1 to 9 in the 3×3 square in such a way that the number in the second row is twice that in the first row,
 and the number in the bottom row is three times that in the top row.
	a1 a2 a3
	b1 b2 b3
	c1 c2 c3
*/
.bss
.data
	fmt:	.asciz	"%d\n%d\n%d\n\n"
	.equ	START,123
	.equ	STOP, 999
	.equ 	STACK, 4
.text
	.global main
	.func main

	/* distinct_row macro ensures that the digits of the row number are distinct */
	.macro split_3_digit_num row
	.split_3_digit_num\@:
	mov r1, \row		@; save to R1
	mov r2, #100		@; multiplier 
	mov r3, #10		@; multiplier 

	/* get digit 1 */
	vmov.f32.s32 s1, r1	@; convert to single due to no div instruction in armv7-1 
	vmov.f32.s32 s2, r2	@; convert to single due to no div instruction in armv7-1 
	vdiv.f32 s1, s1, s2	@; n/100
	vcvt.s32.f32 s1, s1	@; convert single to int
	vmov.s32.f32 r5, s1	@; convert from single to signed int; save in Rx

	/* prep to get digit 2 */
	mov r6, r5		@; copy digit 1
	mul r6, r2		@; digit 1 * 100; inflate digit 1 to its original place 
	sub r6, r1, r6		@; digit 2 is now leading digit
	/* get digit 2 */
	vmov.f32.s32 s1, r6	@; convert to single due to no div instruction in armv7-1 
	vmov.f32.s32 s2, r3	@; convert to single due to no div instruction in armv7-1 
	vdiv.f32 s1, s1, s2	@; n/10
	vcvt.s32.f32 s1, s1	@; convert single to int
	vmov.s32.f32 r6, s1	@; convert from single to signed int; save in Rx

	/* get digit 3 */ 
	mul r8, r5, r2		@; recontruct digit 1 in original place
	mul r9, r6, r3		@; recontruct digit 2 in original place
	add r8, r9		@; digit 1 | digit 2 | 0
	sub r7, r1, r8 		@; now we have digit 3
	
	.endm


main:
	@; r1 = a1|a2|a3
	@; r2 = b1|b2|b3
	@; r3 = c1|c2|c3
	@; r4 = (b1|b2|b3) = 2(r1)	
	@; r5 = (c2|c2|c3) = 3(r1)
	@; r6 = 2
	@; r7 = 3
	@; r8 = STOP ; counter 
	nop

	sub sp, sp, #STACK

	mov r6, #2
	mov r7, #3
	ldr r8, =STOP 

	mov r1, #111
	.loop1:	
	mov r2, #384
	.loop2:	
	mov r3, #576
	.loop3:	

	cmp r1, r2
	beq .skip0
	cmp r1, r3
	beq .skip0

	cmp r2, r3
	beq .skip0	

	mul r4, r1, r6 		@; 2(row 1)
	cmp r4, r2 		@; 2(row 1) == row 2
	bne .skip0

	mul r5, r1, r7 		@; 3(row 1)
	cmp r5, r3 		@; 3(row 1) == row 3
	bne .skip0

.convert0:

	push {r1-r8} 
	split_3_digit_num r1	@; split the 3 digit number a1||a2||a3

	vmov.f32.s32 s10, r5	@; save a1
	vcvt.f32.s32 s10, s10	@; convert signed int to float; this may not be neccessary 

	vmov.f32.s32 s11, r6	@; save a2
	vcvt.f32.s32 s11, s11

	vmov.f32.s32 s12, r7
	vcvt.f32.s32 s12, s12
	pop {r1-r8}		@; restore 

	push  {r1-r8}
	split_3_digit_num r2

	vmov.f32.s32 s13, r5
	vcvt.f32.s32 s13, s13

	vmov.f32.s32 s14, r6
	vcvt.f32.s32 s14, s14

	vmov.f32.s32 s15, r7
	vcvt.f32.s32 s15, s15
	pop {r1-r8}

	push {r1-r8}	
	split_3_digit_num r3

	vmov.f32.s32 s16, r5
	vcvt.f32.s32 s16, s16

	vmov.f32.s32 s17, r6
	vcvt.f32.s32 s17, s17

	vmov.f32.s32 s18, r7
	vcvt.f32.s32 s18, s18
	pop {r1-r8}


.compare0:
	vcmp.f32.f32 s10, s11
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s10, s12
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s10, s13
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s10, s14
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s10, s15
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s10, s16
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s10, s17
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s10, s18
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s11, s12
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s11, s13
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s11, s14
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s11, s15
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s11, s16
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s11, s17
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s11, s18
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s12, s13
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s12, s14
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s12, s15
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s12, s16
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s12, s17
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s12, s18
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s13, s14
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s13, s15
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s13, s16
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s13, s17
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s13, s18
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s14, s15
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s14, s16
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s14, s17
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s14, s18
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s15, s16
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s15, s17
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s15, s18
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s16, s17
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s16, s18
	vmrs apsr_nzcv, fpscr
	beq .skip0

	vcmp.f32.f32 s17, s18
	vmrs apsr_nzcv, fpscr
	beq .skip0


.stop0:

	bl _write

.skip0:
	add r3,#1
	cmp r3, r8
	blt .loop3
	add r2,#1
	cmp r2, r8
	blt .loop2
	add r1,#1
	cmp r1, r8
	blt .loop1

	add sp, sp, #STACK

_exit:
	mov r7, #1
	svc 0

_write:
	push {r0-r10,lr}
	ldr r0,=fmt
	bl printf
	pop {r0-r10,pc}
