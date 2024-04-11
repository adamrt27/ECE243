.global _start

_start:
	# set constant KEY to have address of KEY
	.equ KEY, 0xff200050
	# store that in r24
	movia r24, KEY
	
	# set constant LEDs to have address of LEDs
	.equ LEDs, 0xff200000
	# store that in r25
	movia r25, LEDs
	
	# store current value in r2
	movi r2, 0
	
	# set r3 to 0
	# set r3 to hold bool, that is 1 if key3 was pressed and 0 otherwise
	movi r3, 0
	
loop:
	# call subroutine
	call check_key
	
	# update leds
	stwio r2, (r25)
	
	br loop
	
check_key:

	# load value from LEDs to r8
	ldwio r8, (r24)
	
	# if no key pressed loop back
	beq r8, r0, check_cancel
	
	# check r8 to see which key pressed
	# if 0, set r2 to 1, return
	movi r10, 1
	beq r8, r10, check_key0
	# if 1, increment unles its greater than 15
	movi r11, 2
	beq r8, r11, check_key1
	# if 2, decrement
	movi r12, 4
	beq r8, r12, check_key2
	# if 3, set display to 0
	movi r13, 8
	beq r8, r13, check_key3
	# if LEDs is 0, set to 1
	#beq r2, r0, reset_key3
	
	ret
	
check_key0:
	# put 1 in r2
	movi r2, 1
	ret
	
check_key1:
	# check if r3 is one, if so go to reset_key3
	beq r3, r10, reset_key3
	
	# increment by 1 if its less than 15
	# put 15 in r13
	movi r14, 15
	# if r2 >= 15, return
	bge r2, r14, check_cancel
	# else add 1 to r2 and return
	addi r2, r2, 1
	ret
	
check_key2:
	# check if r3 is one, if so go to reset_key3
	beq r3, r10, reset_key3
	
	# decremeent by 1 if its greater than 1
	# if r2 <= 1, return
	ble r2, r10, check_cancel
	# else add 1 to r2 and return
	subi r2, r2, 1
	ret
	
check_key3:
	# set to 0 while pressed
	movi r2, 0
	# set r3 back to 0
	movi r3, 1
	ret
	
reset_key3:
	# reset r2 to 1, set r3 to 0
	movi r3, 0
	movi r2, 1
	ret
	
check_cancel:
	# check if r3 is one, if so go to reset_key3
	#beq r3, r10, reset_key3
	ret
	
	