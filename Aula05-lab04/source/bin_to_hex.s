/*
 * auxiliar procedure will receive four bits representing a binary (0-15)
 * and it returns a 7-display-segment hexadecimal representation of that number
 *
 * Authors:
 * Dalton Lima @daltonbr
 * Giovanna Cazelato @giovannaC
 * Lucas Pinheiro @lucaspin
 *
 * r4 will hold the input number
 * r2 will hold the returned value (we will use only 1 byte of the register)
 */

.equ HEX_CODE_MAP, 0x20000 /* base address for our table of outputs */
.equ MASK        , 0xff

.global BIN_TO_HEX
BIN_TO_HEX:
	
	/* prologue */
	addi sp, sp, -8
	stw fp, 0(sp)
	stw ra, 4(sp)
	addi fp, sp, 0

    /* body */

    # integrity check: input >0 and <15
    # how to return error? 
    # who need to treat the error: caller or callee?
     
    movia r8, MASK   	/* r8 = MASK */
    and r8, r4, r8      /* apply the mask to nullify the three leftmost bytes */
                        /* r8 will be our OFFSET */
    movia r9, HEX_CODE_MAP
    add r9, r9, r8		# sum the offset to the base address
                  
    # the output is the table base address plus an offset (input)
    ldb r2, 0(r9)

	/* epilogue */
	ldw fp, 0(sp)
	ldw ra, 4(sp)
	addi sp, sp, 8
	ret

.org HEX_CODE_MAP
VALUES:
.byte   0x3f, 0x06, 0x5b, 0x4F, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f, 0x77, 0x7c, 0x58, 0x5e, 0x79, 0x71

# table values for conversion hex chars into 7-display segment
 # 0 - (0,1,2,3,4,5) = 		0011 1111 = 0x3f
 # 1 - (1,2) = 				0000 0110 = 0x06
 # 2 - ( 0,1,3,4,6) = 		0101 1011 = 0x5b
 # 3 - (0,1,2,3,6) = 		0100 1111 = 0x4F
 # 4 - (1,2,5,6) = 			0110 0110 = 0x66
 # 5 - (0,2,3,5,6) = 		0110 1101 = 0x6d
 # 6 - (0,2,3,4,5,6) = 		0111 1101 = 0x7d
 # 7 - (0,1,2) = 			0000 0111 = 0x07
 # 8 - (0,1,2,3,4,5,6) =	0111 1111 = 0x7f
 # 9 - (0,1,2,3,5,6) = 		0110 1111 = 0x6f
 # a - (0,1,2,4,5,6) = 		0111 0111 = 0x77
 # b - (2,3,4,5,6) = 		0111 1100 = 0x7c
 # c - (3,4,6) = 			0101 1000 = 0x58
 # d - (1,2,3,4,6) = 		0101 1110 = 0x5e
 # e - (0,3,4,5,6) = 		0111 1001 = 0x79
 # f - (0,4,5,6) = 			0111 0001 = 0x71

.end