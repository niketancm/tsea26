	.ram0
g_header
g_hd_bitrate
	.skip	1
g_hd_freq
	.skip	1
g_hd_padding
	.skip	1
g_hd_ch_mode
	.skip	1
g_hd_channels
	.skip	1
g_hd_ch_mode_ext
	.skip	1

	.code

	;; calling convention:
	;;   r0 = return value
	;;   r1,r2,... = args
	;;   ar0,r0..r7 = caller save
	;;   ar1-3,r8..r31 = callee save

	;; ar3 = sw stack in dm0


;;; ----------------------------------------
read_header
;;; ----------------------------------------
	;; find sync word
	call	ds2 stream_get1byte
	st1	(--ar3),r8
	st1	(--ar3),r9

	cmp	0,r0
	jump.ne	ds1 read_header1
	move	r8,r0

	;; stop
	out	0x12,r0
	
read_header1
	call	ds1 stream_get1byte
	lsl	r8,r8,8

	or	r8,r0
	nop
	nop
	and	r0,r8,-8	; 0xfff8
	and	r1,r8,6
	set	r2,2		; 2 header bytes read
	cmp	-8,r0		; 0xfff8
	jump.ne	read_header1
	cmp	4,r1		; layer 2?
	jump.ne	read_header1

	st0	(stream_byte_count),r2

	and	r9,r8,1		; r9 = ! use crc

	call	stream_get1byte
	call	ds1 stream_get1byte
	lsl	r8,r0,8

	or	r8,r0
	set	ar2,g_header
	set	r5,2

	lsr	r1,r8,12
	lsr	r2,r8,10
	lsr	r3,r8,9
	lsr	r4,r8,6
	lsr	r6,r8,4
	set	r8,1
	and	r1,15
	and	r2,3
	and	r3,1
	and	r4,3
	and	r6,3
	st0	(ar2++),r1	; bitrate
	cmp	3,r4		; mode_single_channel
	move.eq	r5,r8		; channels (1 or 2)
	st0	(ar2++),r2	; freq
	st0	(ar2++),r3	; padding
	cmp	0,r9		; use crc?
	jump.ne	ds3 read_header2; no, skip it
	st0	(ar2++),r4	; ch_mode
	st0	(ar2++),r5	; channels
	st0	(ar2++),r6	; ch_mode_ext

	;; read and throw away CRC
	call	stream_get1byte
	call	stream_get1byte

read_header2
	ret	ds2
	ld1	r9,(ar3++)
	ld1	r8,(ar3++)
;;; ----------------------------------------
