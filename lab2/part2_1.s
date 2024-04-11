.text  # The numbers that turn into executable instructions
.global _start
_start:

/* r13 should contain the grade of the person with the student number, -1 if not found */
/* r10 has the student number being searched */


	movia r10, 10392584		# r10 is where you put the student number being searched for

/* Your code goes here  */

	# load pointer to snumbers into a reg
	movi r1, Snumbers
	# load pointer to grades into a reg
	movi r2, Grades
	
	# load the first nuber of Snumbers into r5
	ldw r5, (r1)
	
	# load the first grade into r6
	ldw r6, (r2)
	
	# load result into r7
	movi r7, result
	
Loop:
	# load the first nuber of Snumbers into r5
	ldw r5, (r1)
	
	# load the first grade into r6
	ldw r6, (r2)

	# check if number in r10 is the same as the current value in Snumbers (r5)
	# if so, go to end block
	beq r10, r5, end
	# else if number in r5 is 0, load -1 into result
	beq r5, r0, end_not_found
	# else increment pointers to Snumbers and Grades and loop again
	addi r1, r1, 4
	addi r2, r2, 4
	br Loop

end:
	# store the current grade (r6) in r7-> result
	stw r6, (r7)
	# load r7->result into r13
	ldw r13, (r7)
	# go to iloop
	br iloop
	
end_not_found:
	# move -1 into r8
	movi r8, -1
	# store -1 in r7->result
	stw r8, (r7)
	# load result into r13
	ldw r13, (r7)
	br iloop

iloop: br iloop


.data  	# the numbers that are the data 

/* result should hold the grade of the student number put into r10, or
-1 if the student number isn't found */ 

result: .word 0
		
/* Snumbers is the "array," terminated by a zero of the student numbers  */
Snumbers: .word 10392584, 423195, 644370, 496059, 296800
        .word 265133, 68943, 718293, 315950, 785519
        .word 982966, 345018, 220809, 369328, 935042
        .word 467872, 887795, 681936, 0

/* Grades is the corresponding "array" with the grades, in the same order*/
Grades: .word 99, 68, 90, 85, 91, 67, 80
        .word 66, 95, 91, 91, 99, 76, 68  
        .word 69, 93, 90, 72
	
	
