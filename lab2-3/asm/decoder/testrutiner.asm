clearregs
	nop
	nop
	nop
	set r0,0x0
	set r1,0x0
	set r2,0x0
	set r3,0x0
	set r4,0x0
	set r5,0x0
	set r6,0x0
	set r7,0x0
	set r8,0x0
	set r9,0x0
	set r10,0x0
	set r11,0x0
	set r12,0x0
	set r13,0x0
	set r14,0x0
	set r15,0x0
	set r16,0x0
	set r17,0x0
	set r18,0x0
	set r19,0x0
	set r20,0x0
	set r21,0x0
	set r22,0x0
	set r23,0x0
	set r24,0x0
	set r25,0x0
	set r26,0x0
	set r27,0x0
	set r28,0x0
	set r29,0x0
	set r30,0x0
	set r31,0x0
	set ar0,0
	set ar1,0
	set ar2,0
	set ar3,0
	ret
		
dumpAregs
	nop
	nop
	nop
	nop
	push r0
	push r1
	push r2
	push r3
	set r0,0xadad
	nop
	nop
	nop
	out 0x11,r0
	nop
	nop
	move r0,ar0
	move r1,ar1
	move r2,ar2
	move r3,ar3
	out 0x11,r0
	out 0x11,r1
	out 0x11,r2
	out 0x11,r3
	nop
	nop
	pop r3
	pop r2
	pop r1
	pop r0
	nop
	nop
	nop
	nop
	ret

	
dumpregs
	nop
	nop
	nop
	push r0
	set r0,0xdeaa
	nop
	nop
	nop
	out 0x11,r0		; d
	nop
	nop
	nop
	pop r0
	nop
	nop
	nop
	out 0x11,r0
	out 0x11,r1
	out 0x11,r2
	out 0x11,r3
	out 0x11,r4
	out 0x11,r5
	out 0x11,r6
	out 0x11,r7
	out 0x11,r8
	out 0x11,r9
	out 0x11,r10
	out 0x11,r11
	out 0x11,r12
	out 0x11,r13
	out 0x11,r14
	out 0x11,r15
	out 0x11,r16
	out 0x11,r17
	out 0x11,r18
	out 0x11,r19
	out 0x11,r20
	out 0x11,r21
	out 0x11,r22
	out 0x11,r23
	out 0x11,r24
	out 0x11,r25
	out 0x11,r26
	out 0x11,r27
	out 0x11,r28
	out 0x11,r29
	out 0x11,r30
	out 0x11,r31
	nop
	nop	
	push r0
	set r0,0xdeab
	nop
	nop
	nop
	out 0x11,r0		; d
	nop
	nop
	nop
	pop r0
	nop
	nop
	ret

theend
	nop
	nop
	nop
	out 0x12,r0
hejhopp
	nop
	nop
	jump hejhopp



clearmem
	set	r0,0xff
	nop
	nop
clearmemloop
	st0	(r0),r0
	st1	(r0),r0
	dec	r0
	nop
	nop
	jump.ne	clearmemloop
	ret

dumpmem
	push r0
	push r1
	push r2
	nop
	nop
	set r0,0x1234
	nop
	nop
	out 0x11,r0
	set	r0,0xff
	nop
	nop
dumpmemloop
	ld0	r1,(r0)
	ld1	r2,(r0)
	nop
	nop
	out	0x11,r0		
; 	out	0x11,r1
	out	0x11,r2
	dec	r0
	nop
	nop
	jump.ne	dumpmemloop
	pop r2
	pop r1
	pop r0
	ret


dumpflags
	nop
	nop
	push r0
	set r0,0xffff
	nop
	nop
	out 0x11,r0
	move	r0,fl0
	nop
	nop
	out 0x11,r0
	nop
	nop
	pop r0
	ret


dumpACR
	nop
	nop
	push r0
	nop
	nop
	set r0,0xa0a0
	nop
	nop
	out 0x11,r0
	nop
	nop
	move r0,acr0
	nop
	nop
	nop
	out 0x11,r0		; 
	move r0,mul65536 acr0
	nop
	nop
	nop
	out 0x11,r0		; 
	move r0,acr1
	nop
	nop
	nop
	;out 0x11,r0
	move r0,acr2
	nop
	nop
	nop
	;out 0x11,r0
	move r0,acr3
	nop
	nop
	nop
	;out 0x11,r0
	nop
	nop
	pop r0
	nop
	nop
	ret


dumpdatas
	push r0
	push r1
	set r0,0xdada
	nop
	nop
	nop
	out 0x11,r0
	nop
	nop
	nop
	
	nop
	nop
	nop
	ld0 r0,(ar1)
	ld0 r1,(ar2)
	nop
	nop
	nop
	nop
	out 0x11,r0
	out 0x11,r1
	
	pop r1
	pop r0
	ret

	
dumpall
	call dumpACR		
	call dumpmem	
	call dumpregs
	call dumpAregs
	ret

dumpend
	call	dumpall
	jump	theend

dumpend_afterawhile
	push	r0
	