/******************************************************************************
 * Write an interrupt service routine
 *****************************************************************************/
KEY_ISR:
	/* r10 stores current value of key
	   r7 stores pressed value in the format 0b0000, where each binary digit corresponds
	   to a display
	*/
	# store address of KEY in r2
	movia r2, KEYs # store addy of KEYs in r2
	
	# load value from KEY to r8
	ldwio r8, 0xC(r2)
	
	# if no key pressed return
	beq r8, r0, check_cancel
	
	# else swap r3 and reset edgecapture
	
	# now check which key was pressed to reset
	# if key 0, store 1
	movi r10, 1
	andi r9, r8, 0x1
	beq r9, r10, check_0
	
	# if key 1, store 10 -> 0x2
	movi r10, 2
	andi r9, r8, 0x2
	beq r9, r10, check_1
	
	# if key 2, store 100 -> 0x4
	movi r10, 4
	andi r9, r8, 0x4
	beq r9, r10, check_2
	
	# if key 2, store 100 -> 0x4
	movi r10, 8
	andi r9, r8, 0x8
	beq r9, r10, check_3
	
check_0:
	movi r10, 1
	# swap r3 with its current value
	xori r7, r7, 0b0001
	# reset edge capture
	stwio r10, 0xC(r2)
	br END_KEY

check_1:
	movi r10, 2
	# swap r3 with its current value
	xori r7, r7, 0b0010
	# reset edge capture
	stwio r10, 0xC(r2)
	br END_KEY
	
check_2:
	movi r10, 4
	# swap r3 with its current value
	xori r7, r7, 0b0100
	# reset edge capture
	stwio r10, 0xC(r2)
	br END_KEY
	
check_3:
	movi r10, 8
	# swap r3 with its current value
	xori r7, r7, 0b1000
	# reset edge capture
	stwio r10, 0xC(r2)
	br END_KEY
	
check_cancel:
	br END_KEY
	
END_KEY:
	# store everything in the stack
	# store r7 and r10
	
	# check segs
	# convert onehot to binary
	# store each bit in regs r11, r12, r13, r14
	# mask to store
	andi r11, r7, 0b0001
	andi r12, r7, 0b0010
	andi r13, r7, 0b0100
	andi r14, r7, 0b1000
	
	movi r15, 1
	beq r11, r15, HEX_0 # if HEX0 is to be on go to HEX_0
	beq r11, r0, HEX_0_clear
	

aft_HEX_0:
	movi r15, 2
	beq r12, r15, HEX_1
	beq r12, r0, HEX_1_clear # if HEX1 is to be on go to HEX_1

aft_HEX_1:
	movi r15, 4
	beq r13, r15, HEX_2 # if HEX2 is to be on go to HEX_2
	beq r13, r0, HEX_2_clear
	
aft_HEX_2:
	movi r15, 8
	beq r14, r15, HEX_3 # if HEX3 is to be on go to HEX_3
	beq r14, r0, HEX_3_clear
	br end
	
HEX_0:
	# store r7, r11, r12, r13, r14 in stack
	subi sp, sp, 24
	stw r7, 0(sp)
	stw r11, 4(sp)
	stw r12, 8(sp)
	stw r13, 12(sp)
	stw r14, 16(sp)
	stw ra, 20(sp)

	# call hex to display 0 on HEX0
	movi r4, 0
	movi r5, 0
	call HEX_DISP
	
	# unload from stack
	ldw r7, 0(sp)
	ldw r11, 4(sp)
	ldw r12, 8(sp)
	ldw r13, 12(sp)
	ldw r14, 16(sp)
	ldw ra, 20(sp)
	addi sp, sp, 24
	
	br aft_HEX_0 # go back to check hex 1 and 2

HEX_0_clear:
	# store r7, r11, r12, r13, r14 in stack
	subi sp, sp, 24
	stw r7, 0(sp)
	stw r11, 4(sp)
	stw r12, 8(sp)
	stw r13, 12(sp)
	stw r14, 16(sp)
	stw ra, 20(sp)


	# call hex to display 0 on HEX0
	movi r4, 0b10000
	movi r5, 0
	call HEX_DISP
	
	# unload from stack
	ldw r7, 0(sp)
	ldw r11, 4(sp)
	ldw r12, 8(sp)
	ldw r13, 12(sp)
	ldw r14, 16(sp)
	ldw ra, 20(sp)
	addi sp, sp, 24
	
	br aft_HEX_0 # go back to check hex 1 and 2
	
HEX_1:
	# store r7, r11, r12, r13, r14 in stack
	subi sp, sp, 24
	stw r7, 0(sp)
	stw r11, 4(sp)
	stw r12, 8(sp)
	stw r13, 12(sp)
	stw r14, 16(sp)
	stw ra, 20(sp)

	# call hex to display 0 on HEX0
	movi r4, 1
	movi r5, 1
	call HEX_DISP
	
	# unload from stack
	ldw r7, 0(sp)
	ldw r11, 4(sp)
	ldw r12, 8(sp)
	ldw r13, 12(sp)
	ldw r14, 16(sp)
	ldw ra, 20(sp)
	addi sp, sp, 24
	
	br aft_HEX_1 # go back to check hex 1 and 2

HEX_1_clear:
	# store r7, r11, r12, r13, r14 in stack
	subi sp, sp, 24
	stw r7, 0(sp)
	stw r11, 4(sp)
	stw r12, 8(sp)
	stw r13, 12(sp)
	stw r14, 16(sp)
	stw ra, 20(sp)


	# call hex to display 0 on HEX0
	movi r4, 0b10000
	movi r5, 1
	call HEX_DISP
	
	# unload from stack
	ldw r7, 0(sp)
	ldw r11, 4(sp)
	ldw r12, 8(sp)
	ldw r13, 12(sp)
	ldw r14, 16(sp)
	ldw ra, 20(sp)
	addi sp, sp, 24
	
	br aft_HEX_1 # go back to check hex 1 and 2
	
HEX_2:
	# store r7, r11, r12, r13, r14 in stack
	subi sp, sp, 24
	stw r7, 0(sp)
	stw r11, 4(sp)
	stw r12, 8(sp)
	stw r13, 12(sp)
	stw r14, 16(sp)
	stw ra, 20(sp)

	# call hex to display 0 on HEX0
	movi r4, 2
	movi r5, 2
	call HEX_DISP
	
	# unload from stack
	ldw r7, 0(sp)
	ldw r11, 4(sp)
	ldw r12, 8(sp)
	ldw r13, 12(sp)
	ldw r14, 16(sp)
	ldw ra, 20(sp)
	addi sp, sp, 24
	
	br aft_HEX_2 # go back to check hex 1 and 2

HEX_2_clear:
	# store r7, r11, r12, r13, r14 in stack
	subi sp, sp, 24
	stw r7, 0(sp)
	stw r11, 4(sp)
	stw r12, 8(sp)
	stw r13, 12(sp)
	stw r14, 16(sp)
	stw ra, 20(sp)


	# call hex to display 0 on HEX0
	movi r4, 0b10000
	movi r5, 2
	call HEX_DISP
	
	# unload from stack
	ldw r7, 0(sp)
	ldw r11, 4(sp)
	ldw r12, 8(sp)
	ldw r13, 12(sp)
	ldw r14, 16(sp)
	ldw ra, 20(sp)
	addi sp, sp, 24
	
	br aft_HEX_2 # go back to check hex 1 and 2
	
HEX_3:
	# store r7, r11, r12, r13, r14 in stack
	subi sp, sp, 24
	stw r7, 0(sp)
	stw r11, 4(sp)
	stw r12, 8(sp)
	stw r13, 12(sp)
	stw r14, 16(sp)
	stw ra, 20(sp)

	# call hex to display 0 on HEX0
	movi r4, 3
	movi r5, 3
	call HEX_DISP
	
	# unload from stack
	ldw r7, 0(sp)
	ldw r11, 4(sp)
	ldw r12, 8(sp)
	ldw r13, 12(sp)
	ldw r14, 16(sp)
	ldw ra, 20(sp)
	addi sp, sp, 24
	
	br end # go back to check hex 1 and 2

HEX_3_clear:
	# store r7, r11, r12, r13, r14 in stack
	subi sp, sp, 24
	stw r7, 0(sp)
	stw r11, 4(sp)
	stw r12, 8(sp)
	stw r13, 12(sp)
	stw r14, 16(sp)
	stw ra, 20(sp)


	# call hex to display 0 on HEX0
	movi r4, 0b10000
	movi r5, 3
	call HEX_DISP
	
	# unload from stack
	ldw r7, 0(sp)
	ldw r11, 4(sp)
	ldw r12, 8(sp)
	ldw r13, 12(sp)
	ldw r14, 16(sp)
	ldw ra, 20(sp)
	addi sp, sp, 24
	
	br end # go back to check hex 1 and 2

end:
	
	ret
	
	
.section .exceptions, "ax"
IRQ_HANDLER:
        # save registers on the stack (et, ra, ea, others as needed)
        subi    sp, sp, 16          # make room on the stack
        stw     et, 0(sp)
        stw     ra, 4(sp)
        stw     r20, 8(sp)

        rdctl   et, ctl4            # read exception type
        beq     et, r0, SKIP_EA_DEC # not external?
        subi    ea, ea, 4           # decrement ea by 4 for external interrupts

SKIP_EA_DEC:
        stw     ea, 12(sp)
        andi    r20, et, 0x2        # check if interrupt is from pushbuttons
        beq     r20, r0, END_ISR    # if not, ignore this interrupt
        call    KEY_ISR             # if yes, call the pushbutton ISR

END_ISR:
        ldw     et, 0(sp)           # restore registers
        ldw     ra, 4(sp)
        ldw     r20, 8(sp)
        ldw     ea, 12(sp)
        addi    sp, sp, 16          # restore stack pointer
        eret                        # return from exception

/*********************************************************************************
 * set where to go upon reset
 ********************************************************************************/
.section .reset, "ax"
        movia   r8, _start
        jmp    r8

/*********************************************************************************
 * Main program
 ********************************************************************************/
.text
.global  _start

.equ KEYs, 0xFF200050

_start:
        /*
        1. Initialize the stack pointer
        2. set up keys to generate interrupts
        3. enable interrupts in NIOS II
        */
	movia sp, 0x20000 # initialize stack pointer
	movia r2, KEYs # store addy of KEYs in r2
	movi r4, 0x1 # need to affect bit 0 using r4
	
	# setup KEYs registers
	stwio r4, 0xC(r2) # this clears the edge capture bit for KEY0 if it was on,
					  # writing into the edge capture register
	movi r4, 0b1111 # need to affect bit 0 using r4
	stwio r4, 8(r2) # turn on the interrupt mask register bit 0 for KEY 0 so
					# that this causes an interrupt from the KEYs to go
					# to the processor when the button releases
					
	# Now, enable the processor in two ways, in ctl0 and ctl3
	movi r5, 0x2 # used to turn on bit 1 below
	wrctl ctl3, r5 # ctl3 called ienable reg - bit 1 enables interrupts for
				   # IRQ1 which is for key buttons
	wrctl ctl0, r4 # ctl0 also called status reg - bit 0 is Proc Interrupt
				   # Enable (PIE) bit - set it to 1
				   # bit 1 is User/Supervisor bit - set to 0 for Supervisor
				   
	movi r7, 0
	
	
IDLE:   br  IDLE




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
			
