	.code
	set sp,0x7000
	set r2,0xaaaa
	set r3,0xffff
	set r10,0xbeef
	set r11,0xdead
	jump start
apa0
	push r10
	set r10,0xffff
	set r1,0xa000
	nop
	nop
	out 0x11,r1
	pop r10
	ret
	out 0x11,r3
apa1
 	push r10
 	set r10,0xffff
 	set r1,0xa001
 	nop
 	nop
 	out 0x11,r1
 	pop r10
	ret ds1
    	pop r11
	out 0x11,r3
apa2
	push r10
	set r10,0xffff
	set r1,0xa002
	nop
	nop
	out 0x11,r1
	pop r10
	ret ds2
	out 0x11,r2
	pop r11
	out 0x11,r3
apa3
	push r10
	set r10,0xffff
	set r1,0xa003
	nop
	nop
	out 0x11,r1
	pop r10
	ret ds3
	pop r11
	out 0x11,r2	
	out 0x11,r2
	out 0x11,r3
test	
 	push r11
 	set r11,0xffff
	call apa0
 	pop r11
	nop
	nop
 	push r11
 	call ds1 apa1
 	set r11,0xffff
 	nop
 	push r11
 	call ds2 apa2	
 	set r11,0xffff
 	nop
	nop
 	push r11
 	call ds3 apa3
 	set r11,0xffff
 	nop
	nop
 	out 0x11,r2
 	out 0x11,r10
 	out 0x11,r11
	ret
start
	call test
	
	out 0x12,r0
	.ram0
foo
	.skip	5

	.rom0
bar
	.dw	0x500
