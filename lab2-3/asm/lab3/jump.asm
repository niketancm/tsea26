	.code
	set r0,0x0000
	set r1,0x1111
	set r2,0x2222
	set r3,0x3333
	set r4,0x4444
	nop
	nop
	nop
	jump goto
;;; CALL
next	
	out 0x11,r3
	out 0x11,r4
	ret ds2
	out 0x11,r0
	out 0x11,r1
	out 0x11,r2
;;; Unconditional jump
;; 	jump ds3 next
;; 	out 0x11,r0
;; 	out 0x11,r1
;; 	out 0x11,r2
;; next	
;; 	out 0x11,r3
;; 	out 0x11,r4
	
;; CONDITIONAL JUMP
;; 	sub r0,r1,r1
;; 	jump.eq ds3 next
;; 	out 0x11,r0
;; 	out 0x11,r1
;; 	out 0x11,r2
;; next	
;; 	out 0x11,r3
;; 	out 0x11,r4
goto	
	call next
	out 0x11,r0
	out 0x11,r1
	out 0x11,r2
		
	;;Terminate simulation
	out 0x12,r0
	nop
