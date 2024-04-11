.text
/* Program to Count the number of 1's and Zeroes in a sequence of 32-bit words,
and determines the largest of each */

/* register:
r2 - current value to display on LEDS
r4 - holds 0x100000000
r5 - holds 1
r7 - loops for delay
r20 - for LEDS
*/

.global _start
_start:
	# setup LEDS
	.equ    LEDs, 0xFF200000
    movia r20, LEDs
	
	# setup r2 to hold 1
	movi r2, 1
	
	# setup r4 as a constant 0x10000000
	movi r4, 0x00000400
	# setup r5 as a constant 1
	movi r5, 1

loop_left: 
	# store r1 in leds
    stwio r2, (r20)
	call delay # delay
	# shift left
    slli r2, r2, 1
	# if r1 != 0x10000000 loop back
	bne r2, r4, loop_left
	
loop_right:
	# store r1 in leds
    stwio r2, (r20)
	call delay # delay
	# shift left
    srli r2, r2, 1
	# if r1 != 0x10000000 loop back
	bne r2, r5, loop_right
	br loop_left
	
delay:
	movia r7, 327670
	br delay_loop
	
delay_loop:
	subi r7, r7, 1
	bne r7, r0, delay_loop
	ret
