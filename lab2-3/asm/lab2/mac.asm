	.code

	set	r0,0x2345
	set	r1,0x6789
	nop
	move	acr0.h,r0
	move	acr0.l,r1
	set	guards01,0x0000
	nop
	nop

	move	acr1.h,r0
	move	acr1.l,r1
	nop
	
	; now acr0 = 0x0023456789 and acr0 = 0x0023456789
	addl acr0,acr1,acr0 
	move r0,acr0
	nop
	out	0x11,r0		; Send the result to the IOS0011 file
	;; out	0x11,r1		; so that the result from srsim can be
	;; out	0x11,r2		; compared to that of the RTL code.
	;; out	0x11,r3		; If the results are different, you have
	;; out	0x11,r4		; found a bug in the RTL code.
	;; out	0x11,r5		; ...

	out	0x12,r0
	nop

	