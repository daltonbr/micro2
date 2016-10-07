/**********************************************
 * Lab 06 - Audio CODEC - sep, 28th, 2016     *
 * Part 1 - Recording and playing audio       *
 * version 1.0 - 9/29/16 (not tested)         *
 * Authors:                                   *
 * Dalton Lima @daltonbr                      *
 * Giovanna Cazelato @giovannaC               *
 * Lucas Pinheiro @lucaspin                   *
 *********************************************/
 /******************************************************
 *  Audio port IRQ 6                                   *
 *  audio base address 0x10003040 ~ 0x1000304F         *
 *  44.1KHz = 0xAC44 KHz                               *
 *  22KHz = 0x55F0 KHz                                 *
 *  Buffer size calculation                            *
 *  96KHz x 3(sec) = 288 K samples = 0x46500 words     *  
 *  288 K * 4 bytes = 1152 KB = 0x119400 bytes         *
 *  1111 1111 0000 0000 = 0XFF00 //mask FIFO           *
 *	0000 0000 0000 0100 = 0x4    //mask CR             *
 *  0000 0000 0000 1000 = 0x8    //mask CW             *
 ******************************************************/

.org        0x500
BUFFER_BASE_ADDRESS:
.word 
.skip BUFFER_SIZE   # 3000 * 96 = 288k samples = 0x46500 (or 0x119400 bytes ?) 
END_BUFFER:

.equ BUFFER_TIME,               3000                          # in miliseconds
.equ SAMPLE_RATE,               96                            # in KHz
.equ CR_mask,                   0x4
.equ CW_mask,                   0x8
.equ RALC_MASK                  0xFF00
.equ WSLC_MASK                  0xFF00                        # used as high halfword
.equ BUFFER_SIZE,               BUFFER_TIME * SAMPLE_RATE     # 288K
.equ AUDIO_BASE_ADDRESS         0x10003040
.equ PUSHBUTTON_BASE_ADDRESS    0x10000050

.text                                   # executable code follows
.global _start
_start:
    movia r8 , BUFFER_BASE_ADDRESS      # r8 will be a memory pointer
	movia r9 , END_BUFFER               # r9 will check buffer overflow
	movia r10, AUDIO_BASE_ADDRESS 	        
	movia r11, PUSHBUTTON_BASE_ADDRESS

WAIT_REC_BUTTON:                        # r12 will always be TEMP register
	ldwio r12, 12(r11)          	    # load edgecapture PushButton
	beq r12, r0, WAIT_REC_BUTTON        # if (PB == 0) goto WAIT_REC_BUTTON 
	stwio r0, 12(r11)	    	        # reset PB 
	
/* Reset buffer */
	ldwio r12, 0(r10)
	ori r12, r12, CR_mask
	stwio r12, 0(r10)	    		    # CR = 1
	subi r12, r12, CR_mask          
	stwio r12, 0(r10)                   # CR = 0

CHECK_FIFO_EMPTY:                       
    ldwio r12, 4(r10)     	            # load Fifospace register
    andi r12, r12, RALC_MASK   	        # apply mask to check RARC
    beq r12, r0, CHECK_FIFO_EMPTY       # while FIFO == 0 loops
    br RECORD

RECORD:
    ldwio r12, 4(r10)    	            # read sample
    stw r12, 0(r8)			            # store sample in memory
    addi r8, r8, 4  		            # advance the memory pointer
    bne r8, r9, RECORD                  # while (memPointer != END_BUFFER) loops

/* at this point the sound was recorded */

WAIT_PLAY_BUTTON:
    ldwio r12, 12(r11)              	# load edgecapture PushButton
    beq r12, r0, WAIT_PLAY_BUTTON       # if (PB == 0) goto WAIT_PLAY_BUTTON 
    stwio r0, 12(r11)	              	# reset PB 
	
/* Reset buffer */
	ldwio r12, 0(r10)			   
	ori r12, r12, CW_mask            
	stwio r12, 0(r10)			        # CW = 1
	subi r12, r12, CW_mask      
	stwio r12, 0(r10)                    # CW = 0
	movia r8, BUFFER_BASE_ADDRESS       # reset the memory pointer (r8)

CHECK_FIFO_FULL:
    addi r12, r10, 4     			    # load Fifospace register
    andhi r12, r12, WSLC_MASK   	    # apply mask to check WSLC
    beq r12, r0, CHECK_FIFO_FULL        # while FIFO == 0 loops
    br PLAY

PLAY:
    ldw r12, 0(r8)		                # temp = sample
    stwio r12, 12(r10)	                # stored 1 sample in the output buffer
    addi r8, r8, 4  	                # advance the memory pointer
    bne r8, r9, CHECK_FIFO_FULL         # while (memPointer != END_BUFFER) loops

END:
	br END

.end