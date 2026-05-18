.extern	PATTERN						/* externally defined variables */
.extern	KEY_DIR					

/*****************************************************************************
 * Interval timer interrupt service routine
 *                                                                          
 * Shifts a PATTERN being displayed on the LEDG lights. The shift direction 
 * is determined by the external variable KEY_PRESSED.
 * 
******************************************************************************/
	.global INTERVAL_TIMER_ISR
INTERVAL_TIMER_ISR:					
	subi		sp,  sp, 36				/* reserve space on the stack */
   stw		ra, 0(sp)
   stw		r4, 4(sp)
   stw		r5, 8(sp)
   stw		r6, 12(sp)
   stw		r8, 16(sp)
   stw		r10, 20(sp)
   stw		r20, 24(sp)
   stw		r21, 28(sp)
   stw		r22, 32(sp)

	movia		r10, 0x10002000		/* interval timer base address */
	sthio		r0,  0(r10)				/* clear the interrupt */

	movia		r20, 0x10000010		/* LEDG base address */
	addi		r5, r0, 1 				/* set r5 to the constant value 1 */
	movia		r21, PATTERN			/* set up a pointer to the pattern for LEDG lights */
	movia		r22, KEY_DIR			/* set up a pointer to the direction variable */

	ldw		r6, 0(r21)				/* load pattern for LEDG lights */
	stwio		r6, 0(r20)				/* store to LEDG */

	ldw		r4, 0(r22)				/* check which direction is active */
	beq		r4, r0, RIGHT			/* for KEY_DIR == 0, shift right */
	rol		r6, r6, r5				/* else shift left */
	br	 		END_INTERVAL_TIMER_ISR
RIGHT:
	ror		r6, r6, r5				/* rotate the displayed pattern right */

END_INTERVAL_TIMER_ISR:
	stw		r6, 0(r21)				/* store LEDG light pattern */

   ldw		ra, 0(sp)				/* Restore all used register to previous */
   ldw		r4, 4(sp)
  	ldw		r5, 8(sp)
   ldw		r6, 12(sp)
   ldw		r8, 16(sp)
   ldw		r10, 20(sp)
   ldw		r20, 24(sp)
   ldw		r21, 28(sp)
   ldw		r22, 32(sp)
   addi		sp,  sp, 36				/* release the reserved space on the stack */

	ret

	.end
	
