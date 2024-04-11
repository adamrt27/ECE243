.global _start

_start:
	# set constant KEY to have address of KEY
	.equ KEY, 0xFF200050
	# store that in r24
	movia r22, KEY
	
	# set constant LEDs to have address of LEDs
	.equ LEDs, 0xff200000
	# store that in r25
	movia r23, LEDs
	
	# store current value of counter in r2
	movi r2, 0
	
	# set r3 to 0
	# set r3 to hold bool, that is 1 if key3 was pressed and 0 otherwise
	movi r3, 0
	
loop:
	# call subroutine
	call check_key
	
	# call delay
	call delay
	
	beq r3, r0, count
	
loop2:
	# update leds
	stwio r2, (r23)
	
	br loop
	
count:
	addi r2, r2, 1
	br loop2

delay: movia r10, 5000000
sub_delay: subi r10, r10, 1
	bne r10, r0, sub_delay
	
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
	xori r3, r3, 1
	# reset edge capture
	stwio r10, 0xC(r22)
	ret

check_1:
	movi r10, 2
	# swap r3 with its current value
	xori r3, r3, 1
	# reset edge capture
	stwio r10, 0xC(r22)
	ret
	
check_2:
	movi r10, 4
	# swap r3 with its current value
	xori r3, r3, 1
	# reset edge capture
	stwio r10, 0xC(r22)
	ret
	
check_3:
	movi r10, 8
	# swap r3 with its current value
	xori r3, r3, 1
	# reset edge capture
	stwio r10, 0xC(r22)
	ret
	
check_cancel:
	ret
	
	