.text
/* Program to Count the number of 1’s in a 32-bit word,
located at InputWord */
.global _start
_start:
/* Your code here  */
	# load number into r2
	movia r10, InputWord
	ldw r2, (r10)
	# set r6 to 0
	movi r6, 0
	
	# call function
	call ONES
	
	# store answer in answer
	movia r11, Answer
	stw r4, (r11)

endiloop: br endiloop

ONES: 
	# and with 000000001 and then shift by one bit
	# store valye of and in r3 and add that to r4
	# store counter in r6
	
	# store max value in r5
	movi r5, 18
	# set r3 to 0 to prep for and operation
	movi r3, 0
	# and r2 with 1 and store in r3
	andi r3, r2, 0x00000001
	# add r4 and r3
	add r4, r4, r3
	# shift input word by 1 bit
	srli r2, r2, 1
	# increment counter
	addi r6, r6, 1
	# if counter less than 16, loop, otherwise return
	bne r2, r0, ONES
	ret
.data
InputWord: .word 0x4a01fead
Answer: .word 0