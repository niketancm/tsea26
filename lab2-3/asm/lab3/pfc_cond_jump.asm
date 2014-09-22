	.code
	set r1,0
	set r2,0x2222
	set r3,0x3333
	set r4,0x4444
	set r5,0x5555
	set r6,0x6666
	set r7,0x7777
	set r8,0x8888
	set r30,0xffff
	jump start
apa
	nop
	nop
	out 0x11,r2
	out 0x11,r3
	out 0x12,r0
start	
	set r0,1
	move fl0,r1
	nop
	nop
	nop
	jump.eq tohere0
	out 0x11,r2
	out 0x11,r3
	out 0x11,r4
	out 0x11,r5
tohere0
	out 0x11,r30
	jump.eq ds1 tohere1
	out 0x11,r2
	out 0x11,r3
	out 0x11,r4
	out 0x11,r5
	out 0x11,r6
tohere1
	out 0x11,r30
	jump.eq ds2 tohere2
	out 0x11,r2
	out 0x11,r3
	out 0x11,r4
	out 0x11,r5
	out 0x11,r6
	out 0x11,r7
tohere2
	out 0x11,r30
	jump.eq ds3 end
	out 0x11,r2
	out 0x11,r3
	out 0x11,r4
	set r1,1
	out 0x11,r5
	out 0x11,r6
	out 0x11,r7
	out 0x11,r8
	jump start
end
	out 0x11,r30
	set r0,apa
	nop
	nop
	jump r0
	out 0x12,r0
	.ram0
foo
	.skip	5

	.rom0
bar
	.dw	0x500
