LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY pwm_avalon_interface IS
PORT (
    -- Clock and reset
    clock       : IN  STD_LOGIC;
    resetn      : IN  STD_LOGIC;

    -- Avalon Memory-Mapped Slave interface
    address     : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
    chipselect  : IN  STD_LOGIC;
    write       : IN  STD_LOGIC;
    read        : IN  STD_LOGIC;
    writedata   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    readdata    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    byteenable  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- External conduit outputs for motors
    pwm_left    : OUT STD_LOGIC;
    pwm_right   : OUT STD_LOGIC;
    dir_left    : OUT STD_LOGIC;
    dir_right   : OUT STD_LOGIC
);
END pwm_avalon_interface;

ARCHITECTURE Behavior OF pwm_avalon_interface IS

    -- Internal registers
    SIGNAL control_reg    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL period_reg     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL duty_left_reg  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL duty_right_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- PWM counter
    SIGNAL counter : UNSIGNED(31 DOWNTO 0);

    -- Converted values for comparison
    SIGNAL period_value   : UNSIGNED(31 DOWNTO 0);
    SIGNAL duty_left_val  : UNSIGNED(31 DOWNTO 0);
    SIGNAL duty_right_val : UNSIGNED(31 DOWNTO 0);

BEGIN

    period_value   <= UNSIGNED(period_reg);
    duty_left_val  <= UNSIGNED(duty_left_reg);
    duty_right_val <= UNSIGNED(duty_right_reg);

    --------------------------------------------------------------------
    -- Avalon-MM write process
    --------------------------------------------------------------------
    PROCESS(clock)
    BEGIN
        IF rising_edge(clock) THEN

            IF resetn = '0' THEN

                control_reg    <= (OTHERS => '0');
                period_reg     <= STD_LOGIC_VECTOR(TO_UNSIGNED(50000, 32));
                duty_left_reg  <= (OTHERS => '0');
                duty_right_reg <= (OTHERS => '0');

            ELSE

                IF chipselect = '1' AND write = '1' THEN

                    CASE address IS

                        -- Register 0: control_reg
                        -- bit 0 = enable PWM
                        -- bit 1 = dir_left
                        -- bit 2 = dir_right
                        WHEN "00" =>

                            IF byteenable(0) = '1' THEN
                                control_reg(7 DOWNTO 0) <= writedata(7 DOWNTO 0);
                            END IF;

                            IF byteenable(1) = '1' THEN
                                control_reg(15 DOWNTO 8) <= writedata(15 DOWNTO 8);
                            END IF;

                            IF byteenable(2) = '1' THEN
                                control_reg(23 DOWNTO 16) <= writedata(23 DOWNTO 16);
                            END IF;

                            IF byteenable(3) = '1' THEN
                                control_reg(31 DOWNTO 24) <= writedata(31 DOWNTO 24);
                            END IF;

                        -- Register 1: period_reg
                        WHEN "01" =>

                            IF byteenable(0) = '1' THEN
                                period_reg(7 DOWNTO 0) <= writedata(7 DOWNTO 0);
                            END IF;

                            IF byteenable(1) = '1' THEN
                                period_reg(15 DOWNTO 8) <= writedata(15 DOWNTO 8);
                            END IF;

                            IF byteenable(2) = '1' THEN
                                period_reg(23 DOWNTO 16) <= writedata(23 DOWNTO 16);
                            END IF;

                            IF byteenable(3) = '1' THEN
                                period_reg(31 DOWNTO 24) <= writedata(31 DOWNTO 24);
                            END IF;

                        -- Register 2: duty_left_reg
                        WHEN "10" =>

                            IF byteenable(0) = '1' THEN
                                duty_left_reg(7 DOWNTO 0) <= writedata(7 DOWNTO 0);
                            END IF;

                            IF byteenable(1) = '1' THEN
                                duty_left_reg(15 DOWNTO 8) <= writedata(15 DOWNTO 8);
                            END IF;

                            IF byteenable(2) = '1' THEN
                                duty_left_reg(23 DOWNTO 16) <= writedata(23 DOWNTO 16);
                            END IF;

                            IF byteenable(3) = '1' THEN
                                duty_left_reg(31 DOWNTO 24) <= writedata(31 DOWNTO 24);
                            END IF;

                        -- Register 3: duty_right_reg
                        WHEN "11" =>

                            IF byteenable(0) = '1' THEN
                                duty_right_reg(7 DOWNTO 0) <= writedata(7 DOWNTO 0);
                            END IF;

                            IF byteenable(1) = '1' THEN
                                duty_right_reg(15 DOWNTO 8) <= writedata(15 DOWNTO 8);
                            END IF;

                            IF byteenable(2) = '1' THEN
                                duty_right_reg(23 DOWNTO 16) <= writedata(23 DOWNTO 16);
                            END IF;

                            IF byteenable(3) = '1' THEN
                                duty_right_reg(31 DOWNTO 24) <= writedata(31 DOWNTO 24);
                            END IF;

                        WHEN OTHERS =>
                            NULL;

                    END CASE;

                END IF;

            END IF;

        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Avalon-MM read process
    --------------------------------------------------------------------
    PROCESS(address, control_reg, period_reg, duty_left_reg, duty_right_reg)
    BEGIN

        CASE address IS

            WHEN "00" =>
                readdata <= control_reg;

            WHEN "01" =>
                readdata <= period_reg;

            WHEN "10" =>
                readdata <= duty_left_reg;

            WHEN "11" =>
                readdata <= duty_right_reg;

            WHEN OTHERS =>
                readdata <= (OTHERS => '0');

        END CASE;

    END PROCESS;

    --------------------------------------------------------------------
    -- PWM counter
    --------------------------------------------------------------------
    PROCESS(clock)
    BEGIN
        IF rising_edge(clock) THEN

            IF resetn = '0' THEN

                counter <= (OTHERS => '0');

            ELSE

                IF period_value = 0 THEN
                    counter <= (OTHERS => '0');

                ELSIF counter >= period_value - 1 THEN
                    counter <= (OTHERS => '0');

                ELSE
                    counter <= counter + 1;

                END IF;

            END IF;

        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- PWM outputs
    --------------------------------------------------------------------
    pwm_left <= '1' WHEN control_reg(0) = '1'
                      AND period_value /= 0
                      AND counter < duty_left_val
                ELSE '0';

    pwm_right <= '1' WHEN control_reg(0) = '1'
                       AND period_value /= 0
                       AND counter < duty_right_val
                 ELSE '0';

    --------------------------------------------------------------------
    -- Direction outputs
    --------------------------------------------------------------------
    dir_left  <= control_reg(1);
    dir_right <= control_reg(2);

END Behavior;