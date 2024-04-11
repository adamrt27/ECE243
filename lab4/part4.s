.global _start

_start:
	# set constant LEDs to have address of LEDs
	.equ LEDs, 0xff200000
	# store that in r20
	movia r20, LEDs
	
	# set constant TIMER to have address of timer
	.equ TIMER, 0xFF202000
	# store that in r21
	movia r21, TIMER
	
	# set constant TIMER to have address of timer
	.equ KEY, 0xff200050
	# store that in r21
	movia r22, KEY
	
	# store current value of hundreths in r2
	movi r2, 0
	# store current value of seconds in r3
	movi r3, 0
	
	# store pause value in r7
	movi r7, 0
	
loop:
	# check for keypress
	call check_key

	bne r7, r0, loop

	# call delay
	call delay
	# increment hundreths
	addi r2, r2, 1
	# if hundreths at 99, increment seconds and reset hundreths
	movi r5, 99
	beq r2, r5, inc_sec
	
loop2:
	# combine seconds and hundreths
	# shift seconds left by 10 bits, store in r4
	slli r4, r3, 7
	# add seconds and hundreths, put in r5
	add r5, r4, r2
	# update leds
	stwio r5, (r20)
	br loop
	
inc_sec: # increments seconds and resets hundreths
	movi r2, 0
	# if seconds at 59, reset to 0
	movi r5, 8
	beq r3, r5, reset_sec
	addi r3, r3, 1
	br loop2
	
reset_sec:
	movi r3, 0
	br loop2

delay: 
	# set up the starting value
	movia r10, 1000000 # put 1m in r10
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
	
	
check_key:

	# load value from KEY to r8
	ldwio r8, 0xC(r22)
	
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
	xori r7, r7, 1
	# reset edge capture
	stwio r10, 0xC(r22)
	ret

check_1:
	movi r10, 2
	# swap r3 with its current value
	xori r7, r7, 1
	# reset edge capture
	stwio r10, 0xC(r22)
	ret
	
check_2:
	movi r10, 4
	# swap r3 with its current value
	xori r7, r7, 1
	# reset edge capture
	stwio r10, 0xC(r22)
	ret
	
check_3:
	movi r10, 8
	# swap r3 with its current value
	xori r7, r7, 1
	# reset edge capture
	stwio r10, 0xC(r22)
	ret
	
check_cancel:
	ret
	