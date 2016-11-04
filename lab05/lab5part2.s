/***********************************************************
 * Lab 05 - UART and timers - nov 4th, 2016                *
 * Part 2 - Writing to UART                                *
 * (TESTED)                         	     		       *
 * Authors:                                                *
 * Dalton Lima @daltonbr                                   *
 * Giovanna Cazelato @giovannaC                            *
 * Lucas Pinheiro @lucaspin                                *
 ***********************************************************/
 
/*********************************************************************************************
 *                          ---=== JTA UART REGISTERS ===---                                 *
 * Address    | 31 ... 16 | 15     | 14... 11 | 10 | 9 | 8 | 7 ...| 1 | 0 |                  *
 * 0x10001000 |  RAVAIL   | RAVAIL |        Unused         |     DATA     | Data Register    *
 * 0x10001004 |  WSPACE   |       Unused      | AC | WI|RI |Unuse |WE |RE | Control Register *
 *********************************************************************************************/

.org        0x500

.equ WSPACE_UART_mask,          0xFF00              # only high halfword (imm16)
.equ RAVAIL_UART_mask,          0xFF00              # only high halfword (imm16)
.equ DATA_UART_mask,            0x00FF
.equ RVALID_UART_mask,          0b1000000000000000  # more visual than 65536 [decimal]  or 0x8000 
.equ UART_BASE_ADDRESS,         0x10001000

.text                                   # executable code follows
    .global _start
_start:
    movia   r8, UART_BASE_ADDRESS

/* Checking for Space in the FIFO for READING (RVALID) */
POLLING_UART:
    ldwio   r9, 0(r8)                   # r9 = UART Data Register (entire word)
 	andi    r9, r9, RVALID_UART_mask    # getting the RVALID
    beq     r9, r0, POLLING_UART        # if (RAVAIL == 0) loops

/* Reading the character */
    ldbio   r10, 0(r8)                  # r10 = DATA (1 byte)

/* Writing the readed char to the DATA field in the UART Control Register */
    stbio   r10, 0(r8)                  # Writing in the DATA (note: writing into this register 
    br POLLING_UART                     # has no effect on received data)    
    
.end