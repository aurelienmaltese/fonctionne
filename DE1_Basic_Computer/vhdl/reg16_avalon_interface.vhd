LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY reg16_avalon_interface IS
PORT (
    clock      : IN  STD_LOGIC;
    resetn     : IN  STD_LOGIC;
    read       : IN  STD_LOGIC;
    write      : IN  STD_LOGIC;
    chipselect : IN  STD_LOGIC;
    writedata  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    byteenable  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
    readdata    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    Q_export    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)  -- Signal exporté vers l'extérieur
);
END reg16_avalon_interface;

ARCHITECTURE Structure OF reg16_avalon_interface IS
    SIGNAL local_byteenable : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL to_reg, from_reg : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
    to_reg <= writedata;
    local_byteenable <= byteenable WHEN (chipselect = '1' AND write = '1') ELSE "00";

    -- Instanciation du registre
    reg_instance: ENTITY work.reg16
        PORT MAP (
            clock      => clock,
            resetn     => resetn,
            D          => to_reg,
            byteenable => local_byteenable,
            Q          => from_reg
        );

    readdata   <= from_reg;
    Q_export   <= from_reg;  -- Exporte la valeur du registre vers l'extérieur
END Structure;