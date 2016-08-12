/* Fibonacci Sequence in NIOS II (Assembly)
 *
 * Authors:
 * Dalton Lima @daltonbr
 * Giovanna Cazelato @giovannaC
 * Lucas Pinheiro @lucaspin
 *
 */

.equ LIST, 0x1000


.global  _start
_start:
  movia r4, LIST    /* r4 points to the start of the list */
  movia r5, N

  orhi r6, zero, zero     /* reseting the previous */
  or   r6, zero, zero
  ldw  r6, 0(r4)

  orhi r7, zero, zero     /* reseting the current */
  or   r7, zero, zero
  ldw  r7, 4(r4)

  orhi r8, zero, zero     /* reseting the result */
  or   r8, zero, zero

  add

LOOP:
  beq r5, zero, DONE

  /* result = previous + current; */
  add r8, r6, r7
  stw r8, 4(r4)

  /* previous = current; */
  movia r6, r7

  /* current = result; */
  movia r7, r8

  /* n--;   */
  subi r5, 1

  br LOOP:

DONE:

STOP:

.org  0x0FFC   /* 0xFFC + 0x4 = 0x1000 */
N:
.word 8
.word 0, 1
.skip 24       /* 6 elements * 4 bytes */

.end

/* A Draft in C Language

int result;
int n = 8
int previous = 0, current = 1;

while (n > 0)
{
  result = previous + current;
  previous = current;
  current = result;
  n--;
}

*/
