.global _start
_start:

	add r8, r0, r0         # reset accumulator
	movia r4, 0x10000040   # base address SW7-0
	movia r3, 0x10000010   # base address GreenLed

Loop:
	ldwio r5, 0(r4)					# data
	add r8, r8, r5					# add to the accumulator
	stwio r8, 0(r3)					# store accumulator in greenled
	br Loop

END:
	br END
