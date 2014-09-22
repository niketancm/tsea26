
	.rom0
l2_bitrate_per_channel
	.dw	0, -1,-1,-1,1, -1,2, 3,  4,  5,  6,  7,  8,  9,  10
l2_quantization_info_table
	;; freq*16+bitrate_per_ch
	.dw	1, 2, 2, 0, 0, 0, 1, 1,  1,  1,  1 ,0,0,0,0,0 ; 44.1
	.dw	0, 2, 2, 0, 0, 0, 0, 0,  0,  0,  0 ,0,0,0,0,0 ; 48
	.dw	1, 3, 3, 0, 0, 0, 1, 1,  1,  1,  1 ,0,0,0,0,0 ; 32
l2_q_line
	;; q*32+sb
	.dw	0,0,0,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,4,4,4,4,4
	.dw	0,0,0,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,4,4
	.dw	5,5,6,6,6,6,6,6,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
	.dw	5,5,6,6,6,6,6,6,6,6,6,6,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
l2_nbal
	;; qline
	.dw	stream_getbits4
	.dw	stream_getbits4
	.dw	stream_getbits3
	.dw	stream_getbits2
	.dw	stream_getbits0
	.dw	stream_getbits4
	.dw	stream_getbits3

l2_quant_method_table
	;; qline*16+alloc
	.dw	l2_mz,l2_m0,l2_m2,l2_m4,l2_m5,l2_m6,l2_m7,l2_m8,l2_m9,l2_m10,l2_m11,l2_m12,l2_m13,l2_m14,l2_m15,l2_m16
	.dw	l2_mz,l2_m0,l2_m1,l2_m2,l2_m3,l2_m4,l2_m5,l2_m6,l2_m7,l2_m8,l2_m9,l2_m10,l2_m11,l2_m12,l2_m13,l2_m16
	.dw	l2_mz,l2_m0,l2_m1,l2_m2,l2_m3,l2_m4,l2_m5,l2_m16,0,0,0,0,0,0,0,0
	.dw	l2_mz,l2_m0,l2_m1,l2_m16,0,0,0,0,0,0,0,0,0,0,0,0
	.dw	l2_mz,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.dw	l2_mz,l2_m0,l2_m1,l2_m3,l2_m4,l2_m5,l2_m6,l2_m7,l2_m8,l2_m9,l2_m10,l2_m11,l2_m12,l2_m13,l2_m14,l2_m15
	.dw	l2_mz,l2_m0,l2_m1,l2_m3,l2_m4,l2_m5,l2_m6,l2_m7,0,0,0,0,0,0,0,0

l2_D_table
	.scale	1.0
	.df	0.50000000000
	.df	0.50000000000
	.df	0.25000000000
	.df	0.50000000000
	.df	0.12500000000
	.df	0.06250000000
	.df	0.03125000000
	.df	0.01562500000
	.df	0.00781250000
	.df	0.00390625000
	.df	0.00195312500
	.df	0.00097656250
	.df	0.00048828125
	.df	0.00024414063
	.df	0.00012207031
	.df	0.00006103516
	.df	0.00003051758

l2_C_table
	.scale	2.0
	.dfu	1.33333333333
	.dfu	1.60000000000
	.dfu	1.14285714286
	.dfu	1.77777777777
	.dfu	1.06666666666
	.dfu	1.03225806452
	.dfu	1.01587301587
	.dfu	1.00787401575
	.dfu	1.00392156863
	.dfu	1.00195694716
	.dfu	1.00097751711
	.dfu	1.00048851979
	.dfu	1.00024420024
	.dfu	1.00012208522
	.dfu	1.00006103888
	.dfu	1.00003051851
	.dfu	1.00001525902

l2_multiple
	.scale	2.0
	.dfu	2.00000000000000, 1.58740105196820, 1.25992104989487, 1.00000000000000
	.dfu	0.79370052598410, 0.62996052494744, 0.50000000000000, 0.39685026299205
	.dfu	0.31498026247372, 0.25000000000000, 0.19842513149602, 0.15749013123686
	.dfu	0.12500000000000, 0.09921256574801, 0.07874506561843, 0.06250000000000
	.dfu	0.04960628287401, 0.03937253280921, 0.03125000000000, 0.02480314143700
	.dfu	0.01968626640461, 0.01562500000000, 0.01240157071850, 0.00984313320230
	.dfu	0.00781250000000, 0.00620078535925, 0.00492156660115, 0.00390625000000
	.dfu	0.00310039267963, 0.00246078330058, 0.00195312500000, 0.00155019633981
	.dfu	0.00123039165029, 0.00097656250000, 0.00077509816991, 0.00061519582514
	.dfu	0.00048828125000, 0.00038754908495, 0.00030759791257, 0.00024414062500
	.dfu	0.00019377454248, 0.00015379895629, 0.00012207031250, 0.00009688727124
	.dfu	0.00007689947814, 0.00006103515625, 0.00004844363562, 0.00003844973907
	.dfu	0.00003051757813, 0.00002422181781, 0.00001922486954, 0.00001525878906
	.dfu	0.00001211090890, 0.00000961243477, 0.00000762939453, 0.00000605545445
	.dfu	0.00000480621738, 0.00000381469727, 0.00000302772723, 0.00000240310869
	.dfu	0.00000190734863, 0.00000151386361, 0.00000120155435, 0


l2_frame_size_table
	;; freq*16+bitrate
	.dw	0, 104, 156, 182, 208, 261, 313, 365, 417, 522, 626,  731,  835, 1044, 1253 ,0
	.dw	0,  96, 144, 168, 192, 240, 288, 336, 384, 480, 576,  672,  768,  960, 1152 ,0
	.dw	0, 144, 216, 252, 288, 360, 432, 504, 576, 720, 864, 1008, 1152, 1440, 1728 ,0

	.ram0
l2_allocation
	;; sb*2+ch
	.skip	64
l2_scfsi
	;; sb*2+ch
	.skip	64
l2_scf
	;; [gr/4][sb][ch]
	;; gr_div_4*64+sb*2+ch
	.skip	192		; 3*32*2

	.ram1
l2_xr
	;; [sample][ch][sb]
	;; sample*64+ch*32+sb
	.skip	192		; 3*2*32

	.ram1
l2_pcm_l
	.skip	32
l2_pcm_r
	.skip	32

	.code
;; ----------------------------------------
layer2_decode
;;; ----------------------------------------
	set	ar0,l2_bitrate_per_channel
	ld0	r4,(stream_byte_count)
	ld0	r5,(g_hd_padding)
	ld0	r0,(g_hd_bitrate) ; r0 = bitrate
	ld0	r1,(g_hd_ch_mode)
	sub	r4,r5
	ld0	r2,(g_hd_freq)
	ld0	r3,(ar0,r0)	; bitrate_per_ch (if ch>1)
	set	ar1,l2_quantization_info_table
	lsl	r2,4		; freq*16
	cmp	3,r1		; ch_mode == MODE_SINGLE_CHANNEL
	move.eq	r3,r0		; yes, r3 = bitrate_per_ch = bitrate

	add	r0,r2		; r0 = freq*16+bitrate
	set	ar0,l2_frame_size_table
	add	r3,r2		; r3 = freq*16+bitrate_per_ch
	st1	(--ar3),r8
	st1	(--ar3),r9
	ld0	r1,(ar0,r0)	; frame_size
	ld0	r8,(ar1,r3)	; r8 = q
	call	ds3 stream_bit_init
	st1	(--ar3),r10
	sub	r1,r1,r4	; frame_size+padding-stream_byte_count
	;; r1 = number of bytes remaining in frame (frame_size+padding-stream_byte_count)
	st1	(--ar3),r11

	;; r8 = q

	lsl	r0,r8,5
	set	r9,l2_q_line
	set	r10,32		; r10 = is_bound
	ld0	r1,(g_hd_ch_mode_ext)
	add	r9,r0		; r9 = &q_line[q][0]
	set	step1,1
	lsl	r1,2

	move	ar2,r9		; ar2 = &q_line[q][0]
	nop			; FIXME: RTL does not allow prev and next insn together
	st1	(--ar3),r12

	add	r1,4		; r1 = ch_mode_ext*4+4

	;; r9 = &q_line[q][0]
	;; r10 = is_bound (32)
	;; r1 = ch_mode_ext*4+4

	set	ar1,l2_allocation
	ld0	r0,(g_hd_ch_mode)
	ld0	r2,(ar2++)	; q_l
	set	r11,0		; sb
	cmp	1,r0
	jump.eq	l2_joint_stereo
	cmp	3,r0
	jump.eq	l2_single_channel

	;; r9 = &q_line[q][0]
	;; r10 = is_bound
	;; r11 = sb
	;; r1 = ch_mode_ext*4+4
	
	;; stereo/dual channel
l2_stereo_dual
l2_stereo_dual_loop
	set	ar0,l2_nbal
	nop
	nop
	ld0	r12,(ar0,r2)	; &stream_getbits(nbal)
	inc	r11
	nop
	call	r12

	call	ds2 r12
	nop
	st0	(ar1++),r0

	cmp	32,r11
	jump.ne	ds2 l2_stereo_dual_loop
	ld0	r2,(ar2++)	; q_l
	st0	(ar1++),r0

	jump	l2_got_allocation

l2_joint_stereo
	;; r1 = ch_mode_ext*4+4
	move	r10,r1		; correct is_bound
l2_joint_stereo_loop
	set	ar0,l2_nbal
	nop
	nop
	ld0	r12,(ar0,r2)	; &stream_getbits(nbal)
	inc	r11
	nop
	call	r12

	call	ds2 r12
	nop
	st0	(ar1++),r0

	cmp	r11,r10
	jump.ne	ds2 l2_joint_stereo_loop
	ld0	r2,(ar2++)	; q_l
	st0	(ar1++),r0

l2_joint_stereo_loop2
	set	ar0,l2_nbal
	nop
	nop
	ld0	r0,(ar0,r2)	; &stream_getbits(nbal)
	inc	r11
	nop
	call	r0

	cmp	32,r11
	jump.ne	ds3 l2_joint_stereo_loop2
	st0	(ar1++),r0
	ld0	r2,(ar2++)	; q_l
	st0	(ar1++),r0

	jump	l2_got_allocation

l2_single_channel
	;; r1 already loaded
	set	r12,0
l2_single_channel_loop
	set	ar0,l2_nbal
	nop
	nop
	ld0	r0,(ar0,r2)	; &stream_getbits(nbal)
	inc	r11
	nop
	call	r0

	st0	(ar1++),r0

	cmp	32,r11
	jump.ne	ds2 l2_single_channel_loop
	ld0	r2,(ar2++)	; q_l
	st0	(ar1++),r12	; allocation[1][:] = 0


l2_got_allocation
	;; r9 = &q_line[q][0]
	;; r10 = is_bound
	;; ...

	st1	(--ar3),r13
	st1	(--ar3),r14
	st1	(--ar3),r15
	st1	(--ar3),r16
	st1	(--ar3),r17

	set	r11,0
	set	ar2,l2_allocation
	set	ar1,l2_scfsi
	set	r13,stream_getbits2

	;; ...
	;; r11 = sb
	;; ar1 => scfsi
	;; ar2 => allocation

l2_get_scfsi_loop
	ld0	r0,(ar2++)
	ld0	r12,(ar2++)
	set	r1,stream_getbits0
	cmp	0,r0
	move.ne	r1,r13
	nop
	nop
	call	r1

	set	r1,stream_getbits0
	cmp	0,r12
	st0	(ar1++),r0
	move.ne	r1,r13
	nop
	inc	r11
	call	r1
	
	cmp	32,r11
	jump.ne	ds1 l2_get_scfsi_loop
	st0	(ar1++),r0


	;; scf loop

	;; r9 = &q_line[q][0]
	;; r10 = is_bound

	set	ar1,l2_allocation
	set	ar2,l2_scfsi

	set	r12,0		; sb
l2_get_scf_loop_sb
	set	r11,0		; ch
l2_get_scf_loop_ch
l2_get_scf_loop_entry
	ld0	r0,(ar1++)
	ld0	r1,(ar2++)
	inc	r11
	cmp	0,r0
	jump.eq	l2_get_scf_loop_ch_continue

	cmp	0,r1
	jump.eq	l2_scfsi_is_0
	cmp	1,r1
	jump.eq	l2_scfsi_is_1
	cmp	2,r1
	jump.eq	l2_scfsi_is_2

	;; scfsi == 3
	call	stream_getbits6
	call	ds1 stream_getbits6
	st0	(ar2,63),r0
	jump	ds2 l2_scfsi_switch_break
	st0	(ar2,127),r0
	st0	(ar2,191),r0

l2_scfsi_is_0
	call	stream_getbits6
	call	ds1 stream_getbits6
	st0	(ar2,63),r0
	call	ds1 stream_getbits6
	st0	(ar2,127),r0
	jump	ds1 l2_scfsi_switch_break
	st0	(ar2,191),r0

l2_scfsi_is_1
	call	stream_getbits6
	call	ds2 stream_getbits6
	st0	(ar2,63),r0
	st0	(ar2,127),r0
	jump	ds1 l2_scfsi_switch_break
	st0	(ar2,191),r0

l2_scfsi_is_2
	call	stream_getbits6
	st0	(ar2,63),r0
	st0	(ar2,127),r0
	st0	(ar2,191),r0
	;; fall through

l2_scfsi_switch_break
l2_get_scf_loop_ch_continue
	ld0	r0,(g_hd_channels)
	move	r1,ar1
	move	r2,ar2
	cmp	r11,r0
	jump.ne	l2_get_scf_loop_ch

	set	r3,1
	inc	r12
	cmp	1,r0
	addn.eq	r1,r3
	addn.eq	r2,r3
	cmp	32,r12
	jump.ne	ds2 l2_get_scf_loop_sb
	move	ar1,r1
	move	ar2,r2
	
	;; --------

	;; r9 = &q_line[q][0]
	;; r10 = is_bound

	;; for(gr_div_4 = 0; gr_div_4 < 3; gr_div_4++) {
	;; for(gr_mod_4 = 0; gr_mod_4 < 4; gr_mod_4++) {
	;; for(sb = 0; sb < 32; sb++) {
	;; for(ch = 0; ch < channels; ch++) {
	;; (for sample=0..2)

	;; observera att värdena i sampels[3] återanvänds för andra kanalen om joint stereo och >is_bound !

	; scf[gr_div_4*64 + sb*2 + ch]
	; xr[sample*64 + ch*32 + sb]


	;; xr[][][] ligger i ram1


	set	r11,0		; gr_div_4*64
l2_bigloop_gr_div_4
	set	r12,0		; gr_mod_4
l2_bigloop_gr_mod_4
	set	r13,0		; sb
l2_bigloop_sb
	set	r0,l2_xr
	set	r14,0		; ch
	set	r15,0
	add	r0,r13
	set	r16,0
	set	r17,0
	move	ar2,r0
	lsl	r8,r13,1
l2_bigloop_ch

	;; r9 = &q_line[q][0(sb)]
	;; r10 = is_bound
	;; r11 = gr_div_4*64
	;; r12 = gr_mod_4
	;; r13 = sb
	;; r14 = ch
	;; r15,r16,r17 = sample values
	;; r8 = sb*2+ch (index i allocation)
	;; ar2 => xr+sample*64+ch*32+sb

	move	ar1,r13		; sb
	set	ar0,l2_allocation
	nop
	ld0	r1,(ar1,r9)	; q_l = q_line[q][sb]
	ld0	r0,(ar0,r8)
	nop
	lsl	r1,4
	nop
	set	ar0,l2_quant_method_table
	add	r0,r1		; r0 = q_l*16+allocation[q][sb]
	nop
	nop
	ld0	r0,(ar0,r0)
	nop

	cmp	0,r14
	jump.eq	r0

	cmp	r13,r10		; sb-is_bound (negative => sb < is_bound)
	jump.mi	r0
	jump	l2_bigloop_same_as_other_channel

l2_mz
	set	r0,0
	set	r1,0
	set	r2,0
	jump	ds3 l2_bigloop_save_samples
	set	r15,0
	set	r16,0
	set	r17,0
	
l2_m0
	;; grouping=3, bits=5, shift=15-1
	call	stream_getbits5
	;; div/mod by 3 three times
	;; value is 0..31
	call	ds2 l2_do_divmod
	set	r2,21846
	set	r1,3
	jump	ds2 l2_bigloop_do_D_C_multiple
	set	r0,15
	set	r1,0

l2_do_divmod
	;; r0 = sample values (grouped)
	;; r1 = 3, 5, or 9
	;; r2 = 1 + 65536/{3, 5, or 9}
	muluu	acr0,r0,r2	; a = |_ s/x _|
	move	r3,acr0		; a
	nop
	nop
	nop
	nop
	muluu	acr1,r3,r2	; s2 = |_ a/x _|
	move	r17,acr1	; s2 = |_ a/x _|
	muluu	acr0,r3,r1	; a * x
	move	r15,mul65536 acr0 ; a * x
	nop
	nop
	nop
	muluu	acr2,r17,r1	; s2 * x
	move	r16,mul65536 acr2
	ret	ds3
	sub	r15,r0,r15	; s - a * x
	nop
	sub	r16,r3,r16

l2_m1
	;; grouping=5, bits=7, shift=15-2
	call	stream_getbits7
	;; div/mod by 5 three times
	;; value is 0..127
	call	ds2 l2_do_divmod
	set	r2,13108	; FIXME: does this always work?
	set	r1,5
	jump	ds2 l2_bigloop_do_D_C_multiple
	set	r0,13
	set	r1,1

l2_m2
	;; bits=3*3, shift=15-2
	call	stream_getbits3
	call	ds1 stream_getbits3
	move	r15,r0
	call	ds1 stream_getbits3
	move	r16,r0
	jump	ds3 l2_bigloop_do_D_C_multiple
	move	r17,r0
	set	r0,13
	set	r1,2

l2_m3
	;; grouping=9, bits=10, shift=15-3
	call	stream_getbits10
	;; div/mod by 9 three times
	;; value is 0..1023
	call	ds2 l2_do_divmod
	set	r2,7282		; FIXME: does this always work?
	set	r1,9
	jump	ds2 l2_bigloop_do_D_C_multiple
	set	r0,12
	set	r1,3

l2_m4
	;; bits=4*3, shift=15-3
	call	stream_getbits4
	call	ds1 stream_getbits4
	move	r15,r0
	call	ds1 stream_getbits4
	move	r16,r0
	jump	ds3 l2_bigloop_do_D_C_multiple
	move	r17,r0
	set	r0,12
	set	r1,4

l2_m5
	;; bits=5*3, shift=15-4
	call	stream_getbits5
	call	ds1 stream_getbits5
	move	r15,r0
	call	ds1 stream_getbits5
	move	r16,r0
	jump	ds3 l2_bigloop_do_D_C_multiple
	move	r17,r0
	set	r0,11
	set	r1,5

l2_m6
	;; bits=6*3, shift=15-5
	call	stream_getbits6
	call	ds1 stream_getbits6
	move	r15,r0
	call	ds1 stream_getbits6
	move	r16,r0
	jump	ds3 l2_bigloop_do_D_C_multiple
	move	r17,r0
	set	r0,10
	set	r1,6

l2_m7
	;; bits=7*3, shift=15-6
	call	stream_getbits7
	call	ds1 stream_getbits7
	move	r15,r0
	call	ds1 stream_getbits7
	move	r16,r0
	jump	ds3 l2_bigloop_do_D_C_multiple
	move	r17,r0
	set	r0,9
	set	r1,7

l2_m8
	;; bits=8*3, shift=15-7
	call	stream_getbits8
	call	ds1 stream_getbits8
	move	r15,r0
	call	ds1 stream_getbits8
	move	r16,r0
	jump	ds3 l2_bigloop_do_D_C_multiple
	move	r17,r0
	set	r0,8
	set	r1,8

l2_m9
	;; bits=9*3, shift=15-8
	call	stream_getbits9
	call	ds1 stream_getbits9
	move	r15,r0
	call	ds1 stream_getbits9
	move	r16,r0
	jump	ds3 l2_bigloop_do_D_C_multiple
	move	r17,r0
	set	r0,7
	set	r1,9

l2_m10
	;; bits=10*3, shift=15-9
	call	stream_getbits10
	call	ds1 stream_getbits10
	move	r15,r0
	call	ds1 stream_getbits10
	move	r16,r0
	jump	ds3 l2_bigloop_do_D_C_multiple
	move	r17,r0
	set	r0,6
	set	r1,10

l2_m11
	;; bits=11*3, shift=15-10
	call	stream_getbits11
	call	ds1 stream_getbits11
	move	r15,r0
	call	ds1 stream_getbits11
	move	r16,r0
	jump	ds3 l2_bigloop_do_D_C_multiple
	move	r17,r0
	set	r0,5
	set	r1,11

l2_m12
	;; bits=12*3, shift=15-11
	call	stream_getbits12
	call	ds1 stream_getbits12
	move	r15,r0
	call	ds1 stream_getbits12
	move	r16,r0
	jump	ds3 l2_bigloop_do_D_C_multiple
	move	r17,r0
	set	r0,4
	set	r1,12

l2_m13
	;; bits=13*3, shift=15-12
	call	stream_getbits13
	call	ds1 stream_getbits13
	move	r15,r0
	call	ds1 stream_getbits13
	move	r16,r0
	jump	ds3 l2_bigloop_do_D_C_multiple
	move	r17,r0
	set	r0,3
	set	r1,13

l2_m14
	;; bits=14*3, shift=15-13
	call	stream_getbits14
	call	ds1 stream_getbits14
	move	r15,r0
	call	ds1 stream_getbits14
	move	r16,r0
	jump	ds3 l2_bigloop_do_D_C_multiple
	move	r17,r0
	set	r0,2
	set	r1,14

l2_m15
	;; bits=15*3, shift=15-14
	call	stream_getbits15
	call	ds1 stream_getbits15
	move	r15,r0
	call	ds1 stream_getbits15
	move	r16,r0
	jump	ds3 l2_bigloop_do_D_C_multiple
	move	r17,r0
	set	r0,1
	set	r1,15

l2_m16
	;; bits=16*3, shift=15-15
	call	stream_getbits16
	call	ds1 stream_getbits16
	move	r15,r0
	call	ds1 stream_getbits16
	move	r16,r0
	jump	ds3 l2_bigloop_do_D_C_multiple
	move	r17,r0
	set	r0,0
	set	r1,16

	
l2_bigloop_do_D_C_multiple
	;; r0 = shift amount
	;; r1 = offset into D&C table (= qs)

	set	ar0,l2_D_table
	set	ar1,l2_C_table
	set	r2,0x8000
	lsl	r15,r0
	lsl	r16,r0
	lsl	r17,r0
	ld0	r3,(ar0,r1)
	ld0	r4,(ar1,r1)
	xor	r15,r2		; invert msb as according to spec
	xor	r16,r2
	xor	r17,r2
	adds	r15,r3		; +D[qs]
	adds	r16,r3
	adds	r17,r3
	mulsu	acr0,r15,r4	; *C[qs] (need to do *2.0)
	mulsu	acr1,r16,r4
	mulsu	acr2,r17,r4
	move	r15,sat rnd mul2 acr0
	move	r16,sat rnd mul2 acr1
	move	r17,sat rnd mul2 acr2
	nop

l2_bigloop_same_as_other_channel
	add	r0,r11,r8	; gr_div_4*64 + sb*2 + ch
	set	ar0,l2_scf
	nop
	nop
	ld0	r0,(ar0,r0)
	set	ar0,l2_multiple
	nop
	nop
	ld0	r0,(ar0,r0)
	nop
	nop
	mulsu	acr0,r15,r0	; *multiple[scf]
	mulsu	acr1,r16,r0
	mulsu	acr2,r17,r0
	move	r0,sat rnd div8 acr0 ; FIXME - scaling!
	move	r1,sat rnd div8 acr1
	move	r2,sat rnd div8 acr2
	nop
	nop

l2_bigloop_save_samples
	st1	(ar2,0),r0
	st1	(ar2,64),r1
	st1	(ar2,128),r2

	;; next ch
	move	r1,ar2
	ld0	r0,(g_hd_channels)
	inc	r14		; ch
	add	r1,32
	inc	r8		; sb*2+ch
	cmp	r14,r0
	jump.ne	ds1 l2_bigloop_ch
	move	ar2,r1

l2_bigloop_next_sb
	;; next sb
	cmp	31,r13
	jump.ne	ds1 l2_bigloop_sb
	inc	r13

	;; run subband synthesis etc

	;; r9 = &q_line[q][0(sb)]
	;; r10 = is_bound
	;; r11 = gr_div_4*64
	;; r12 = gr_mod_4
	;; r13 = s
	;; r14 = ch

	call	stream_bit_save_state

	ld0	r0,(g_hd_channels)
	set	r8,l2_xr
	set	r13,0
	cmp	1,r0
	jump.eq	l2_out_mono

l2_out_stereo_loop
	;; r8 = xr+s*64+ch*32
	call	subband_synthesis_update_V0

	call	ds3 subband_synthesis
	move	r1,r8		; &samples[32]
	set	r2,0		; ch
	set	r3,l2_pcm_l	; &pcm[32]

	call	ds3 subband_synthesis
	add	r1,r8,32	; &samples[32]
	set	r2,1		; ch
	set	r3,l2_pcm_r	; &pcm[32]

	call	ds2 output_pcm
	set	r1,l2_pcm_l
	set	r2,l2_pcm_r

	cmp	2,r13
	jump.ne	ds2 l2_out_stereo_loop
	add	r8,64
	inc	r13

	jump	l2_out_done

l2_out_mono
l2_out_mono_loop
	;; xr+s*64+ch*32

	call	subband_synthesis_update_V0

	call	ds3 subband_synthesis
	move	r1,r8		; &samples[32]
	set	r2,0		; ch
	set	r3,l2_pcm_l	; &pcm[32]

	call	ds2 output_pcm
	set	r1,l2_pcm_l
	set	r2,l2_pcm_l

	cmp	2,r13
	jump.ne	ds2 l2_out_mono_loop
	add	r8,64
	inc	r13

l2_out_done
	call	stream_bit_load_state

	;; next gr_mod_4
	cmp	3,r12
	jump.ne	ds1 l2_bigloop_gr_mod_4
	inc	r12

	;; next gr_div_4
	cmp	128,r11
	jump.ne ds1 l2_bigloop_gr_div_4
	add	r11,64

	ld1	r17,(ar3++)
	ld1	r16,(ar3++)
	ld1	r15,(ar3++)
	ld1	r14,(ar3++)
	ld1	r13,(ar3++)
	ld1	r12,(ar3++)
	ld1	r11,(ar3++)
	jump	ds3 stream_bit_flush_remaining
	ld1	r10,(ar3++)
	ld1	r9,(ar3++)
	ld1	r8,(ar3++)
