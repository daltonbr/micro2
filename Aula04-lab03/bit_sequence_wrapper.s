global BIT_SEQUENCE_WRAPPER
BIT_SEQUENCE_WRAPPER:

	/* r4 will receive the number */
	/* r5 will receive something to indicate if we are counting 0's or 1's */
	/* If r5 receives 0, it will count 0's. If it receives anything else, it will count 1's */

	/* prologue */

	addi sp, sp, -8
	stw ra, 4(sp)
	stw fp, 0(sp)
	addi fp, sp, 0

	beq r5, r0, COUNT_ZERO
	addi r5, r0, 1
	call BIT_SEQUENCE
	br END_BIT_SEQUENCE_WRAPPER

	COUNT_ZERO:
		call BIT_SEQUENCE

	END_BIT_SEQUENCE_WRAPPER:

		/* epilogue */

		ldw fp, 0(sp)
		ldw ra, 4(sp)
		addi sp, sp, 8
		ret

.end