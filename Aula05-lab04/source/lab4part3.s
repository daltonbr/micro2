 # 0 - (0,1,2,3,4,5) = 		0011 1111 = 0x3F
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
 # d - (1,2,3,4) = 			0001 1110 = 0x1e
 # e - (0,3,4,5,6) = 		0111 1001 = 0x79
 # f - (0,4,5,6) = 			0111 0001 = 0x71


#.equ ZERO 00000000
.equ MASK_HEX0 0x000000FF
.equ MASK_HEX1 0x0000FF00
.equ MASK_HEX2 0x00FF0000
.equ MASK_HEX3 0xFF000000

.global _start
_start:

	movia sp, 0x50000
	add fp, sp, r0

	add r16, r0, r0         # reset accumulator
	movia r17, 0x10000040   # base adress SW0-7
	movia r18, 0x10000010   # base adress greenled
	movia r11, 0x10000050   # base adress pushbutton
	movia r19, 0x10000020   # base adress HEX0-3

Loop:
	ldwio r20, 12(r11)       # load edgecapture PushButton
	beq r20, r0, Loop	   # if (PB == 0){ goto Loop }
	stwio r0, 12(r11)       # reset the edgecapture PushButton
	ldwio r21, 0(r17)        # data
	add r16, r16, r21         # add to the accumulator

    movia r22, MASK_HEX0		
    and r23, r16, r22
    
    add r4, r0, r23         # move the accumulator to r17 (will be converted to 7-display seg format)

    call BIN_TO_HEX

    and r23, r2, r22

 	stwio r23, 0(r19)	   # store accumulutor in led
	stwio r16, 0(r18)		   # store accumulator in greenled

	#################################
	# parsing accumulator, converting, and sending to the proper 7-display segment (HEX1)
	#################################

	movia r22, MASK_HEX1		# r10 must be saved by the caller. Here, we are not saving it, because we are lazy
    and r23, r16, r22    
    srli r23, r23, 8

    add r4, r0, r23         # move the accumulator to r17 (will be converted to 7-display seg format)

    call BIN_TO_HEX

    and r23, r2, r22

 	slli r23, r23, 8
    stwio r23, 0(r19)	   # store accumulutor in led
	stwio r16, 0(r18)		   # store accumulator in greenled

	#################################
	# parsing accumulator, converting, and sending to the proper 7-display segment (HEX1)
	#################################

	movia r10, MASK_HEX1		# r10 must be saved by the caller. Here, we are not saving it, because we are lazy
    and r23, r16, r10
    srli r23, r23, 8
    
    add r4, r0, r23         # move the accumulator to r17 (will be converted to 7-display seg format)

    call BIN_TO_HEX

    and r22, r2, r10

 	slli r22, r22, 8
    stwio r22, 0(r19)	   # store accumulutor in led
	stwio r23, 0(r18)		   # store accumulator in greenled





	# GreenLed => HexDisp => BCD
	# 0000 => 0x0 => 3f

	br Loop

END:
	br END
.end