        .code
;;; ----------------------------------------------------------------------
;;; Load random values into (almost) all registers.
;;; sanitycheck can later be called to ensure that no registers have been
;;; modified.
;;; ----------------------------------------------------------------------
initsanitycheck

	;; Set up content of accumulators (except the guard bits)
        set r0,0xaba5
        set r1,0x3a3c
	move acr0.l,r0
	move acr0.h,r1
        set r0,0x2185
        set r1,0x57c8
	move acr1.l,r0
	move acr1.h,r1
        set r0,0x8429
        set r1,0x842a
	move acr2.l,r0
	move acr2.h,r1
        set r0,0x1e81
        set r1,0xbdb9
	move acr3.l,r0
	move acr3.h,r1

	;; Set up content of normal registers
        set r0,0x34e4
        set r1,0x4429
        set r2,0x7333
        set r3,0x205e
        set r4,0x6fe4
        set r5,0x5eea
        set r6,0xf900
        set r7,0x250f
        set r8,0x2284
        set r9,0x7c27
        set r10,0xf536
        set r11,0xda91
        set r12,0xa725
        set r13,0x5796
        set r14,0xe841
        set r15,0xd527
        set r16,0xc34a
        set r17,0x9c5d
        set r18,0xf84f
        set r19,0xbe69
        set r20,0xcd65
        set r21,0x46ce
        set r22,0x93fc
        set r23,0x5f0b
        set r24,0xe90d
        set r25,0x6a89
        set r26,0x7558
        set r27,0x4182
        set r28,0x6468
        set r29,0xb549
        set r30,0xa786
 ;        set r31,0x6fb4		We do not care about r31 as that is used in the main loop...

	;; Setup content of special purpose registers
        set sr0,0x818c
        set sr1,0x08ac
        set sr2,0x4935
        set sr3,0xf77c
 ;        set sr4,0x418b		We will not change the stack pointer either!
        set sr5,0x7e45
        set sr6,0x83e3
        set sr7,0x2acc
        set sr8,0x5ff1
        set sr9,0x22a6
        set sr10,0x78a0
        set sr11,0x1ab0
 ;        set sr12,0xff8e	We do not check the status register 
        set sr13,0x5e13
        set sr14,0xe3db
        set sr15,0x2ab9
        set sr16,0x71c6
        set sr17,0x7095
        set sr18,0x5f5b
        set sr19,0x65b3
        set sr20,0x8e78
        set sr21,0x169f
        set sr22,0xdc0c
        set sr23,0x4a49
        set sr24,0x7cc0
        set sr25,0xb1e5
        set sr26,0xe8d8
        set sr27,0x3a37
        set sr28,0x372e
        set sr29,0xa20e
        set sr30,0x159b
        set sr31,0xcc90

	ret

;;; ----------------------------------------------------------------------
;;; Setup up a data hazard here so the simulator will stop execution
;;;  (The hazard is setup so that the register content will not change.)
;;; This file is written in such a way that r0 contains the number of the
;;; register which contains the wrong value:
;;; r0 = 0x0000 : r0 contained the wrong value
;;; r0 = 0x0001 : r1 contained the wrong value
;;;    ....
;;; r0 = 0x0031 : r31 contained the wrong value
;;; r0 = 0x8000 : sr0 contained the wrong value
;;; r0 = 0x8001 : sr1 contained the wrong value
;;;      ...
;;; r0 = 0x8031 : sr31 contained the wrong value
;;; r0 = 0xc000 : acr0 contained the wrong value
;;;      ...
;;; r0 = 0xc003 : acr3 contained the wrong value
;;; 
;;; (See the sanitycheck function to see how this is done.)
;;; ----------------------------------------------------------------------
sanitycheckfailed
	push r30
	pop r30
	add r30,0
	jump sanitycheckfailed

;;; ----------------------------------------------------------------------
;;; This function ensures that all registers contains the same value that
;;; was written into them originally. If not, this means that a 
;;; non-interrupt safe function was called.
;;;
;;; Exception: Does not check the following registers:
;;; r31, sp (stack pointer), and sr (status register)
;;; ----------------------------------------------------------------------

sanitycheck
        cmp 0x34e4,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0x0
        cmp 0x4429,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0x1
        cmp 0x7333,r2
	jump.ne ds1 sanitycheckfailed
	set r0,0x2
        cmp 0x205e,r3
	jump.ne ds1 sanitycheckfailed
	set r0,0x3
        cmp 0x6fe4,r4
	jump.ne ds1 sanitycheckfailed
	set r0,0x4
        cmp 0x5eea,r5
	jump.ne ds1 sanitycheckfailed
	set r0,0x5
        cmp 0xf900,r6
	jump.ne ds1 sanitycheckfailed
	set r0,0x6
        cmp 0x250f,r7
	jump.ne ds1 sanitycheckfailed
	set r0,0x7
        cmp 0x2284,r8
	jump.ne ds1 sanitycheckfailed
	set r0,0x8
        cmp 0x7c27,r9
	jump.ne ds1 sanitycheckfailed
	set r0,0x9
        cmp 0xf536,r10
	jump.ne ds1 sanitycheckfailed
	set r0,0x10
        cmp 0xda91,r11
	jump.ne ds1 sanitycheckfailed
	set r0,0x11
        cmp 0xa725,r12
	jump.ne ds1 sanitycheckfailed
	set r0,0x12
        cmp 0x5796,r13
	jump.ne ds1 sanitycheckfailed
	set r0,0x13
        cmp 0xe841,r14
	jump.ne ds1 sanitycheckfailed
	set r0,0x14
        cmp 0xd527,r15
	jump.ne ds1 sanitycheckfailed
	set r0,0x15
        cmp 0xc34a,r16
	jump.ne ds1 sanitycheckfailed
	set r0,0x16
        cmp 0x9c5d,r17
	jump.ne ds1 sanitycheckfailed
	set r0,0x17
        cmp 0xf84f,r18
	jump.ne ds1 sanitycheckfailed
	set r0,0x18
        cmp 0xbe69,r19
	jump.ne ds1 sanitycheckfailed
	set r0,0x19
        cmp 0xcd65,r20
	jump.ne ds1 sanitycheckfailed
	set r0,0x20
        cmp 0x46ce,r21
	jump.ne ds1 sanitycheckfailed
	set r0,0x21
        cmp 0x93fc,r22
	jump.ne ds1 sanitycheckfailed
	set r0,0x22
        cmp 0x5f0b,r23
	jump.ne ds1 sanitycheckfailed
	set r0,0x23
        cmp 0xe90d,r24
	jump.ne ds1 sanitycheckfailed
	set r0,0x24
        cmp 0x6a89,r25
	jump.ne ds1 sanitycheckfailed
	set r0,0x25
        cmp 0x7558,r26
	jump.ne ds1 sanitycheckfailed
	set r0,0x26
        cmp 0x4182,r27
	jump.ne ds1 sanitycheckfailed
	set r0,0x27
        cmp 0x6468,r28
	jump.ne ds1 sanitycheckfailed
	set r0,0x28
        cmp 0xb549,r29
	jump.ne ds1 sanitycheckfailed
	set r0,0x29
        cmp 0xa786,r30
	jump.ne ds1 sanitycheckfailed
	set r0,0x30

        move r0,sr0
        move r1,sr1
	cmp 0x818c,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0x8000

	cmp 0x08ac,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0x8001

        move r0,sr2
        move r1,sr3
	cmp 0x4935,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0x8002

	cmp 0xf77c,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0x8003

        move r0,sr5
        move r1,sr6
	cmp 0x7e45,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0x8005

	cmp 0x83e3,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0x8006

        move r0,sr7
        move r1,sr8
	cmp 0x2acc,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0x8007

	cmp 0x5ff1,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0x8008

        move r0,sr9
        move r1,sr10
	cmp 0x22a6,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0x8009

	cmp 0x78a0,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0x8010

        move r0,sr11		; We do not check the status register (sr12)
        move r1,sr13
	cmp 0x1ab0,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0x8011

	cmp 0x5e13,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0x8013

        move r0,sr14
        move r1,sr15
	cmp 0xe3db,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0x8014

	cmp 0x2ab9,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0x8015

        move r0,sr16
        move r1,sr17
	cmp 0x71c6,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0x8016

	cmp 0x7095,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0x8017

        move r0,sr18
        move r1,sr19
	cmp 0x5f5b,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0x8018

	cmp 0x65b3,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0x8019

        move r0,sr20
        move r1,sr21
	cmp 0x8e78,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0x8020

	cmp 0x169f,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0x8021

        move r0,sr22
        move r1,sr23
	cmp 0xdc0c,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0x8022

	cmp 0x4a49,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0x8023

        move r0,sr24
        move r1,sr25
	cmp 0x7cc0,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0x8024

	cmp 0xb1e5,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0x8025

        move r0,sr26
        move r1,sr27
	cmp 0xe8d8,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0x8026

	cmp 0x3a37,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0x8027

        move r0,sr28
        move r1,sr29
	cmp 0x372e,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0x8028

	cmp 0xa20e,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0x8029

        move r0,sr30
        move r1,sr31
	cmp 0x159b,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0x8030

	cmp 0xcc90,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0x8031

	move r0,acr0
	move r1, mul65536 acr0
	cmp 0x3a3c,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0xc000

	cmp 0xaba5,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0xc000

	move r0,acr1
	move r1, mul65536 acr1
	cmp 0x57c8,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0xc001

	cmp 0x2185,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0xc001

	move r0,acr2
	move r1, mul65536 acr2
	cmp 0x842a,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0xc002

	cmp 0x8429,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0xc002

	move r0,acr3
	move r1, mul65536 acr3
	cmp 0xbdb9,r0
	jump.ne ds1 sanitycheckfailed
	set r0,0xc003

	cmp 0x1e81,r1
	jump.ne ds1 sanitycheckfailed
	set r0,0xc003
	
	
	ret

