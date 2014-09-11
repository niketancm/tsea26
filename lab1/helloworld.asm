;;; ----------------------------------------------------------------------
;;; Example program that outputs the value 0 to 42 on port 0x11
;;; When run on the simulator this port is connected to the file IOS0011
;;; ----------------------------------------------------------------------
	
	
	set   sp,stackarea	; Set the stackpointer
	
	set   r0,0		; Loop counter
	set   r1,43		; Loop end

loop
	out   0x11,r0		; Output data
	add   r0,1
	cmp   r1,r0		; And check if we have reached the end of the loop
	jump.ne loop

;;;     The following commented code is an example of a faster way of running the same loop
	
;;; 	set   r0,0
;;;     set   r1,42
;;; 	cmp   1,r0		; Force Z to 0
;;; loop2
;;; 	jump.ne ds3 loop2	; Other variant of loop, this one is faster as
;;; 	out   0x11,r0 		; it uses the delay slots efficiently
;;; 	add   r0,1
;;; 	cmp   r1,r0

;;;     FIXME - Replace the loop with a repeat based loop which counts
;;;     from 0 to 42.
;;;
;;;     Hint: the syntax for repeat is as follows:
;;;         repeat label_after_loop,number_of_iterations
;;;     (Unfortunately no warning message will be given if you mix up the
;;;     parameters to repeat.)

	out   0x13,r0		; Exit the simulator.


;;; ----------------------------------------------------------------------
;;; Some space for the stack
;;; ----------------------------------------------------------------------
	
	.ram1
stackarea
	.skip 100
