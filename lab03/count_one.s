.global COUNT_ONE
COUNT_ONE:

	/* r4 will receive the number */
	/* r5 will receive 1 to indicate that we count sequence of 1's */
	/* If r5 receives 0, it will count 0's. If it receives anything else, it will count 1's */
	/* r2 will contain the OUTPUT - from the BIT_SEQUENCE suboutine */

	/* prologue */

	addi sp, sp, -8
	stw ra, 4(sp)
	stw fp, 0(sp)
	addi fp, sp, 0

	addi r5, r0, 1			/* set r5 to 1 */
	call BIT_SEQUENCE

	/* epilogue */

	ldw fp, 0(sp)
	ldw ra, 4(sp)
	addi sp, sp, 8
	ret

.end