/**********************************************
 * Lab 06 - Audio CODEC - sep, 30th, 2016     *
 * Part 2 - Recording and playing audio       *
 * version 0.1 - 10/01/16 (not tested)         *
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

#include <stdio.h>
#define BUFFER_TIME         3000                         // in miliseconds
#define SAMPLE_RATE         96                           // in KHz
#define BUFFER_SIZE         (BUFFER_TIME * SAMPLE_RATE)  // in words (32 bits)
#define KEY1                2
#define KEY2                4
#define KEY3                8
#define CW_MASK             0x8                         // 1000[bin] - Clear WRITE Audio Buffer
#define CR_MASK             0x4                         //  100[bin] - Clear READ Audio Buffer

int main(void)
{
    /* Declare volatile pointer to I/O registers (volatile means that IO load and store
    instructions (e.g. ldwio, stwio ) will be used to access these pointer locations) */
    volatile int * KEY_ptr                = (int *) 0x10000050;            // PushButton KEY address
    volatile int * AUDIO_CONTROL_ptr      = (int *) 0x10003040;            // AUDIO CONTROL and BASE address
    volatile int * AUDIO_L_ptr            = (int *) 0x10003048;            // AUDIO LEFT CHANNEL address
    /* SDRAM 0x00000000 ~0x007FFFFF */ 
    int * BUFFER_BASE_ptr                 = (int *) 0x00000500;            // Starting position of the buffer
    int * BUFFER_END_ptr                  = BUFFER_BASE_ptr + BUFFER_SIZE; // End of the buffer
    int *BUFFER_ptr;                                                       // our memory pointer

// Set our pointer at the base of the buffer    
    BUFFER_ptr = BUFFER_BASE_ptr;                                          

// Wait for REC button (KEY1)
    while (!(*KEY_ptr == KEY1));                 // wait for PushButton KEY1 press
    while (*KEY_ptr);                            // wait for PushButton KEYs release

/* Reset the RECORD audio buffer */
    *(AUDIO_CONTROL_ptr) =  CR_MASK;             // CR = 1
    *(AUDIO_CONTROL_ptr) =  0;                   // CR = 0

/* Record */
    while (*BUFFER_ptr >= *BUFFER_END_ptr)       // WHile we have space in our buffer
    {   
        // if we have samples to read (mask to RARC) ...
        if (((*(AUDIO_CONTROL_ptr + 1) & 0x000000FF) != 00 ) )
        {
            *BUFFER_ptr = *AUDIO_L_ptr;          // writes the sample to the memory buffer
            BUFFER_ptr++;                        // increment our memory buffer
        }
    }

/* RESET our pointer at the base of the buffer */
    BUFFER_ptr = BUFFER_BASE_ptr;            

/* Reset PLAYBACK audio buffer */
    *(AUDIO_CONTROL_ptr) =  CW_MASK;             // CW = 1
    *(AUDIO_CONTROL_ptr) =  0;                   // CW = 0

/* Playback */
    while (*BUFFER_ptr >= *BUFFER_END_ptr)       // WHile we have space in our buffer
    {   
        // if we have space in the output buffer (mask to WSRC) ...
        if (((*(AUDIO_CONTROL_ptr + 1) & 0x00FF0000) != 00 ) )
        {
            *AUDIO_L_ptr = *BUFFER_ptr;          // writes the sample to the output buffer
            BUFFER_ptr++;                        // increment our memory buffer
        }
    }
}