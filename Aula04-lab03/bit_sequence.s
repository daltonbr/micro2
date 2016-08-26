MASK .eq 0x01

global BIT_SEQUENCE
BIT_SEQUENCE:

	/* r2 will be used to return the max bit count */
	/* r4 will receive the input number to check */
	/* r8 will hold the bit counter */
	/* r9 will hold the applied mask */
	/* r10 will hold the MASK constant */
	/* r11 will be the bit iterator i (0-31) */
	/* r12 will hold the input number */

	/* prologue */

	addi sp, sp, -8
	stw ra, 4(sp)
	stw fp, 0(sp)
	addi fp, sp, 0

	/* start of the function */

	movia r10, r0, mask  					/* move MASK to register */
	addi r11, r0, 32 						/* the iterator i starts at 32 */

	LOOP:
		
		beq r11, r0, END_LOOP 				/* check if has traversed the 32 bits */
		addi r11, r11, -1 					/* decrement counter */
		and r9, r12, r10 					/* apply the mask to select the rightmost bit */
		srl r12, r12, r10					/* shift one position to the right */
		beq r9, r0, CHECK_BIGGER			/* if there is a bit 1, we increment the counter */
		addi r8, r8, 1						/* if it is 1, increment the bit counter */

		CHECK_BIGGER:
			ble r8, r2, LOOP				/* if it ain't bigger, do not change */
			add r2, r8, r10 				/* update the current max */

		br LOOP
	END_LOOP:

	/* epilogue */

	ldw fp, 0(sp)
	ldw ra, 4(sp)
	addi sp, sp, 8
	ret

.end