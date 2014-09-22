	.ram1
	.skip	128
stack
	
	.code

	call clearregs
	call clearmem
	nop
	nop
	nop
	set r0,0xfa10
	set r1,0x0
	nop
	nop
	st0 (r0),r1
	nop
	nop

main
	nop
	nop
	set	ar3,stack
	call	stream_init

main_loop
	call	read_header
	call	layer2_decode

	set	r0,0xfa10
	nop
	nop
	ld0	r1,(r0)
	nop
	nop
	inc	r1
	nop
	nop
 	out	0x22,r1
	st0	(r0),r1
	cmp	5,r1

   	jump.ne	main_loop
;     	jump	main_loop

	out	0x12,r0
	nop
	nop
	nop
