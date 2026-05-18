LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY lights IS
    PORT (
        SW : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        KEY : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        CLOCK_50 : IN STD_LOGIC;

        LED : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

        -- SDRAM
        DRAM_CLK, DRAM_CKE : OUT STD_LOGIC;
        DRAM_ADDR : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
        DRAM_BA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        DRAM_CS_N, DRAM_CAS_N, DRAM_RAS_N, DRAM_WE_N : OUT STD_LOGIC;
        DRAM_DQ : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        DRAM_DQM : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

        -- Sorties vers driver moteur CUTECAR
        MTRL_P : OUT STD_LOGIC;
        MTRL_N : OUT STD_LOGIC;
        MTRR_P : OUT STD_LOGIC;
        MTRR_N : OUT STD_LOGIC;

        -- Enable / Sleep du driver moteur
        MTR_Sleep_n : OUT STD_LOGIC;

        -- Fault du driver moteur
        MTR_Fault_n : IN STD_LOGIC
    );
END lights;

ARCHITECTURE Structure OF lights IS

    COMPONENT v1
        PORT (
            clk_clk             : IN    STD_LOGIC;
            reset_reset_n       : IN    STD_LOGIC;
            led_export          : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
            sw_export           : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
            sdram_wire_addr     : OUT   STD_LOGIC_VECTOR(12 DOWNTO 0);
            sdram_wire_ba       : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
            sdram_wire_cas_n    : OUT   STD_LOGIC;
            sdram_wire_cke      : OUT   STD_LOGIC;
            sdram_wire_cs_n     : OUT   STD_LOGIC;
            sdram_wire_dq       : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            sdram_wire_dqm      : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
            sdram_wire_ras_n    : OUT   STD_LOGIC;
            sdram_wire_we_n     : OUT   STD_LOGIC;
            sdram_clk_clk       : OUT   STD_LOGIC;

            -- Ports PWM générés par Qsys
            pwm_motor_pwm_left  : OUT   STD_LOGIC;
            pwm_motor_pwm_right : OUT   STD_LOGIC;
            pwm_motor_dir_left  : OUT   STD_LOGIC;
            pwm_motor_dir_right : OUT   STD_LOGIC
        );
    END COMPONENT;

    -- Signaux internes venant de ton IP PWM
    SIGNAL pwm_left_sig  : STD_LOGIC;
    SIGNAL pwm_right_sig : STD_LOGIC;
    SIGNAL dir_left_sig  : STD_LOGIC;
    SIGNAL dir_right_sig : STD_LOGIC;

BEGIN

    NiosII: v1
        PORT MAP (
            clk_clk             => CLOCK_50,
            reset_reset_n       => KEY(0),

            led_export          => LED,
            sw_export           => SW,

            sdram_wire_addr     => DRAM_ADDR,
            sdram_wire_ba       => DRAM_BA,
            sdram_wire_cas_n    => DRAM_CAS_N,
            sdram_wire_cke      => DRAM_CKE,
            sdram_wire_cs_n     => DRAM_CS_N,
            sdram_wire_dq       => DRAM_DQ,
            sdram_wire_dqm      => DRAM_DQM,
            sdram_wire_ras_n    => DRAM_RAS_N,
            sdram_wire_we_n     => DRAM_WE_N,
            sdram_clk_clk       => DRAM_CLK,

            -- Connexion PWM Qsys vers signaux internes
            pwm_motor_pwm_left  => pwm_left_sig,
            pwm_motor_pwm_right => pwm_right_sig,
            pwm_motor_dir_left  => dir_left_sig,
            pwm_motor_dir_right => dir_right_sig
        );

    --------------------------------------------------------------------
    -- Activation du driver moteur
    --------------------------------------------------------------------
    MTR_Sleep_n <= '1';

    --------------------------------------------------------------------
    -- Conversion PWM + DIR vers entrées moteur P/N
    --------------------------------------------------------------------

    -- Moteur gauche
    MTRL_P <= pwm_left_sig WHEN dir_left_sig = '1' ELSE '0';
    MTRL_N <= pwm_left_sig WHEN dir_left_sig = '0' ELSE '0';

    -- Moteur droit
    MTRR_P <= pwm_right_sig WHEN dir_right_sig = '1' ELSE '0';
    MTRR_N <= pwm_right_sig WHEN dir_right_sig = '0' ELSE '0';

END Structure;