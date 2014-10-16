;;; Simple test program to do motion estimation on a QCIF grayscale image
;;; (QCIF resolution is 176x144)


;;; Allocate memory for both the current and the reference frame at the top of
;;; both memories!
	.ram0
original_frame			; image1.raw
	.skip	25344		; 176 * 144

	; image1.raw and image2.raw will be loaded by the simulator into the ram buffers
	; (This is hardcoded behavior in the simulator)

	.ram1
new_frame			; image2.raw
	.skip	25344		; 176 * 144

	.rom0

search_offsets
#include "spiral_search_pattern.asm"
	.dw	0		; End of offsets

	;; One 4x4 block:
	;; A B C D
	;; E F G H
	;; I J K L
	;; M N O P
pixel_offsets
	.dw	0		; A
	.dw	1		; B
	.dw	2		; C
	.dw	3		; D
	.dw	176		; E
	.dw	177		; F
	.dw	178		; G
	.dw	179		; H
	.dw	352		; I
	.dw	353		; J
	.dw	354		; K
	.dw	355		; L
	.dw	528		; M
	.dw	529		; N
	.dw	530		; O
	.dw	531		; P

	.code

	
start
	call	sad_entire_image
	nop

	out	0x13,r0		; Tell simulator that we are finished
	nop
	nop
	nop
	
	

sad_entire_image
	;; To simplify this demo program we do not care about border blocks
	;; We search blocks with starting addresses from (16,16) to (152,124)

	;; (Otherwise we would have to take care to avoid searches
	;;  which would end up outside the image borders.)

	;; r8 - x coordinate
	;; r9 - y coordinate
	;; r10 - Offset in image for current search block
	set	r8,16	
	set	r9,16
	set	r10,2832 ; 16+16*176
	nop

sad_next_block	
	move	r0,r10
	call	sad_one_block	; Call sad with current block in r0

	out	0x11, r6	; Output the best match for this block

	add	r8,r8,4		; Increase X counter
	add	r10,r10,4	; Increase current offset in image
	sub	r0,160,r8	; Have we reached the border blocks to the right?
	jump.ne	sad_next_block	; (Continue if not)

	;; New line
	set	r8,16		; X counter = 16
	add	r9,r9,4		; Increase Y counter by 4
	add	r10,560		; Increase the offset by three lines 3*176 plus 32
	sub	r0, 128, r9	; Have we reached the border blocks at the bottom?
	jump.ne	sad_next_block	; (Continue if not)

	ret
	

;;; ------------------------------------------

sad_one_block

;;; Search around a given 4x4 block in the original frame and find the best match
;;; in the new frame
;;; Inputs:
;;; r0: Offset to the upper left 4x4 block in the original frame
	
;;; Register usage in the entire algorithm
;;; ar0: Pointer to upper left corner of the original 4x4 block
;;; ar1: Pointer to upper left corner of the 4x4 block we want to compare 
;;; 	the original block with
;;; ar2: Points to the search_offsets array, it is 0 terminated
;;; ar3: Pixel offsets inside one 4x4 block

;;; Temporary registers used in this function:
;;; r0,r1,r2,r3
	
;;; r5: Sum of absolute difference for the best match yet
;;; r6: Index for best match yet
;;; r7: Current index
;;; r14: Upper left corner of the 4x4 block in the old frame
;;; r15: Upper left corner of the 4x4 block in the new frame which has the same
;;;      coordinates as the original 4x4 block in the old frame

	
	set	r1,new_frame
	set	r2,original_frame
	add	r14,r1,r0	; Pointer to 4x4 block in original frame

	;; Since we use the same offset here as in the original frame we will start
	;; start to search at the same location in the new frame (which is likely to
	;; be the best match anyway in a scene with little movement)
	add	r15,r2,r0

	set	r0,search_offsets	; Initialize search_offsets pointer 
	set	r5,65535		; Initialize "best match yet" to something impossibly large
	set	r6,65535		; Dummy value for best index match yet
	move	ar2,r0
	
	move	ar1,r14
	move	ar0,r15

	set	r3,pixel_offsets 	; Initialize pixel_offsets pointer
	set	r7,0			; Initialize index counter to 0
sad_next_iteration

	move	ar3,r3		; Reinitialize pixel_offsets pointer
	
	set	r4,0	  	; Clear the register used to accumulate data
	

	repeat	sad_kernel_end,16
sad_kernel_start
 	ld0	r0,(ar3++)	; Load displacement in image
	nop
 	ld0	r1,(ar0,r0)	; Load pixel in original image
 	ld1	r2,(ar1,r0)	; Load pixel in new image
 	nop

 	sub	r1,r1,r2	; Calculate difference
 	abs	r1,r1		; Take absolute value

 	add	r4,r4,r1	; Sum of absolute difference

sad_kernel_end
	

	; Check if this is the best match yet
 	sub	r0,r4,r5	; r4 - r5
 	jump.ult not_better

	; Update the best match
	move	r5,r4
	move	r6,r7


not_better
	ld0	r0,(ar2++)	; Where should we search for the 4x4 block next?
	nop
	add	r1,r15,r0
	move	ar0,r1		; Update address register with next block

	add	r7,r7,1
	add	r0,r0,0		; Final iteration? (the search_offsets array is 0 terminated)
	jump.ne	sad_next_iteration

sad_finished
	ret
