.global SORT
SORT:
	/* i = r6, j = r7 */
	/* size = r4 */
	/* indice_max = r8 */
	/* vector = r5 */
	/* tmp = r9 */

	addi sp, sp, -8
	080stw fp, 0(sp)
	stw ra, 4(sp)
	addi fp, sp, 0

	addi r6, r0, 0  /* i = 0 */
	addi r7, r6, 0	/* j = i + 1 */

OUTER_LOOP:
	
	bge r6, r4, END_OUTER_LOOP  /* if i reaches list size, we get out of outer loop */
	addi r8, r6, 0 			 	/* indice_max = i */

	INNER_LOOP:

		addi r7, r7, 1				/* increment j */
		bge r7, r4, END_INNER_LOOP /* when j reaches size, get out of inner loop */

		slli r10, r7, 2				/* calculating real offset (4 * j) */
		add r10, r10, r5			/* adding base address to the offset - vector[j] */

		slli r11, r8, 2				/* calculating real offset of indice_max */
		add r11, r11, r5			/* adding base addres to the offset - vector[indice_max] */
		
		ldw r12, (r10)				/* load vector[indice_max] in r12 */
		ldw r13, (r11)				/* load vector[j] in r13 */
		ble r13, r12, INNER_LOOP	/* if it aint bigger, go back to the inner loop */	
		add r8, r0, r7				/* indice_max = j */

		br INNER_LOOP

	END_INNER_LOOP:

	addi r6, r6, 1					/* increment i */
	beq	r6, r8, OUTER_LOOP 			/* if bigger wasnt found, go back to loop */

	ldw r9, (r11)	 				/* temp = vector[indice_max] */
	ldw r14, (r10)
	stw r9, (r10)
	stw r14, (r11)

	# add r11, r10, r0 				/* vector[indice_max] = vector[i] */
	# add r10, r9, r0 				/* vector[i] = temp */

	# ldw r11, (r10)					/* vector[indice_max] = vector[i] */
	# stw r10, (r11)					/* vector[i] = temp */

	br OUTER_LOOP

END_OUTER_LOOP:
		
	ldw fp, 0(sp) 					/* restore ra, fp, sp, and other registers, if any */
	ldw ra, 4(sp)
	addi sp, sp, 8
	ret

END:
    br		END              /* Espera aqui quando o programa terminar  */
