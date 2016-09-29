/**********************************************
 * Authors:                                   *
 * Dalton Lima @daltonbr                      *
 * Giovanna Cazelato @giovannaC               *
 * Lucas Pinheiro @lucaspin                   *
 *********************************************/
 /**********************************************
 *  Audio port IRQ 6                           *
 *  audio base adress 0x10003040 ~ 0x1000304F  *
 *  44.1KHz = 0xAC44                           *
 *  22KHz = 0x55F0                             *
 *  SRAM base adress 0x08000000 ~ 0x0807FFFF   *
 *  96KHz x 3(sec) = 0x46500                   *
 *  1111 1111 0000 0000 = 0XFF00 //mask FIFO   *
 *	0000 0000 0000 0100 = 0x4    //mask CR     *
 *  0000 0000 0000 1000 = 0x8    //mask CW     *
 **********************************************/
.data  # .org?
buffer:
.word 
.skip 0x46500
.equ memory_base_address 0x46500  # starting point of the audio

.global _start
_start:

	addi r8, r0, 0x46500    	# sampling rate / counter
	movia r9, 0x10003040    	# base adress Audio
	movia r10, 0x10000050   	# base adress pushbotton
    movia r13, 0xFF00       	# mask to check FIFO empty
    movia r16, 0x4              # mask CR
    movia r17, 0x8              # mask CW

    movia r19, memory_base_address  # r19 memory pointer
Loop:
	ldwio r11, 12(r10)      	# load edgecapture PushButton
	beq r11, r0, Loop	    	# if (PB == 0) goto Loop 
	stwio r0, 12(r10)	    	# reset PB 
	
	/* Reset buffer */
	ldwio r18, 0(r9)			#r18 is temp
	or r18, r18, r16            # mask to CR
	stwio r18, 0(r9)			# CR = 1
	sub r18, r18, r16	        # CR = 0
	stwio r18, 0(r9)

	CHECK_FIFO_EMPTY:
		addi r15, r9, 4     	# load FIFO space register
		and r14, r13, r15   	# apply mask to check RARC
		beq r14, r0, CHECK_FIFO_EMPTY # while FIFO == 0 loops
		br RECORD

	RECORD:                 	# 3s loop		
		ldwio r12, 4(r9)    	# read sample
		stw r12, 0(r19)			# store sample in memory
		addi r19, r19, 4 		# advance the memory pointer
		addi r8, r8, -1     	# dec counter
		bne r8, r0, CHECK_FIFO  	# if (couter != 0) goto CHECK_FIFO

# at this point the sound was recorded
# now we gonna play that mothafuck

play_loop:
	ldwio r11, 12(r10)      	# load edgecapture PushButton
	beq r11, r0, play_loop	    	# if (PB == 0) goto play_loop 
	stwio r0, 12(r10)	    	# reset PB 
	
	/* Reset buffer */
	ldwio r18, 0(r9)			# r18 is temp
	or r18, r18, r17			# mask to CW            
	stwio r18, 0(r9)			# CW = 1
	sub r18, r18, r17	        # CW = 0
	stwio r18, 0(r9)
	movia r19, memory_base_address  # r19 reset the memory pointer
	addi r8, r0, 0x46500    	# reset sampling rate / counter

	CHECK_FIFO_FULL:
		addi r15, r9, 4     			# load FIFO space register
		andi r14, r15, 0xFF000000   	# apply mask to check WSLC | r14 is temp
		beq r14, r0, CHECK_FIFO_FULL # while FIFO == 0 loops
		br play

	play:
		ldw r18, 0(r19)		# temp = data (sample)
		stwio r18, 12(r9)	# stored 1 sample in the outpub buffer
		addi r19, r19, 4  	# advance the memory pointer
		addi r8, r8, -1     # dec counter
		bne r8, r0, CHECK_FIFO_FULL # check if all the samples were loaded

END:
	br END