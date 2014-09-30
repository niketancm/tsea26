	.code
	set sp,stackarea		; We obviously need some space for the stack...
	nop
	call initfirkernel
	call initsanitycheck		; Set up random values in almost all registers

;;; ----------------------------------------------------------------------
;;; Main loop. This loop ensures that handle_sample is called 1000 times.
;;; ----------------------------------------------------------------------
	set r31,1000
loop
	call handle_sample

	add r31,-1
	jump.ne loop		

	call sanitycheck  ; Ensure no register was clobbered
	out 0x13,r0       ; Signals that we are at the end of the loop


;;; ----------------------------------------------------------------------
;;; We assume that the handle_sample signal is called with a frequency
;;; of 500 Hz from a timer interrupt. It can thus not assume anything
;;; about the contents of the registers and must also save all registers
;;; that are modified.
;;; 
;;; Once all registers are saved it calls fir_kernel to perform the actual
;;; filtering.
;;; ----------------------------------------------------------------------
handle_sample
	push r0
	push r1

	move r0,ar0
	move r1,ar1
	push r0
	push r1

	move r0,step0
	move r1,step1
	push r0
	push r1

	move r0,bot1
	move r1,top1
	push r0
	push r1

	move r0,acr0
	move r1,mul65536 acr0
	push r0
	push r1

	move r0,guards01
	move r1,loopn
	push r0
	push r1

	move r0,loopb
	move r1,loope
	push r0
	push r1

	move r0,r10
	push r0
	
	move r0,bot0 		;Set the top and bottom for filter
	move r1,top0		;coefficients
	push r0
	push r1

        
        ;;;  FIXME - You may want to save other registers here as well.
        ;;; (Alternatively, you might want to save less registers here in order
        ;;; to improve the performance if you can get away with it somehow...)
	
	call fir_kernel

	pop r1			;changed
	pop r0
	move top0,r1
	move bot0,r0
	
	pop r0
        nop
	move r10,r0
	
	pop r1
	pop r0
	move loope,r1
	move loopb,r0

	pop r1
	pop r0
	move loopn,r1
	move guards01,r0

	pop r1
	pop r0
	move acr0.l,r1
	move acr0.h,r0
	
	pop r1
	pop r0
	move top1,r1
	move bot1,r0

	pop r1
	pop r0
	move step1,r1
	move step0,r0
	
	pop r1
	pop r0
	move ar1,r1
	move ar0,r0

	pop r1
	pop r0
	ret


;;; ----------------------------------------------------------------------
;;; Allocate variables used by the fir_kernel here
;;; ----------------------------------------------------------------------
	
	.ram0
current_location
	.skip 1

;;; ----------------------------------------------------------------------
;;; Initialization function for the fir kernel. Right now it only sets
;;; the current_location variable but you may want to do something more
;;; here in the lab.
;;; ----------------------------------------------------------------------
	.code
initfirkernel

	set r1,ringbuffer
	set r2,0
	
;;; This is the routine to intialize the ringbuffer to zeros

	repeat zeros,32
	st1 (r1),r2
zeros
	
	set r1,ringbuffer 	
	nop
	st0 (current_location),r1 ;Store the address of the ringbuffer in ram0
	ret

;;; ----------------------------------------------------------------------
;;; This is the filter kernel. It assumes that the following registers
;;; can be changed: r0, r1, ar0, ar1, step0, step1, bot1, top1, acr0,
;;; loopn/b/e. If you need to modify other registers, change
;;; handle_sample above!
;;; ----------------------------------------------------------------------
	.code
fir_kernel

;; --------------------------------------------------------------------
;; Set-up the top and bot for both the co-efficients and ringbuffer
;; --------------------------------------------------------------------

	set bot1,ringbuffer               ;and the bottom1 registers for ring buffer
        nop
        move r10,bot1
        nop
	add r0,r10,31
	set step1,1
        move top1,r0 	                 ;set the top1
	
	set bot0,coefficients               ;and the bottom0 register for coefficients.
        nop
        move r1,bot0
        nop
	add r0,r1,31
	set step0,1
        move top0,r0 	                 ;set the top0

;; ;; ----------------------------------------------------------------
;; ;; Read from circular buffer and store the address of the 
;; ;; current postion in the buffer to the location "current_location"
;; ;; which is stored in DM0(RAM0) using st0
;; ;; ----------------------------------------------------------------


	ld0 r10,(current_location) ;load the address of the last buffer location from RAM0
	move ar0,r1		   ;r1 has the first address of co-efficients
	move ar1,r10 		   ;The ar1 contains the address of the ring buffer
	nop
	in r0,0x10		   ;Read input sample -> r0
	nop
	st1 (r10),r0	      	   ;Store the data, into the buffer
	clr acr0		   ;The accumalator might have junk values, hence clear it
	repeat convo,31
        convss acr0,(ar0++%),(ar1++%)
convo
	move r10,ar1		   ;move the address to r10 to stored later
	nop
	convss acr0,(ar0++%),(ar1++%)
	nop
	nop
	move r0,sat div4 rnd acr0
	nop
	st0 (current_location),r10 ;store the address to "current_location" in ram0
	clr acr0
	out 0x11,r0
	ret

;;; ----------------------------------------------------------------------
;;; Allocate space for ringbuffer. We put this in DM1 since the
;;; filter coefficients are stored in DM0 (as we only have a rom in DM0)
;;; ----------------------------------------------------------------------
	.ram1
ringbuffer
	.skip 31
top_ringbuffer			; Convenient label
	.skip 1
	

;;; ----------------------------------------------------------------------
;;; The filter coefficients should be stored here in read only memory
;;; ----------------------------------------------------------------------
	.rom0
coefficients
;;;  FIXME: Here you need to fill in the coefficients.
;;;  Note: For your final solution you need to use .dw here to
;;;  demonstrate that you understand fixed point twos complement
;;;  arithmetic. No negative numbers may be entered here! (Hexadecimal
;;;  numbers are ok though.)
;;; 
;;;  Hint: During development you might find it easier to use .df and
;;;  .scale instead though
;;; 
;;;  Hint: You might find it easy to use fprintf() in matlab to
;;;  create this part. (fprintf in matlab can handle vectors)

	.dw 0x0074 		;
	.dw 0x00fc		; Enter hexadecimal number like this
	.dw 0x01f7
	.dw 0x03b2
	.dw 0x0674
	.dw 0x0a6e
	.dw 0x0fb6
	.dw 0x163f
	.dw 0x1dd7
	.dw 0x2628
	.dw 0x2ebf
	.dw 0x3717
	.dw 0x3ea0
	.dw 0x44d4
	.dw 0x493d
	.dw 0x4b88
	.dw 0x4b88
	.dw 0x493d
	.dw 0x44d4
	.dw 0x3ea0
	.dw 0x3717
	.dw 0x2ebf
	.dw 0x2628
	.dw 0x1dd7
	.dw 0x163f
	.dw 0x0fb6
	.dw 0x0a6e
	.dw 0x0674
	.dw 0x03b2
	.dw 0x01f7
	.dw 0x00fc
	.dw 0x0074

	;; .scale 0.125         ;Change the appropriate div in line number 205
	;; .df 0.0004		;
	;; .df 0.0010		; Enter hexadecimal number like this
	;; .df 0.0019
	;; .df 0.0036
	;; .df 0.0063
	;; .df 0.0102
	;; .df 0.0153
	;; .df 0.0217
	;; .df 0.0291
	;; .df 0.0373
	;; .df 0.0457
	;; .df 0.0538
	;; .df 0.0612
	;; .df 0.0672
	;; .df 0.0715
	;; .df 0.0738
	;; .df 0.0738
	;; .df 0.0715
	;; .df 0.0672
	;; .df 0.0612
	;; .df 0.0538
	;; .df 0.0457
	;; .df 0.0373
	;; .df 0.0291
	;; .df 0.0217
	;; .df 0.0153
	;; .df 0.0102
	;; .df 0.0063
	;; .df 0.0036
	;; .df 0.0019
	;; .df 0.0010
	;; .df 0.0004

;;; ----------------------------------------------------------------------
;;; Stack space
;;; ----------------------------------------------------------------------
	.ram1
stackarea
	.skip 300		; Should be plenty enough for a stack in this lab!

	
#include "sanitycheck.asm"

