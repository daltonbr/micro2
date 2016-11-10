/***********************************************************
 * Lab 05 - UART and timers - nov, 10th, 2016              *
 * Part 3 - Using the timer [tested]                               *
 * Writing to the terminal, interrupting, but way too fast *
 * Authors:                                                *
 * Dalton Lima @daltonbr                                   *
 * Giovanna Cazelato @giovannaC                            *
 * Lucas Pinheiro @lucaspin                                *
 ***********************************************************/
 
/*********************************************************************************************
 *                          ---=== JTAG UART REGISTERS ===---                                 *
 * Address    | 31 ... 16 | 15     | 14... 11 | 10 | 9 | 8 | 7 ...| 1 | 0 |                  *
 * 0x10001000 |  RAVAIL   | RAVAIL |        Unused         |     DATA     | Data Register    *
 * 0x10001004 |  WSPACE   |       Unused      | AC | WI|RI |Unuse |WE |RE | Control Register *
 *********************************************************************************************/

 /*************************************************************************************************************
 *                           ---=== TIMER REGISTERS ===---                                                   *
 * Address    | 31      ...      16 |        15          |   3   |   2   |   1   |   0   |                   *
 * 0x10002000 |                     |                 Unused             |  RUN  |  TO   | Status Register   *
 * 0x10002004 |                     |      Unused        | STOP  | START | CONT  |  ITO  | Control Register  *
 * 0x10002008 |    Not present      |                Counter start value (low)           |                   *
 * 0x1000200C | (interval timer has |                Counter start value (high)          |                   *
 * 0x10002010 |  16-bit registers)  |                Counter snapshot (low)              |                   *
 * 0x10002014 |                     |                Counter snapshot (high)             |                   *
 *************************************************************************************************************/

.equ WSPACE_UART_mask,          0xFF00              # only high halfword (imm16)
.equ RAVAIL_UART_mask,          0xFF00              # only high halfword (imm16)
.equ DATA_UART_mask,            0x00FF
.equ RVALID_UART_mask,          0b1000000000000000  # more visual than 65536 [decimal]  
.equ UART_BASE_ADDRESS,         0x10001000
.equ TIMER_BASE_ADDRESS,        0x10002000
.equ TIMER_INTERVAL,            0x017D7840           # 1/(50 MHz) × (0x17D7840) = 500 msec

    .text                                         # executable code follows

    .org 0x20
    .global     INTERRUPTION_HANDLER
/* here we have 2 kinds of interruption: timer and JTAG UART (for reading)    
 * checking ipending (ctl4) to see which interruption occurred
 * and branching accordingly - JTAG UART or Timer interrupt */
INTERRUPTION_HANDLER:  
    rdctl       r13, ipending
    andi        r14, r13, 0b1                     # mask for Timer interruption
    bne         r14, r0, TIMER_INTERRUPT    
    andi        r14, r13, 0b100000000             # mask for JTAG UART interruption
    bne         r14, r0, UART_INTERRUPT
    # check for anything else ? - maybe not an external interruption? 

/* Writing the readed char to the DATA field in the UART Control Register */
TIMER_INTERRUPT:
    
    ldbio       r15, 0(r9)
    andi        r15, r15, 0b11111110
    stbio       r15, 0(r9)
    stbio       r10, 0(r8)                  # Writing in the DATA (note: writing into this register
                                            # has no effect on received data) 
    br RETURN_FROM_INTERRUPT
    
/* Reading the character */    
UART_INTERRUPT:
    ldbio       r10, 0(r8)                  # r10 = DATA (1 byte)
    br RETURN_FROM_INTERRUPT

RETURN_FROM_INTERRUPT:
    subi        ea, ea, 4                   # external interrupt must decrement ea, so that the 
    eret                                    # interrupted instruction will be run after eret

    .org        0x500
    .global     _start
_start:
    movia       r8, UART_BASE_ADDRESS
    movia       r9, TIMER_BASE_ADDRESS

/* set the interval timer period for scrolling the HEX displays */
    movia       r12, TIMER_INTERVAL         # 1/(50 MHz) × (0x17D7840) = 500 msec
    sthio       r12, 8(r9)                  # store the low halfword of counter (low)...
    srli        r12, r12, 16                # move the high halfword to the low part
    sthio       r12, 12(r9)                 # ...and then store it in the the counter (high)

/* start interval timer, enable its interrupts and set it to reload when reach 0 */
    movi        r13, 0b0111                 # START = 1, CONT = 1, ITO = 1
    sthio       r13, 4(r9)

/* enable Nios II processor interrupts */
    movi        r7, 0b100000001             # set interrupt mask bits for IRQ #0 (interval
    wrctl       ienable, r7                 # timer) and #8 (JTAG port) 
    movi        r7, 1
    wrctl       status, r7                  # turn on Nios II interrupt processing

/* enable JTAG uART interrupt for reading (RE) */

    ldbio       r15, 4(r8)
    ori         r15, r15, 0b00000001
    sthio       r15, 4(r8)

/* load an initial value to the buffer (r10) */
    movia       r10, 64                     # r10 = '@'

IDLE:                                       # simply idles, waiting for interrupts
    br IDLE
    
.end