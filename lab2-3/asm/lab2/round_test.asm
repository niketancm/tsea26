	.code
	;; Positive number as input
	set	r0,0x2345
	set	r1,0x0000
	;; Load both the number into the accumulator
	move	acr0.h,r0
	move	acr0.l,r1
	set	guards01,0x0000 
	nop
	nop
	;; move	acr2.h,r2
	;; move	acr2.l,r3
	;; set	guards23,0xffff
	;; nop
	;; nop
	
	; now acr0 = 0x0023458000 and acr2 = 0xffffff0000
	move	r3, rnd acr0		
	nop


	out	0x11,r3		; so that the result from srsim can be
	;; out	0x11,r2		; compared to that of the RTL code.
	;; End simulation.
	out	0x12,r0
	nop
