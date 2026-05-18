
module DE0_Nano_Basic_Computer (
	// Inputs
	CLOCK_50,
	KEY,
	SW,

/*****************************************************************************/
	// Bidirectionals
	GPIO_0,
	GPIO_1,
	GPIO_2,
	GPIO_2_IN,

	//  Memory (SDRAM)
	DRAM_DQ,

/*****************************************************************************/
	// Outputs
	// 	Simple
	LEDG,

	//  Memory (SDRAM)
	DRAM_ADDR,
	
	DRAM_BA,
	DRAM_CLK,
	DRAM_CKE,
	DRAM_CS_N,
	DRAM_CAS_N,
	DRAM_RAS_N,
	DRAM_WE_N,
	DRAM_DQM
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input		[ 1: 0]	KEY;
input		[ 3: 0]	SW;

// Bidirectionals
inout		[31: 0]	GPIO_0;
inout		[31: 0]	GPIO_1;
inout		[12: 0]	GPIO_2;
input		[ 2: 0]	GPIO_2_IN;

//  Memory (SDRAM)
inout		[15: 0]	DRAM_DQ;

// Outputs
// 	Simple
output		[ 7: 0]	LEDG;

//  Memory (SDRAM)
output		[12: 0]	DRAM_ADDR;

output		[ 1: 0]	DRAM_BA;
output				DRAM_CLK;
output				DRAM_CKE;
output				DRAM_CS_N;
output				DRAM_CAS_N;
output				DRAM_RAS_N;
output				DRAM_WE_N;
output		[ 1: 0]	DRAM_DQM;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
// Used to connect the Nios 2 system clock to the non-shifted output of the PLL
wire				system_clock;

// Internal Registers

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/


/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

// Output Assignments

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
nios_system NiosII (
	// 1) global signals:
	.clk									(system_clock),
	.reset_n								(KEY[0]),

	// the_Dip_switches
	.DIP_to_the_Dip_switches				(SW),

	// the_Pushbuttons
	.KEY_to_the_Pushbuttons					({KEY[1], 1'b1}),

	// the_Expansion_JP1
	.GPIO_0_to_and_from_the_Expansion_JP1	(GPIO_0),

	// the_Expansion_JP2
	.GPIO_1_to_and_from_the_Expansion_JP2	(GPIO_1),

	// the_Expansion_JP3
	.GPIO_2_to_and_from_the_Expansion_JP3	(GPIO_2),

	// the_Expansion_JP3_In
	.GPIO_2_IN_to_the_Expansion_JP3_In			(GPIO_2_IN),

	// the_Green_LEDs
	.LEDG_from_the_Green_LEDs				(LEDG),

	// the SDRAM
	.zs_addr_from_the_SDRAM					(DRAM_ADDR),
	.zs_ba_from_the_SDRAM					(DRAM_BA),
	.zs_cas_n_from_the_SDRAM				(DRAM_CAS_N),
	.zs_cke_from_the_SDRAM					(DRAM_CKE),
	.zs_cs_n_from_the_SDRAM					(DRAM_CS_N),
	.zs_dq_to_and_from_the_SDRAM			(DRAM_DQ),
	.zs_dqm_from_the_SDRAM					(DRAM_DQM),
	.zs_ras_n_from_the_SDRAM				(DRAM_RAS_N),
	.zs_we_n_from_the_SDRAM					(DRAM_WE_N)
);

sdram_pll neg_3ns (CLOCK_50, DRAM_CLK, system_clock);

endmodule
