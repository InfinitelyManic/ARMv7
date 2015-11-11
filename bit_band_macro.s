/*	David @InfinitelyManic
	bit-band alias = bit-band base + (byte offset * 32) + (bit number * 4)
	0x2200.0000 + (0x1000 * 32) + (3 * 4) = 0x2202.000C
	http://www.ti.com/lit/ds/symlink/tm4c1294ncpdt.pdf
	# uname -a
	Linux debian-armhf 3.2.0-4-vexpress #1 SMP Debian 3.2.51-1 armv7l GNU/Linux
	Not thumb! \O.O/
*/
.bss
.data
	fmt:	.asciz 	"0x%x 0x%x\n"
.text
	.global main
	.func main
	.macro	calcAlias a b			@; bit-bandable address & bit nnumber
		.calcAlias\@:			@; this is just to make debugging a little easier; at least for me
		mov r1, \a			@; save address
		mov r2, \b			@; save bit number  

		movw r3, #0xffff		
		movt r3, #0x400f		@; 0x400fffff; MAX bit-bandable 1MB region; Peripherals

		eor r4, r4
		movt r4, #0x4000		@; 0x40000000; MIN bit-bandable 1MB region; Peripherals

		movw r5, #0x7fff		
		movt r5, #0x2000		@; 0x20007fff; MAX bit-bandable 32KB region; SRAM

		eor r6, r6
		movt r6, #0x2000		@; 0x20000000; MIN bit-bandable 23KB region; SRAM

		eor r7, r7
		movt r7, #0x2200		@; upper bit-band alias value for 32KB region; SRAM

		eor r8, r8
		movt r8, #0x4200		@; upper bit-band alias value for 1MB region; Peripherals	

		sub r9, r1, r6			@; byte offset for 32KB region; SRAM	

		sub r10, r1, r4			@; byte offset for 1MB region; Peripherals	

		mov r11, #32			@; byte offset multiplier	(byte offset * 32) 
		mov r12, #4			@; bit number multiplier	(bit number * 4) 
		
		cmp r1, r3			@; 0x40000000 < a < 0x400fffff 
		bgt .exit\@
		cmp r1, r4			@; 0x40000000 < a < 0x400fffff 
		bge .periph\@ 			

		cmp r1, r5			@; 0x20000000 < a < 0x20007fff 
		bgt .exit\@
		cmp r1, r6			@; 0x20000000 < a < 0x20007fff 
		blt .exit\@

	.sram\@: /* SRAM 32KB region calc */
		/* bit-band alias = bit-band base + (byte offset * 32) + (bit number * 4) */
		mul r9, r11			@; (byte offset * 32)
		mul r2, r12			@; (bit number * 4)  
		add r9, r2			@; (byte offset * 32) + (bit number * 4)
		add r7, r9			@; bit-band base + (byte offset * 32) + (bit number * 4)
		mov r0, r7 
		b .exit\@

	.periph\@: /* Peripherals 1MB region calc */
		/* bit-band alias = bit-band base + (byte offset * 32) + (bit number * 4) */
		mul r10, r11			@; (byte offset * 32)
		mul r2, r12			@; (bit number * 4)  
		add r10, r2			@; (byte offset * 32) + (bit number * 4)
		add r8, r10			@; bit-band base + (byte offset * 32) + (bit number * 4)
		mov r0, r8 

	.exit\@:	.exitm
	.endm

main:
	movw r10, #0xfffc	
	movt r10, #0x400f
	mov r11, #31 

	push {r10}				@; save original value
	calcAlias r10, r11
	mov r2, r0				@; save return value or r0 to r2 for printf
	pop {r1}				@; pop save value to r1 for printf
	bl  _write

_exit:
		mov r7, #1
		svc 0

_write:
	push {lr}
	ldr r0, =fmt
	bl printf
	pop {pc}
