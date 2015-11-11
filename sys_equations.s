/*
	David @InfinitelyManic
	Solving Systems of Equations
	Inspired by Syombua Wambua - http://pastebin.com/0kbuHiFp
*/
.bss
.data
	out0:	.asciz 	"Enter A[1],B[1],C[1],D[1] values\n"
	out1:	.asciz 	"Enter A[2],B[2],C[2],D[2] values\n"
	out2:	.asciz 	"Enter A[3],B[3],C[3],D[3] values\n"
	out3: 	.asciz	"You entered %d %d %d %d\n"
	outf:	.asciz	"X = [%lf]\nY = [%lf]\nZ = [%lf]\n"
	scan0:	.string	"%d"
.text
	.include "mymac.s"
	.global main
	addr_scan:	.word	scan0
	.align 8
main:
	nop
	// r9	= ai = s1 = s5 = s9
	// r10 	= bi = s2 = s6 = s10
	// r11 	= ci = s3 = s7 = s11
	// r12 	= di = s4 = s8 = s12
	ldr r0,=out0			// point to correct message
	bl write
	bl scan				// results are retured in r9, r10, r11, r12
	bl writeE			// print what the user entered

	// macro to vmov sx, rx, vcvt.f32.s32 sx, sx
	cvtInt2Single r9, s1
	cvtInt2Single r10, s2
	cvtInt2Single r11, s3
	cvtInt2Single r12, s4
	
	ldr r0,=out1			// point to correct message
	bl write
	bl scan				// results are retured in r9, r10, r11, r12
	bl writeE			

	// macro to vmov sx, rx, vcvt.f32.s32 sx, sx
	cvtInt2Single r9, s5
	cvtInt2Single r10, s6
	cvtInt2Single r11, s7
	cvtInt2Single r12, s8

	ldr r0,=out2			// point to correct message
	bl write
	bl scan				// results are retured in r9, r10, r11, r12
	bl writeE			

	cvtInt2Single r9, s9
	// macro to vmov sx, rx, vcvt.f32.s32 sx, sx
	cvtInt2Single r10, s10	
	cvtInt2Single r11, s11
	cvtInt2Single r12, s12

	/*
	a1 = s1
	a2 = s5
	a3 = s9
	
	b1 = s2
	b2 = s6
`	b3 = s10

	c1 = s3 
	c2 = s7
	c3 = s11

	d1 = s4
	d2 = s8
	d3 = s12 
	-----------------------------
	m1 = s13 
	n1 = s15
	u1 = s17

	m2 = s19
	n2 = s21
	u2 = s23

	x = s25
	y = s27
	z = s29
	*/

	// m1 =(c1*a2)-(c2*a1);
	vmul.f32 s13, s3, s5
	vmul.f32 s14, s7, s1 
	vsub.f32 s13, s13, s14

	// n1 =(c1*b2)-(c2*b1);
	vmul.f32 s15, s3, s6
	vmul.f32 s16, s7, s2
	vsub.f32 s15, s15, s16

	// u1 =(c1*d2)-(c2*d1);
	vmul.f32 s17, s3, s8
	vmul.f32 s18, s7, s4
	vsub.f32 s17, s17, s18 

	// m2 =(c2*a3)-(c3*a2);
	vmul.f32 s19, s7, s9
	vmul.f32 s20, s11, s5
	vsub.f32 s19, s19, s20

	// n2 =(c2*b3)-(c3*b2);
	vmul.f32 s21, s7, s10
	vmul.f32 s22, s11, s6
	vsub.f32 s21, s21, s22

	// u2 =(c2*d3)-(c3*d2);
	vmul.f32 s23, s7, s12
	vmul.f32 s24, s11, s8	
	vsub.f32 s23, s23, s24

	// x = ((n1*u2)-(n2*u1))/((n1*m2)-(n2*m1));
	vmul.f32 s25, s15, s23
	vmul.f32 s26, s21, s17
	vsub.f32 s25, s25, s26

	vmul.f32 s26, s15, s19
	vmul.f32 s27, s21, s13
	vsub.f32 s26, s26, s27
	vdiv.f32 s25, s25, s26

	// y= (u1-(m1*x))/n1;
	vmul.f32 s27,s13, s25
	vsub.f32 s27,s17, s27 
	vdiv.f32 s27,s27,s15 

	// z = (d1-(a1*x)-(b1*y))/c1;
	vmul.f32 s29, s1, s25
	vmul.f32 s30, s2, s27
	vsub.f32 s29, s4, s29
	vsub.f32 s29, s29, s30
	vdiv.f32 s29, s29, s3

	// printf works with doubles not singles
	vcvt.f64.f32 d0, s25
	vcvt.f64.f32 d1, s27
	vcvt.f64.f32 d2, s29
	
	bl writef	

exit:
	mov r7, #1
	svc #0

write:
	push {r0-r3,lr}
	bl printf
	pop {r0-r3,pc}

writef:					// printing double floating points  
	push {r0-r3,lr}
	sub sp, sp, #4
	ldr r0,=outf
	eor r1, r1
	vmov r2, r3, d0
	vstr d1, [sp]
	vstr d2, [sp,#8]		// putting double on stack so move 64 bits
	bl printf
	add sp, sp, #4
	pop {r0-r3,pc}

writeE:					// print what the user entered
	push {r0-r11,lr}
	ldr r0,=out3
	mov r1, r9
	mov r2, r10
	mov r3, r11
	push {r12}
	bl printf
	pop {r12}
	pop {r0-r11,pc}

scan:
	push {r0-r3,lr}
	sub sp,sp, #4

	ldr r0, addr_scan
	mov r1, sp
	bl scanf
	ldr r9, [sp]		// store Ai

	ldr r0, addr_scan
	mov r1, sp
	bl scanf
	ldr r10, [sp]		// store Bi

	ldr r0, addr_scan
	mov r1, sp
	bl scanf
	ldr r11, [sp]		// store Ci

	ldr r0, addr_scan
	mov r1, sp
	bl scanf
	ldr r12, [sp]		// store Di

	add sp, sp, #4
	pop {r0-r3,pc}
