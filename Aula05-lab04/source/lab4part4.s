/************************************************************************
 * Lab4 - part4 - Parallel I/O                                     *
 * 7- display segment accumulator (version with interruption)           *
 * Version 2.0 - 2016/10/05
 * Partially Tested, HEX_TO_BIN not returning right value               *
 * Authors:                                                             *
 * Dalton Lima @daltonbr                                                *
 * Giovanna Cazelato @giovannaC                                         *
 * Lucas Pinheiro @lucaspin                                             *
 ***********************************************************************/

# .equ KEY1,                       0b0010
.equ MASK_HEX0,                  0x0000000F
.equ MASK_HEX1,                  0x000000F0
.equ MASK_HEX2,                  0x00000F00
.equ MASK_HEX3,                  0x0000F000
.equ GREENLED_BASE_ADDRESS,      0x10000010
.equ HEX3_0_BASE_ADDRESS,        0x10000020
.equ SWITCH7_0_BASE_ADDRESS,     0x10000040
.equ PUSHBUTTON_BASE_ADDRESS,    0x10000050

.text

/*********************************************************************************
* EXCEPTIONS SECTIONS                                                            *
* The monitor Program automatically places the ".exceptions"section at the       *
* exception location specified in the CPU settings in SOPC Builder.              *
* Note: "ax" is REQUIRED to designate the section as allocatable and executable. *
*********************************************************************************/

    # .section    .exceptions, "ax"

.org 0x20
.global     INTERRUPTION_HANDLER
INTERRUPTION_HANDLER:
    # TODO: check which kind of exception
    # TODO: check which button was pressed
    
    ldwio       r21, 0(r17)         # data
    add         r16, r16, r21       # add to the accumulator
    stwio       r16, 0(r18)         # store accumulator in greenled (just for fun)
    
    # The accumulador (r16) is already calculated here
    # it will be divided in 4 parts (1byte each)
    # switched to the rightmost position, converted in BIN_TO_HEX
    # bringed back to their original position
    # merged in the HEX3-0 base address

    ##########
    # (HEX0) #
    ##########

    movia r22, MASK_HEX0    # r22 will hold our current mask, the input is 4 bits long
    and r23, r16, r22       # applying the mask to the accumulator
    add r4, r0, r23         # passing the value as parameter in r4
    call BIN_TO_HEX         # output in r2
    add r23, r2, r0         # r23 = return of bin_to_hex
    stwio r23, 0(r19)       # store hexcodes in 7display-led (HEX0)

    ##########
    # (HEX1) #
    ##########

    movia r22, MASK_HEX1    # r22 will hold our current mask
    and r23, r16, r22       # applying the mask to the accumulator
    srli r23, r23, 4        # moving the value 1 byte to the RIGHT
    add r4, r0, r23         # passing the value as parameter in r4
    call BIN_TO_HEX         # output in r2
    add r23, r2, r0         # Load only the wanted value
    slli r23, r23, 8        # moving back the converted value to original position (LEFT 1 byte)
    ldw r22, 0(r19)         # put the contents of r19 (value in HEX3-0) in the temp register
    add r23, r23, r22       # merge the new HEX1 in the output
    stwio r23, 0(r19)       # store hexcodes in 7display-led (HEX1)

    ##########
    # (HEX2) #
    ##########

    movia r22, MASK_HEX2    # r22 will hold our current mask
    and r23, r16, r22       # applying the mask to the accumulator
    srli r23, r23, 8        # moving the value 2 bytes to the RIGHT
    add r4, r0, r23         # passing the value as parameter in r4
    call BIN_TO_HEX         # output in r2
    add r23, r2, r0         # Load only the wanted value
    slli r23, r23, 16       # moving back the converted value to original position (LEFT 4 bytes)
    ldw r22, 0(r19)         # put the contents of r19 (value in HEX3-0) in the temp register
    add r23, r23, r22       # merge the new HEX2 in the output
    stwio r23, 0(r19)       # store hexcodes in 7display-led (HEX2)

    ##########
    # (HEX3) #
    ##########

    movia r22, MASK_HEX3    # r22 will hold our current mask
    and r23, r16, r22       # applying the mask to the accumulator
    srli r23, r23, 12       # moving the value 3 bytes to the RIGHT
    add r4, r0, r23         # passing the value as parameter in r4
    call BIN_TO_HEX         # output in r2
    add r23, r2, r0         # Load only the wanted value
    slli r23, r23, 24       # moving back the converted value to original position (LEFT 6 bytes)
    ldw r22, 0(r19)         # put the contents of r19 (value in HEX3-0) in the temp register
    add r23, r23, r22       # merge the new HEX3 in the output
    stwio r23, 0(r19)       # store hexcodes in 7display-led (HEX3)

    addi        ea, ea, -4          # return to the last instruction

    /* write to the PushButton port interruption edge capture register */
    stwio   r0, 12(r11)         # interrupt mask register is (base + 12)

    eret

.global _start
_start:

	movia   sp, 0x50000            # Allocates a valid stack
	add     fp, sp, r0

	add     r16, r0, r0                            # reset accumulator
	movia   r17, SWITCH7_0_BASE_ADDRESS
	movia   r18, GREENLED_BASE_ADDRESS
	movia   r11, PUSHBUTTON_BASE_ADDRESS
	movia   r19, HEX3_0_BASE_ADDRESS

/* write to the PushButton port interruption mask register */
    movi    r5, 0b0010         # set interruption mask for KEY 1 only
    stwio   r5, 8(r11)         # interrupt mask register is (base + 8) 

/* enable NIOS II processor interrupts */
    movi    r5, 0b0010         # interrupt mask
    wrctl   ienable, r5        # set interrupt mask bit for level 1 (PushButtons)
    movi    r5, 0b0001
    wrctl   status, r5         # set PIE = 1 - (Processor Interrupt-Enable) turn on NIOS II interrupt processing

IDLE:
	br IDLE                 # main program simply idles */

.end