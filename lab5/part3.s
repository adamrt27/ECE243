.section .exceptions, "ax"
IRQ_HANDLER:
        # save registers on the stack (et, ra, ea, others as needed)
        subi    sp, sp, 44         # make room on the stack
        stw     et, 0(sp)
        stw     ra, 4(sp)
        stw     r20, 8(sp)
		stw 	r21, 12(sp)
		stw		r10, 16(sp)
		stw		r9, 20(sp)
		stw 	r8, 24(sp)
		stw		r11, 28(sp)
		stw 	r12, 32(sp)
		stw		r13, 36(sp)

        rdctl   et, ctl4            # read exception type
        beq     et, r0, SKIP_EA_DEC # not external?
        subi    ea, ea, 4           # decrement ea by 4 for external interrupts

SKIP_EA_DEC:
        stw     ea, 40(sp)
        andi    r20, et, 0x2        # check if interrupt is from pushbuttons
        beq     r20, r0, CHECK_TIMER# if not, ignore this interrupt, check timer
        call    KEY_ISR             # if yes, call the pushbutton ISR

CHECK_TIMER:
		andi	r21, et, 0x1		# check if interrupt is from timer
		beq		r21, r0, END_ISR 	# if not, ignore this interrupt
		call	TIMER_ISR 			# if yes, call the timer ISR

END_ISR:
        ldw     et, 0(sp)           # restore registers
        ldw     ra, 4(sp)
        ldw     r20, 8(sp)
		ldw 	r21, 12(sp)
		ldw 	r10, 16(sp)
		ldw		r9, 20(sp)
		ldw 	r8, 24(sp)
		ldw		r11, 28(sp)
		ldw		r12, 32(sp)
		ldw		r13, 36(sp)
        ldw     ea, 40(sp)
        addi    sp, sp, 44          # restore stack pointer
        eret                        # return from exception

/*********************************************************************************
 * set where to go upon reset
 ********************************************************************************/
.section .reset, "ax"
        movia   r8, _start
        jmp    r8
.text
.global  _start

.equ KEYs, 0xFF200050
.equ TIMER, 0xFF202000
.equ LED_BASE, 0xFF200000

_start:
    /* Set up stack pointer */
	movia 	sp, 0x20000 		# initialize stack pointer
	
    call    CONFIG_TIMER        # configure the Timer
    call    CONFIG_KEYS         # configure the KEYs port
	
    /* Enable interrupts in the NIOS-II processor */
	movi 	r5, 0b11 			# used to turn on bit 1 below
	wrctl 	ctl3, r5 			# ctl3 called ienable reg - bit 1 enables interrupts for
				   				# IRQ1 which is for key buttons
	movi 	r4, 0b1111 			# need to affect bit 0 using r4
	wrctl 	ctl0, r4 			# ctl0 also called status reg - bit 0 is Proc Interrupt
				   				# Enable (PIE) bit - set it to 1
				   				# bit 1 is User/Supervisor bit - set to 0 for Supervisor

    movia   r8, LED_BASE        # LEDR base address (0xFF200000)
    movia   r9, COUNT           # global variable
LOOP:
    ldw     r10, 0(r9)          # global variable
    stwio   r10, 0(r8)          # write to the LEDR lights
    br      LOOP

CONFIG_TIMER:
	movia 	r8, TIMER 			# store addy of KEYs in r2

	/* set TO to 0 to reset */
	stwio	r0, 0(r8)
	
	/* Store start value in timer */
	movia 	r9, 25000000		# store 25M in r9
	movia 	r10, 0xFFFF			# set up value for masking
	and		r10, r9, r10		# store lower 16 bits in r10
	stwio 	r10, 0x8(r8) 		# store into timer
	srli	r9, r9, 16			# shift right to get upper 16 bits in r9
	stwio 	r9, 0xC(r8) 		# store into timer
	
	/* start timer and turn on interrupt */
	movia 	r10, 0b0111 		# set r10 to turn on CONT and START
	stwio 	r10, 0x4(r8)		# store in timer
	
	ret

CONFIG_KEYS:
	/* clear edge capture register */
	movia 	r8, KEYs 			# store addy of KEYs in r2
	movi 	r9, 0b1111 			# need to affect bit 0 using r4
	stwio 	r9, 0xC(r8) 		# this clears the edge capture bit for KEY0-3 if it 
								# was on, writing into the edge capture register
	
	/* turn on interrupt mask register */
	movi 	r9, 0b1111 			# need to affect bit 0 using r4
	stwio 	r9, 8(r8) 			# turn on the interrupt mask register bit 0 for KEY 0-3 
								# so that this causes an interrupt from the KEYs to go
								# to the processor when the button releases
	ret
	
KEY_ISR:
	# add r11 to count in TIMER_ISR, so switch between 0 and 1
	movia 	r11, RUN
	ldw		r12, (r11)
	xori 	r12, r12, 1
	stw		r12, (r11)
	# reset edge capture bit
	movia 	r12, KEYs 			# store addy of KEYs in r2
	movi 	r13, 0xF 		# store 1s in r13
	# load value from KEY to r8
	stwio 	r13, 0xC(r12)
	ret
	
TIMER_ISR:
	movia 	r8, TIMER 			# store addy of KEYs in r2

	/* set TO to 0 to reset */
	stwio	r0, 0(r8)
	
	# load count into r9
	movia   r9, COUNT           # global variable
	# load value into r10
	ldw 	r10, 0(r9)
	# increment r10
	movia 	r11, RUN
	ldw		r12, (r11)
	add		r10, r10, r12
	# store back in count/r9
	stw		r10, (r9)
	
	ret


.data
/* Global variables */
.global  COUNT
COUNT:  .word    0x0            # used by timer

.global  RUN                    # used by pushbutton KEYs
RUN:    .word    0x1            # initial value to increment COUNT

.end