	.code

	;; put some nice constants into some registers
	set r0,0x0000
	set r1,0x1111
	set r2,0x2222
	set r3,0x3333

	;; output the registers
	out 0x11,r0
	out 0x11,r1
	out 0x11,r2
	out 0x11,r3

	;; terminate simulation
	out 0x12,r0
	nop
