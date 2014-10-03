	.code

	;; TODO: test the 'add' instruction
	;; ...
	;; set r0,10
	;; nop
	;; add r0,4		        ;add 10+4
	;; out 0x11,r0	

	;; set r1,0x7fff		;set r1 to largest positive number.
	;; nop
	;; add r1,0x0001 		;add 1 to largest positive number, causes overflow.
	;; out 0x11,r1

	;; set r2,0x8000		;set r2 to largest negative number
	;; nop
	;; add r2,0x0002		;add 2 to r2.
	;; out 0x11,r10
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; These conditions are not working!! -ve + -ve
	
	;; set r2,0x8000		;set r2 to largest negative number
	;; nop
	;; add r2,0xffff		;add -1 to r2, to cause overflow.
	;; out 0x11,r2

	;; set r2,0xfff6		;set r2 to a -2
	;; nop
	;; add r2,0xfffc		;add -4 to r2, to cause overflow.
	;; out 0x11,r2
	
	
	;; TODO: test the 'addc' instruction
	;; ...

	;; set r0,10
	;; nop
	;; addc r0,4		        ;add 10+4
	;; out 0x11,r0	

	;; set r1,0x7fff		;set r1 to largest positive number.
	;; nop
	;; addc r1,0x0001 		;add 1 to largest positive number, causes overflow.
	;; out 0x11,r1

	set r2,0x8000		;set r2 to largest negative number
	nop
	addc r2,0x0002		;add 2 to r2.
	out 0x11,r2
	
	;; TODO: test the 'sub' instruction
	;; ...
	;; set r0,0x000a ;set r0 to 10	
	;; set r1,0xffff ;-1 to r1
	;; nop
	;; sub r0,r1 ;should be 11
	;; out 0x11,r0

	;; set r0,0x000a ;set r0 to 10	
	;; set r1,0x8000 ;both adder part and the sub part is activated.
	;; nop
	;; sub r0,r1 
	;; out 0x11,r0

	;; set r0,0x7fff ;set r0 to largest +ve number	
	;; set r1,0xfffc ;-4
	;; nop
	;; sub r0,r1 ;add part of the vhdl code is activated. why?
	;; out 0x11,r0

	;; set r0,5 
	;; set r1,10
	;; nop
	;; sub r0,r1
	;; out 0x11,r0

	
	;; TODO: test the 'subc' instruction
	;; ...

	set r0,0x000a ;set r0 to 10	
	set r1,0xffff ;-1 to r1
	nop
	subc r0,r1 ;should be 11
	out 0x11,r0


	;; TODO: test the 'ABS' instruction
	;; ...

	;; set r0,0x8000		;Largest negative number
	;; set r1,0x8001
	;; set r2,0x7fff		;Largest positive number
	;; set r4,0xffff		;-1
	;; set r5,5
	;; set r6,0xfffc 		;-4
	;; set r3,0
	;; nop

	;; abs r3,r0
	;; out 0x11,r3
	;; abs r3,r1
	;; out 0x11,r3
	;; abs r3,r2
	;; out 0x11,r3
	;; abs r3,r4
	;; out 0x11,r3
	;; abs r3,r5
	;; out 0x11,r3
	;; abs r3,r6
	;; out 0x11,r3


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
	;; set r0,266
	;; set r1,10
	;; nop
	;; max r2,r0,r1
	;; out 0x11,r2

	;; set r0,10
	;; set r1,11
	;; nop
	;; max r2,r0,r1
	;; out 0x11,r2

	;; set r0,0x7fff
	;; set r1,0x0000
	;; nop
	;; max r2,r0,r1
	;; out 0x11,r2

	;; set r0,0x7fff
	;; set r1,0x7fff
	;; nop
	;; max r2,r0,r1
	;; out 0x11,r2

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
