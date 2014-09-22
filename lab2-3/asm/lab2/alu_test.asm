	.code


	;; TODO: test the 'add' instruction
	;; ...


	;; TODO: test the 'addc' instruction
	;; ...


	;; TODO: test the 'sub' instruction
	;; ...


	;; TODO: test the 'subc' instruction
	;; ...


	;; TODO: test the 'abs' instruction
	;; ...


	;; TODO: test the 'cmp' instruction
	set	r0,4
	set	r1,2485
	nop
	nop
	cmp	r0,r1
	nop
	nop
	move	r0,fl0		; read flags register
	nop
	nop
	out	0x11,r0
	;; ...


	;; TODO: test the 'min' and 'max' instructions
	;; ...


	;; terminate simulation
	out	0x12,r0
	nop
