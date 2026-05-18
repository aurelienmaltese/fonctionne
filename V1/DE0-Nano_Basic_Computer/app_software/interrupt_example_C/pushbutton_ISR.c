extern volatile int key_dir;
extern volatile int pattern;

/***************************************************************************************
 * Pushbutton - Interrupt Service Routine                                
 *                                                                          
 * This routine toggles the key_dir variable from 0 <-> 1
****************************************************************************************/
void pushbutton_ISR( void )
{
	volatile int * KEY_ptr = (int *) 0x10000050;

	// only KEY[1] can cause an interrupt on the DE0-Nano board; just clear it 
	*(KEY_ptr + 3) = 0; 						// Clear the interrupt

	key_dir ^= 1;								// Toggle key_dir value

	return;
}
