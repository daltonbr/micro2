/***********************************************************
 * Lab 05 - UART and timers - nov 4th, 2016                *
 * Part 1 - Flashing ascii chars on Altera Monitor Program *
 * (TESTED)                                                *
 * Authors:                                                *
 * Dalton Lima @daltonbr                                   *
 * Giovanna Cazelato @giovannaC                            *
 * Lucas Pinheiro @lucaspin                                *
 ***********************************************************/
 
/*********************************************************************************************
 *                          ---=== JTAG UART REGISTERS ===---                                *
 * Address    | 31 ... 16 | 15     | 14... 11 | 10 | 9 | 8 | 7 ...| 1 | 0 |                  *
 * 0x10001000 |  RAVAIL   | RVALID |        Unused         |     DATA     | Data Register    *
 * 0x10001004 |  WSPACE   |       Unused      | AC | WI|RI |Unuse |WE |RE | Control Register *
 *********************************************************************************************/

.org        0x500

.equ WSPACE_UART_mask,          0xFFFF         # only high halfword (imm16)
.equ DATA_UART_mask,            0x00FF
.equ UART_BASE_ADDRESS,         0x10001000
.equ Z,                         0x5A            # ASCII 90 (decimal)
.equ COUNTER,                   0x4C4B40        # 5*10ˆ6 [decimal]

.text                                   # executable code follows
    .global _start
_start:
    movia   r8, UART_BASE_ADDRESS

/* Checking for Space in the FIFO for Writing (WSPACE) */
POLLING_UART:
	ldwio   r9, 4(r8)        	        # r9 = UART Control Register (entire word)
    andhi   r9, r9, WSPACE_UART_mask    # andhi gets the highest bits and reset the lowest 16 bits
    beq     r9, r0, POLLING_UART        # if (WSPACE == 0) loops

/* 5*10ˆ6 cycles = 4secs (SDRAM) or 0.5 sec (SRAM) */
    movia   r11, COUNTER                # initializing r11 as a counter
TIMER_LOOP:
    addi    r11, r11, -1                # decrementing COUNTER
    bne     r11, r0, TIMER_LOOP         # COUNTER != 0 goto TIMER_LOOP

/* Storing Z in the DATA field in the UART Control Register */
    addi    r10, r0, Z
    sthio   r10, 0(r8)                  # store ONLY the LOW halfword
    br POLLING_UART
    
.end
