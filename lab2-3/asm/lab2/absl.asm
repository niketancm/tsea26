	.code
	;; Positive number as input
	set	r0,0x2345
	set	r1,0x6789
	;; negative number as input
	;; set	r2,0xffff
	;; set	r3,0x0000
	;; special case with largest negative number
	set	r2,0x8000
	set	r3,0x0000
	;; Load both the number into the accumulator
	move	acr0.h,r0
	move	acr0.l,r1
	set	guards01,0x0000 
	nop
	nop
	move	acr2.h,r2
	move	acr2.l,r3
	set	guards23,0xffff
	nop
	nop
	
	; now acr0 = 0x0023456789 and acr2 = 0xffffff0000
	absl 	acr1,acr0
	absl	acr3,acr2
	move	r1,acr1		
	move	r2,acr3
	nop


	out	0x11,r1		; so that the result from srsim can be
	out	0x11,r2		; compared to that of the RTL code.
	;; End simulation.
	out	0x12,r0
	nop
