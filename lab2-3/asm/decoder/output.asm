
	.code

output_pcm
	;; r1 => left channel buffer in ram0, 32 samples
	;; r2 => right channel buffer in ram0, 32 samples
	;; r1==r2 if mono
	;; r8-r15 and ar3 must be preserved

	;; FIXME

	move	ar2,r1
	move	ar1,r2
	set	step1,1

	repeat	output_pcm_loop,16
	ld1	r0,(ar2++)
	ld1	r1,(ar1++)
	ld1	r2,(ar2++)
	ld1	r3,(ar1++)

	nop
	nop
	nop
	nop
	out	0x11,r0		; IO_OUT
	out	0x11,r1
	out	0x11,r2
	out	0x11,r3
output_pcm_loop

	ret
