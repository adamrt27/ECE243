.text
/* Program to Count the number of 1's and Zeroes in a sequence of 32-bit words,
and determines the largest of each */

/* register:
r2 - current number from TEST_NUM
r10 - Address of TEST_NUM
r11 - Address of LargestOnes
r12 - current number from LargestOnes
r13 - Address of LargestZeros
r14 - current number from LargestZeros
r4 - output of Ones subroutine
r5 - puts current number for shifting
r6 - stores -1 for XOR
r7 - counter for loop
r25 - for LEDS
*/

.global _start
_start:
	# set everything to 0
	movi r2, 0
	movi r3, 0
	movi r4, 0
	movi r5, 0
	movi r10, 0
	movi r11, 0
	movi r12, 0
	movi r13, 0
	movi r14, 0
	# load number into r2, store address in r10
	movia r10, TEST_NUM
	ldw r2, (r10)
	# load largestOnes into r12, store address at r11
	movia r11, LargestOnes
	ldw r12, (r11)
	# load largestZeros into r14, store address at r13
	movia r13, LargestZeroes
	ldw r14, (r13)

loop_ones:
	# call function on normal ones
	# set r4 to 0 to prep for output
	movi r4, 0
	# set r5 to hold r2
	mov r5, r2
	call ONES
	# store answer in LargestOnes if its greater than the current value
	bgt r4, r12, update_ones
	
loop_zeros:
	movi r6, 0xFFFFFFFF
	# flip it current number
	xor r5, r2, r6
	# set r4 to 0 to prep for output
	movi r4, 0
	call ONES
	# store answer in LargestZeros if its greater than current value
	bgt r4, r14, update_zeros
	# increment r10 and load it into r2
	addi r10, r10, 4
	ldw r2, (r10)
	# if current number is 0, end program
	beq r0, r2, preiloop
	br loop_ones

update_ones:
	stw r4, (r11) # store new value in LargestOnes
	ldw r12, (r11) # update r12 with new value 
	br loop_zeros
	
update_zeros:
	stw r4, (r13) # store new value in LargestOnes
	ldw r14, (r13) # update r12 with new value 
	br loop_ones

preiloop:
	.equ    LEDs, 0xFF200000
    movia r25, LEDs
	br endiloop

endiloop: 
	movia r7, 3276700
    stwio r12, (r25)
	call delay
	movia r7, 3276700
    stwio r14, (r25)
	call delay
	br endiloop

ONES: 
	# output is stored in r4
	# set r3 to 0 to prep for AND operation
	movi r3, 0
	# AND r2 with 1 and store in r3
	andi r3, r5, 0x00000001
	# ADD r4 and r3
	add r4, r4, r3
	# SHIFT LEFT input word by 1 bit
	srli r5, r5, 1
	# if counter less than 16, loop, otherwise return
	bne r5, r0, ONES
	ret
	
delay:
	subi r7, r7, 1
	bne r7, r0, delay
	ret
	

.data
TEST_NUM:  #.word 0x4a01fead, 0xF677D671,0xDC9758D5,0xEBBD45D2,0x8059519D
            #.word 0x76D8F0D2, 0xB98C9BB5, 0xD7EC3A9E, 0xD9BADC01, 0x89B377CD
            .word 0xFFFFFFFF, 0x00000003, 0  # end of list 

LargestOnes: .word 0
LargestZeroes: .word 0

