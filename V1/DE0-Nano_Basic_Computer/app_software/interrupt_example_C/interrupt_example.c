#include "nios2_ctrl_reg_macros.h"

/* key_dir and pattern are written by interrupt service routines; we have to declare 
 * these as volatile to avoid the compiler caching their values in registers */
volatile int key_dir = 0;
volatile	int pattern = 0x0F0F0F0F;	// pattern for LEDG lights

/********************************************************************************
 * This program demonstrates use of interrupts in the DE0-Nano Basic Computer. It
 * first starts the interval timer with 66 msec timeouts, and then enables 
 * Nios II interrupts from the interval timer and pushbutton KEYs
 *
 * The interrupt service routine for the interval timer displays a pattern on 
 * the LEDG lights, and shifts this pattern either left or right. The shifting
 * direction is reversed when KEY[1] is pressed
********************************************************************************/
int main(void)
{
	/* Declare volatile pointers to I/O registers (volatile means that IO load
	 * and store instructions will be used to access these pointer locations, 
	 * instead of regular memory loads and stores)
	*/
	volatile int * interval_timer_ptr = (int *) 0x10002000;	// interal timer base address
	volatile int * KEY_ptr = (int *) 0x10000050;					// pushbutton KEY address

	/* set the interval timer period for scrolling the LEDG lights */
	int counter = 0x320000;				// 1/(50 MHz) x (0x320000) = 66 msec
	*(interval_timer_ptr + 0x2) = (counter & 0xFFFF);
	*(interval_timer_ptr + 0x3) = (counter >> 16) & 0xFFFF;

	/* start interval timer, enable its interrupts */
	*(interval_timer_ptr + 1) = 0x7;	// STOP = 0, START = 1, CONT = 1, ITO = 1 
	
	*(KEY_ptr + 2) = 0x2; 				/* write to the pushbutton interrupt mask register, and
											 	* set KEY[1] mask bit to 1 (KEY[0] is Nios II reset) */

	NIOS2_WRITE_IENABLE( 0x3 );		/* set interrupt mask bits for levels 0 (interval
											 	* timer) and level 1 (pushbuttons) */

	NIOS2_WRITE_STATUS( 1 );			// enable Nios II interrupts

	while(1);								// main program simply idles
}
