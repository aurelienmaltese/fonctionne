/* This program demonstrates use of parallel ports in the DE0-Nano Basic Computer
 *
 * It performs the following: 
 *  	1. displays a rotating pattern on the green LEDG
 * 	2. if KEY[1] is pressed, uses the SW (DIP) switches as the pattern
*/
int main(void)
{
	/* Declare volatile pointers to I/O registers (volatile means that IO load
	 * and store instructions will be used to access these pointer locations, 
	 * instead of regular memory loads and stores)
	*/
	volatile int * green_LED_ptr	= (int *) 0x10000010;	// green LED address
	volatile int * SW_switch_ptr	= (int *) 0x10000040;	// SW slider switch address
	volatile int * KEY_ptr			= (int *) 0x10000050;	// pushbutton KEY address

	int LEDG_bits = 0x0F0F0F0F;				// pattern for LEDG lights
	int SW_value, KEY_value;
	volatile int delay_count;					// volatile so the C compiler doesn't remove the loop

	while(1)
	{
		SW_value = *(SW_switch_ptr);		 	// read the SW slider (DIP) switch values

		KEY_value = *(KEY_ptr); 				// read the pushbutton KEY values
		if (KEY_value != 0)						// check if any KEY was pressed
		{
			/* set pattern using SW values */
			LEDG_bits = SW_value | (SW_value << 8) | (SW_value << 16) | (SW_value << 24);
			while (*KEY_ptr);						// wait for pushbutton KEY release
		}
		*(green_LED_ptr) = LEDG_bits; 			// light up the green LEDs

		/* rotate the pattern shown on the LEDs */
		if (LEDG_bits & 0x80000000)
			LEDG_bits = (LEDG_bits << 1) | 1;
		else
			LEDG_bits = LEDG_bits << 1;

		for (delay_count = 150000; delay_count != 0; --delay_count); // delay loop
	}
}
