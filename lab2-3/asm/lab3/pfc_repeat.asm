	.code
	set r2,0xaaaa
	set r3,0xffff
 	jump start
apa0
	set r11,0xa000
	set r12,0xa010
	set r13,0xa020
	set r14,0xdead
	nop
	nop
	repeat le0,1 
	out 0x11,r11
le0
 	out 0x11,r14
	repeat le00,2 
	out 0x11,r12
le00
	out 0x11,r14
	repeat le000,3 
	out 0x11,r13
le000
	out 0x11,r14
	ret
	out 0x11,r3
apa1
	set r11,0xa001
	set r12,0xa011
	set r13,0xa021
	nop
	nop
	repeat le1,1 
	out 0x11,r11
	out 0x11,r11
le1
	repeat le11,2 
	out 0x11,r12
	out 0x11,r12
le11
	repeat le111,3 
	out 0x11,r13
	out 0x11,r13
le111
	ret ds1
	out 0x11,r2
	out 0x11,r3
apa2
	set r11,0xa002
	set r12,0xa012
	set r13,0xa022
	nop
	nop
	repeat le2,1 
	out 0x11,r11
	out 0x11,r11
	out 0x11,r11
le2
	repeat le22,2 
	out 0x11,r12
	out 0x11,r12
	out 0x11,r12
le22
	repeat le222,3 
	out 0x11,r13
	out 0x11,r13
	out 0x11,r13
le222
	ret ds2
	out 0x11,r2
	out 0x11,r2
	out 0x11,r3
apa3
 	set r1,0xa003
 	nop
 	nop
 	repeat le3,1 
 	out 0x11,r1
 	out 0x11,r1
 	out 0x11,r1
 	out 0x11,r1
le3
 	repeat le33,2
 	out 0x11,r1
 	out 0x11,r1
 	out 0x11,r1
 	out 0x11,r1
le33
 	repeat le333,3 
 	out 0x11,r1
 	out 0x11,r1
 	out 0x11,r1
 	out 0x11,r1
le333
 	ret ds3
 	out 0x11,r2
 	out 0x11,r2
 	out 0x11,r2
 	out 0x11,r3
test
 	call apa0
 	call ds1 apa1
 	out 0x11,r2
 	call ds2 apa2
 	out 0x11,r2
 	out 0x11,r2
 	call ds3 apa3
 	out 0x11,r2
 	out 0x11,r2
 	out 0x11,r2
 	ret		
start
 	out 0x11,r2
   	call test
	
	out 0x12,r0
	.ram0
foo
	.skip	5

	.rom0
bar
	.dw	0x500
