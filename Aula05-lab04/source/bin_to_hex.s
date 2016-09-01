.global BIN_TO_HEX
BIN_TO_HEX:

	/* this procedure will receive four bits representing a binary (0-15) */
	/* and it returns a 7-display-segment hexadecimal representation of that number */

	/* r4 will hold the input number */
	/* r2 will hold the returned value */

	/* prologue */
	addi sp, sp, -8
	stw fp, 0(sp)
	stw ra, 4(sp)
	addi fp, sp, 0



	/* epilogue */
	ldw fp, 0(sp)
	ldw ra, 4(sp)
	addi sp, sp, 8
	ret

.org HEX_CODE_MAP



.end
