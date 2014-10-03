	.code


	;; TODO: test the 'add' instruction
	;; ...
	;; set r0,10
	;; set r1,-4
	;; nop
	;; add r0,
	;; out 0x11,r0

	;; TODO: test the 'addc' instruction
	;; ...


	;; TODO: test the 'sub' instruction
	;; ...
	;; set r0,0x000a
	;; set r1,0xffff
	;; nop
	;; sub r0,r1
	;; out 0x11,r0
	;; TODO: test the 'subc' instruction
	;; ...


	;; TODO: test the 'ABS' instruction
	;; ...

	set r0,0x8000		;Largest negative number
	set r1,0x8001
	set r2,0x7fff		;Largest positive number
	set r4,0xffff		;-1
	set r5,5
	set r6,0xfffc 		;-4
	set r3,0
	nop
	abs r3,r0
	out 0x11,r3
	abs r3,r1
	out 0x11,r3
	abs r3,r2
	out 0x11,r3
	abs r3,r4
	out 0x11,r3
	abs r3,r5
	out 0x11,r3
	abs r3,r6
	out 0x11,r3
	
	;; TODO: test the 'cmp' instruction
	;; set	r0,4
	;; set	r1,2485
	;; nop
	;; nop
	;; cmp	r0,r1
	;; nop
	;; nop
	;; move	r0,fl0		; read flags register
	;; nop
	;; nop
	;; out	0x11,r0
	;; ;; ...


	;; TODO: test the 'min' and 'max' instructions
	;; ... only unsigned numbers

	;; Max Operation Test
	set r0,266
	set r1,10
	nop
	max r2,r0,r1
	out 0x11,r2

	set r0,10
	set r1,11
	nop
	max r2,r0,r1
	out 0x11,r2

	set r0,0x7fff
	set r1,0x0000
	nop
	max r2,r0,r1
	out 0x11,r2

	set r0,0x7fff
	set r1,0x7fff
	nop
	max r2,r0,r1
	out 0x11,r2

	;;Min Operation Test
	;; set r0,0x7fff
	;; set r1,0x7fff
	;; nop
	;; min r2,r0,r1
	;; out 0x11,r2

	;; set r0,266
	;; set r1,10
	;; nop
	;; min r2,r0,r1
	;; out 0x11,r2

	;; set r0,10
	;; set r1,11
	;; nop
	;; min r2,r0,r1
	;; out 0x11,r2

	;; set r0,0x7fff
	;; set r1,0x0000
	;; nop
	;; min r2,r0,r1
	;; out 0x11,r2
	
	;; terminate simulation
	out	0x12,r0
	nop
