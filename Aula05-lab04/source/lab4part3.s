
 # TABLE - HEX TO 7 Display Segement
 # 0 - (0,1,2,3,4,5) 		= 0011 1111 = 0x3F
 # 1 - (1,2) 						= 0000 0110 = 0x06
 # 2 - ( 0,1,3,4,6)	 		= 0101 1011 = 0x5B
 # 3 - (0,1,2,3,6)  		= 0100 1111 = 0x4F
 # 4 - (1,2,5,6) 				= 0110 0110 = 0x66
 # 5 - (0,2,3,5,6) 			= 0110 1101 = 0x6D
 # 6 - (0,2,3,4,5,6)	 	= 0111 1101 = 0x7D
 # 7 - (0,1,2) 					= 0000 0111 = 0x07
 # 8 - (0,1,2,3,4,5,6) 	=	0111 1111 = 0x7F
 # 9 - (0,1,2,3,5,6) 		= 0110 1111 = 0x6F
 # a - (0,1,2,4,5,6) 		= 0111 0111 = 0x77
 # b - (2,3,4,5,6) 			= 0111 1100 = 0x7C
 # c - (3,4,6)				  = 0101 1000 = 0x58
 # d - (1,2,3,4) 				= 0001 1110 = 0x1E
 # e - (0,3,4,5,6) 			= 0111 1001 = 0x79
 # f - (0,4,5,6) 				= 0111 0001 = 0x71

#.equ ZERO 00000000
#.eq MASK_HEX0 0x000000FF
#.eq MASK_HEX1 0x0000FF00
.global _start
_start:

	add r8, r0, r0         # reset accumulator
	movia r4, 0x10000040   # base address SW7-0
	movia r3, 0x10000010   # base address greenled
	movia r2, 0x10000050   # base address pushbutton
	movia r7, 0x10000020   # base address HEX3-0

Loop:
	ldwio r9, 12(r2)			# load edgecapture PushButton
	beq r9, r0, Loop			# if (PB == 0){ goto Loop }
	stwio r0, 12(r2)			# reset the edgecapture PushButton
	ldwio r5, 0(r4)       # data
	add r8, r8, r5        # add to the accumulator

	movia r10, 0x3f3f3f3f
	stwio r10, 0(r7)
	stwio r8, 0(r3)		   # store accumulator in greenled

	# GreenLed => HexDisp => BCD
	# 0000 => 0x0 => 3f

	br Loop

END:
	br END
	
.end
