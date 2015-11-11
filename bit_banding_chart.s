/*	David @InfinitelyManic
	bit_banding_chart.s
	Generates map between SRAM address and corresponding bit-band address for Cortex-M 
	gcc -g bit_banding_chart.s -o bit_banding_chart
	# uname -a
	Linux debian-armhf 3.2.0-4-vexpress #1 SMP Debian 3.2.51-1 armv7l GNU/Linux
*/
.bss
.data
	fmt:	.asciz			"SRAM Addr: 0x%x Bit[%d] Bit-Band Alias Addr= 0x%x \n"
	.equ 	SRAM_Addr_start,	0x20000000
	.equ 	SRAM_Addr_end,		0x21ffffff
	.equ 	BIT_BAND_Addr_start,	0x22000000
	.equ 	BITn_MAX,		31
	.equ 	BYTE_MULTI,		0x4

.text
	.global main
	.func main
main:
	/*
	r0 = fmt
	r1 = SRAM start address
	r2 = 0-31 bit counter; just for display 
	r3 = calculated SRAM BIT-BAND alias address; printf
	r4 = SRAM BIT-BAND alias starting address  
	r5 = continous bit counter 0...31...inf  
	r6 = temp variable
	r10 = SRAM_Addr_end
	r11 = BYTE_MULTI
	*/
	nop
	mov r1, 	#SRAM_Addr_start 	@; printf
	eor r2,	r2				/* counter for bit number; reset after end of loop */
	eor r3, r3				/* printf BIT_BAND_Addr alias */
	mov r4,		#BIT_BAND_Addr_start
	eor r5,	r5				/* counter for continious bit number; do not reset */
	mov r10,	#SRAM_Addr_end
	mov r11, 	#BYTE_MULTI
	.loop0:
		eor r2,	r2			/* counter for bit number; reset after end of loop */
		.loop1:
		/* ****** do something *********/	
			mul r6, r5, r11		
			add r3, r4, r6
			bl write
		/* ****** done something *******/
		add r5, #1
		add r2, #1
		cmp r2, #BITn_MAX
		ble .loop1
	add r1, #1
	cmp r1, r10
	ble .loop0

exit:
	mov r7, #1
	svc 0

write:
	push {r0-r5,lr}
	ldr r0, =fmt
	bl printf
	pop {r0-r5, pc}
