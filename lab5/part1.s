.global _start
_start:
	# set constant TIMER to have address of timer
	.equ TIMER, 0xFF202000
	# store that in r21
	movia r21, TIMER
	
	# use push buttons to choose number, switches to choose which display
	movi r4, 0
	movi r5, 0
	
loop:
	mov r4, r13
	mov r5, r14
	call delay
	call HEX_DISP
	addi r13, r13, 1
	
	movi r6, 16
	bge r13, r6, inc_sec
	
	br loop
	
inc_sec:
	movi r13, 0
	# if seconds at 59, reset to 0
	movi r2, 5
	bge r14, r2, reset_sec
	addi r14, r14, 1
	br loop
	
reset_sec:
	movi r14, 0
	movi r13, 0x10
	movi r15, 5
	
reset_loop:
	mov r4, r13
	mov r5, r14
	call HEX_DISP
	addi r14, r14, 1
	ble r14, r15, reset_loop
	movi r13, 0
	movi r14, 0
	br loop
	
	

delay: 
	# set up the starting value
	movia r10, 10000000 # put 1m in r10
	srli r11, r10, 16 # shift right by 16 bits
	andi r10, r10, 0xFFFF # mask lower 16 bits
	stwio r10, 0x8(r21) # store lower 16 bits 
	stwio r11, 0xC(r21) # store upper 16 bits
	# start running
	movia r10, 0b0110 # set up r10 to turn on CONT and Start
	stwio r10, 0x4(r21) # load into timer
subdelay:
	# poll to see if TO is 1
	ldwio r12, (r21) # load current value of status reg into r12
	andi r12, r12, 0b1 # mask the TO bit
	beq r12, r0, subdelay # loop if 0
	stwio r0, (r21) # reset TO bit if 1
	ret
	
	

/*    Subroutine to display a four-bit quantity as a hex digits (from 0 to F) 
      on one of the six HEX 7-segment displays on the DE1_SoC.
*
 *    Parameters: the low-order 4 bits of register r4 contain the digit to be displayed
		  if bit 4 of r4 is a one, then the display should be blanked
 *    		  the low order 3 bits of r5 say which HEX display number 0-5 to put the digit on
 *    Returns: r2 = bit patterm that is written to HEX display
 */

.equ HEX_BASE1, 0xff200020
.equ HEX_BASE2, 0xff200030

HEX_DISP:   movia    r8, BIT_CODES         # starting address of the bit codes
	    andi     r6, r4, 0x10	   # get bit 4 of the input into r6
	    beq      r6, r0, not_blank 
	    mov      r2, r0
	    br       DO_DISP
not_blank:  andi     r4, r4, 0x0f	   # r4 is only 4-bit
            add      r4, r4, r8            # add the offset to the bit codes
            ldb      r2, 0(r4)             # index into the bit codes

#Display it on the target HEX display
DO_DISP:    
			movia    r8, HEX_BASE1         # load address
			movi     r6,  4
			blt      r5,r6, FIRST_SET      # hex4 and hex 5 are on 0xff200030
			sub      r5, r5, r6            # if hex4 or hex5, we need to adjust the shift
			addi     r8, r8, 0x0010        # we also need to adjust the address
FIRST_SET:
			slli     r5, r5, 3             # hex*8 shift is needed
			addi     r7, r0, 0xff          # create bit mask so other values are not corrupted
			sll      r7, r7, r5 
			addi     r4, r0, -1
			xor      r7, r7, r4  
    			sll      r4, r2, r5            # shift the hex code we want to write
			ldwio    r5, 0(r8)             # read current value       
			and      r5, r5, r7            # and it with the mask to clear the target hex
			or       r5, r5, r4	           # or with the hex code
			stwio    r5, 0(r8)		       # store back
END:			
			ret
			
BIT_CODES:  .byte     0b00111111, 0b00000110, 0b01011011, 0b01001111
			.byte     0b01100110, 0b01101101, 0b01111101, 0b00000111
			.byte     0b01111111, 0b01100111, 0b01110111, 0b01111100
			.byte     0b00111001, 0b01011110, 0b01111001, 0b01110001

            .end
			

