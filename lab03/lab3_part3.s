/* subroutine to calculate the MAX LENGHT of alternated 0's and 1's in a 32bits word */
/* this soubroutine uses COUNT_ZERO, COUNT_ONE, COUNT */
/* version 2.0 */

MASK .eq 0xAAAAAAAA /* 1010 1010 1010 1010 1010 1010 1010 1010 [binary] */  

.global ALTERNATED_BIT_SEQUENCE
ALTERNATED_BIT_SEQUENCE:

	/* r4 will RECEIVE the INPUT number to check */
    /* r9 will hold the applied mask */
    /* r10 will hold the MASK constant */
    /* r12 will hold the INPUT number */
    /* r13 hold the sequence of 0's */
    /* r14 hold the sequence of 1's */
    /* r16 will hold the OUTPUT of THIS subroutine - the MAX LENGHT of alternated 0's and 1's  */	

	/* prologue */

	addi sp, sp, -8
	stw ra, 4(sp)
	stw fp, 0(sp)
	addi fp, sp, 0

	/* start of the function */

	movia r10, r0, mask  					/* move MASK to register */
    addi r12, r4, r0                        /* move the input to r12 */ 
		
    xor r9, r12, r10 					/* apply the mask */
    stw r9, 0(r4)                       /* passing the parameter to call the subroutines */
    
    call COUNT_ZERO
    add r13, r2, r0                    /* pass the output of the COUNT_ZEROS to r13 */
    
    call COUNT_ONE
    add r14, r2, r0                    /* pass the output of the COUNT_ZEROS to r13 */

/* now we have in r13 and r14 the MAX SEQUENCE of 0's and 1's respectively */
/* the bigger number will be our output */

    ble r13, r14, ONE  			   	/* IF r13 is greater... */
    add r16, r13, r0 			     /* ...0's is bigger */
    br EPILOGUE

    ONE:
        add r16, r14, r0 				    /* ...1's is bigger */
	
    /* epilogue */
    EPILOGUE:
	ldw fp, 0(sp)
	ldw ra, 4(sp)
	addi sp, sp, 8
	ret

.end