/*
 * Lab4 - part3
 * 7- display segment accumulator
 *
 * Authors:
 * Dalton Lima @daltonbr
 * Giovanna Cazelato @giovannaC
 * Lucas Pinheiro @lucaspin
 *
 */

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
	ldwio r20, 12(r11)      # load edgecapture PushButton
	beq r20, r0, Loop       # if (PB == 0){ goto Loop }
	stwio r0, 12(r11)       # reset the edgecapture PushButton
	ldwio r21, 0(r17)       # data
	add r16, r16, r21       # add to the accumulator
	stwio r16, 0(r18)       # store accumulator in greenled (just for fun)

    # The accumulador (r16) is already calculated here
    # it will be divided in 4 parts (1byte each)
    # switched to the rightmost position, converted in BIN_TO_HEX
    # bringed back to their original position
    # merged in the HEX3-0 base address

    ##########
	# (HEX0) #
	##########

    movia r22, MASK_HEX0    # r22 will hold our current mask
    and r23, r16, r22       # applying the mask to the accumulator
    add r4, r0, r23         # passing the value as parameter in r4
    call BIN_TO_HEX         # output in r2
    and r23, r2, r22        # r23 = output masked
    stwio r23, 0(r19)       # store hexcodes in 7display-led (HEX0)

    ##########
	# (HEX1) #
	##########

    movia r22, MASK_HEX1    # r22 will hold our current mask
    and r23, r16, r22       # applying the mask to the accumulator
    srli r23, r23, 8        # moving the value 1 byte to the RIGHT
    add r4, r0, r23         # passing the value as parameter in r4
    call BIN_TO_HEX         # output in r2
    and r23, r2, r22        # r23 = output masked
    slli r23, r23, 8        # moving back the converted value to original position (LEFT 1 byte)
    add r23, r23, r19       # merge the new HEX1 in the output
    stwio r23, 0(r19)       # store hexcodes in 7display-led (HEX1)

    ##########
	# (HEX2) #
	##########

    movia r22, MASK_HEX2    # r22 will hold our current mask
    and r23, r16, r22       # applying the mask to the accumulator
    srli r23, r23, 16       # moving the value 2 bytes to the RIGHT
    add r4, r0, r23         # passing the value as parameter in r4
    call BIN_TO_HEX         # output in r2
    and r23, r2, r22        # r23 = output masked
    slli r23, r23, 16       # moving back the converted value to original position (LEFT 2 bytes)
    add r23, r23, r19       # merge the new HEX2 in the output
    stwio r23, 0(r19)       # store hexcodes in 7display-led (HEX2)

    ##########
	# (HEX3) #
	##########

    movia r22, MASK_HEX3    # r22 will hold our current mask
    and r23, r16, r22       # applying the mask to the accumulator
    srli r23, r23, 24       # moving the value 3 bytes to the RIGHT
    add r4, r0, r23         # passing the value as parameter in r4
    call BIN_TO_HEX         # output in r2
    and r23, r2, r22        # r23 = output masked
    slli r23, r23, 24       # moving back the converted value to original position (LEFT 3 bytes)
    add r23, r23, r19       # merge the new HEX3 in the output
    stwio r23, 0(r19)       # store hexcodes in 7display-led (HEX3)

	br Loop

END:
	br END
.end