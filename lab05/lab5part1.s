/***********************************************************
 * Lab 05 - UART and timers - oct, 5th, 2016               *
 * Part 1 - Flashing ascii chars on Altera Monitor Program *
 * version 0.2 - 10/10/16 (not tested)                     *
 * Authors:                                                *
 * Dalton Lima @daltonbr                                   *
 * Giovanna Cazelato @giovannaC                            *
 * Lucas Pinheiro @lucaspin                                *
 ***********************************************************/
 
/*********************************************************************************************
 *                          ---=== JTA UART REGISTERS ===---                                 *
 * Address    | 31 ... 16 | 15     | 14... 11 | 10 | 9 | 8 | 7 ...| 1 | 0 |                  *
 * 0x10001000 |  RAVAIL   | RVALID |        Unused         |     DATA     | Data Register    *
 * 0x10001004 |  WSPACE   |       Unused      | AC | WI|RI |Unuse |WE |RE | Control Register *
 *********************************************************************************************/

.org        0x500

.equ WSPACE_UART_mask,          0xFF00          # only high halfword (imm16)
.equ DATA_UART_mask,            0x00FF
.equ UART_BASE_ADDRESS          0x10001000
# .equ UART_CONTROL_ADDRESS       0x10001004
.equ Z                          0x5A            # ASCII 90 (decimal)
.equ COUNTER                    0x4C4B40        # 5*10ˆ6 [decimal]

.text                                   # executable code follows
    .global _start
_start:
    movia   r8, UART_BASE_ADDRESS
    # movia   r9, UART_CONTROL_ADDRESS

/* Checking for Space in the FIFO for Writing (WSPACE) */
POLLING_UART:
	ldwio   r10, 4(r8)        	        # r10 = UART Control Register (entire word)
    andhi   r10, r10, WSPACE_UART_mask
    andi    r10, r10, 0x0000            # setting the r10 low halfword to 0
    beq     r10, r0, POLLING_UART       # if (WSPACE == 0) loops

/* 5*10ˆ6 cycles = 4secs (SDRAM) or 0.5 sec (SRAM) */
    movia   r12, COUNTER                # initializing r12 as a counter
TIMER_LOOP:
    addi    r12, r12, -1                # decrementing COUNTER
    beq     r12, r0, TIMER_LOOP         # COUNTER == 0 goto TIMER_LOOP

/* Storing Z in the DATA field in the UART Control Register */
    andi    r11, r11, Z
    sthio   r11, 0(r8)                  # store ONLY the LOW halfword
    br POLLING_UART
    
END:
	br END

.end