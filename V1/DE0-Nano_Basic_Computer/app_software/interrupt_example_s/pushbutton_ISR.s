.extern	KEY_DIR					/* externally defined variable */
/***************************************************************************************
 * Pushbutton - Interrupt Service Routine                                
 *                                                                          
 * This routine toggles the KEY_DIR variable from 0 <-> 1
****************************************************************************************/
	.global	PUSHBUTTON_ISR
PUSHBUTTON_ISR:
	subi		sp, sp, 16					/* reserve space on the stack */
   stw		ra, 0(sp)
   stw		r10, 4(sp)
   stw		r11, 8(sp)
   stw		r12, 12(sp)

	movia		r10, 0x10000050			/* base address of pushbutton KEY parallel port */
	/* only KEY[1] could have caused the interrupt on the DE0-Nano board; just clear it */
	stwio		zero, 0xC(r10)				/* clear the interrupt */                  

	movia		r11, KEY_DIR				/* global variable to return the result */
	ldw		r12, 0(r11)					/* load current KEY_DIR value */
	xori		r12, r12, 1					/* toggle value */
	stw		r12, 0(r11)					/* store the toggled value */

END_PUSHBUTTON_ISR:
   ldw		ra,  0(sp)					/* Restore all used register to previous */
   ldw		r10, 4(sp)
   ldw		r11, 8(sp)
   ldw		r12, 12(sp)
   addi		sp,  sp, 16

	ret
	.end
	
