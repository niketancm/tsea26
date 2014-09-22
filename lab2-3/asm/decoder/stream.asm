	.ram0
stream_byte_count
	.skip	1
stream_bits_byte_limit
	.skip	1
stream_bit_count
	.skip	1
stream_bits
	.skip	1

	.code
stream_init
	set	r0,0
	nop
	nop
	st0	(stream_byte_count),r0
	ret	ds3
	st0	(stream_bits_byte_limit),r0
	st0	(stream_bit_count),r0
	st0	(stream_bits),r0

stream_get1byte
	;; read another byte and increment stream_byte_count
	in	r0,0x10	;IO_IN
	ld0	r1,(stream_byte_count)
	nop
	and	r0,255
	inc	r1
	ret	ds2
	nop
	st0	(stream_byte_count),r1

stream_bit_init
	;; r1 = number of bytes available
	ret	ds3
	move	r31,r1		; byte count
	set	r30,0		; bit count
	set	r29,0		; bits
	;; r28 is scratch

stream_bit_save_state
	;; save registers to memory
	ret	ds3
	st0	(stream_bits_byte_limit),r31
	st0	(stream_bit_count),r30
	st0	(stream_bits),r29

stream_bit_load_state
	;; load registers from memory
	ret	ds3
	ld0	r31,(stream_bits_byte_limit)
	ld0	r30,(stream_bit_count)
	ld0	r29,(stream_bits)

sbfr_read
	call	ds1 stream_get1byte
	dec	r31
stream_bit_flush_remaining
	;; flush/remove remaining bytes from input
	cmp	0,r31
	jump.ne	sbfr_read
	ret

stream_bits_refill
	;; there are at most 7 bits in the shift register, load 8 more
	;; FIXME: this is quite inefficient
	cmp	0,r31		; at end-of-frame?
	jump.eq	sbr_no_more
	call	stream_get1byte
	set	r2,0xff00	; mask
	sub	r1,8,r30
	nop
	nop
	rol	r2,r1		; align mask
	rol	r0,r1		; align bits
	nop
	and	r29,r2		; make room for new bits
	dec	r31
	ret	ds2
	or	r29,r0		; insert new bits
	add	r30,8
	;; r29 must be available to the caller immediately
sbr_no_more
	ret

	
stream_getbits0
	ret	ds1
	set	r0,0

stream_getbits1
	cmp	0,r30
	jump.ne	sgb1_ok
	call	stream_bits_refill
sgb1_ok
	rol	r29,1
	dec	r30
	ret	ds1
	and	r0,r29,1

stream_getbits2
	cmp	2,r30		; 2-r30, r30>=2 => Z=1 or C=1
	jump.ule sgb2_ok
	call	stream_bits_refill
sgb2_ok
	rol	r29,2
	sub	r30,2
	ret	ds1
	and	r0,r29,3

stream_getbits3
	cmp	3,r30
	jump.ule sgb3_ok
	call	stream_bits_refill
sgb3_ok
	rol	r29,3
	sub	r30,3
	ret	ds1
	and	r0,r29,7

stream_getbits4
	cmp	4,r30
	jump.ule sgb4_ok
	call	stream_bits_refill
sgb4_ok
	rol	r29,4
	sub	r30,4
	ret	ds1
	and	r0,r29,15

stream_getbits5
	cmp	5,r30
	jump.ule sgb5_ok
	call	stream_bits_refill
sgb5_ok
	rol	r29,5
	sub	r30,5
	ret	ds1
	and	r0,r29,31

stream_getbits6
	cmp	6,r30
	jump.ule sgb6_ok
	call	stream_bits_refill
sgb6_ok
	rol	r29,6
	sub	r30,6
	ret	ds1
	and	r0,r29,63

stream_getbits7
	cmp	7,r30
	jump.ule sgb7_ok
	call	stream_bits_refill
sgb7_ok
	rol	r29,7
	sub	r30,7
	ret	ds1
	and	r0,r29,127

stream_getbits8
	cmp	8,r30
	jump.ule sgb8_ok
	call	stream_bits_refill
sgb8_ok
	rol	r29,8
	sub	r30,8
	ret	ds1
	and	r0,r29,255

stream_getbits9
	call	stream_getbits8
	call	ds1 stream_getbits1
	rol	r28,r0,1
	ret	ds1
	or	r0,r28
	
stream_getbits10
	call	stream_getbits8
	call	ds1 stream_getbits2
	rol	r28,r0,2
	ret	ds1
	or	r0,r28

stream_getbits11
	call	stream_getbits8
	call	ds1 stream_getbits3
	rol	r28,r0,3
	ret	ds1
	or	r0,r28

stream_getbits12
	call	stream_getbits8
	call	ds1 stream_getbits4
	rol	r28,r0,4
	ret	ds1
	or	r0,r28

stream_getbits13
	call	stream_getbits8
	call	ds1 stream_getbits5
	rol	r28,r0,5
	ret	ds1
	or	r0,r28

stream_getbits14
	call	stream_getbits8
	call	ds1 stream_getbits6
	rol	r28,r0,6
	ret	ds1
	or	r0,r28

stream_getbits15
	call	stream_getbits8
	call	ds1 stream_getbits7
	rol	r28,r0,7
	ret	ds1
	or	r0,r28

stream_getbits16
	call	stream_getbits8
	call	ds1 stream_getbits8
	rol	r28,r0,8
	ret	ds1
	or	r0,r28
