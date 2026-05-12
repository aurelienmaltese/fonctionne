LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY component_tutorial IS
    PORT (
        CLOCK_50 : IN STD_LOGIC;               -- Horloge 50 MHz de la carte DE-series
        KEY : IN STD_LOGIC_VECTOR(0 DOWNTO 0); -- Bouton KEY[0] pour le reset (actif bas)
        HEX0 : OUT STD_LOGIC_VECTOR(0 TO 6);   -- Affichage 7-segments 0
        HEX1 : OUT STD_LOGIC_VECTOR(0 TO 6);   -- Affichage 7-segments 1
        HEX2 : OUT STD_LOGIC_VECTOR(0 TO 6);   -- Affichage 7-segments 2
        HEX3 : OUT STD_LOGIC_VECTOR(0 TO 6)    -- Affichage 7-segments 3
    );
END component_tutorial;

ARCHITECTURE Structure OF component_tutorial IS
    -- Déclaration du composant embedded_system (généré par Qsys)
    COMPONENT embedded_system
        PORT (
            clk_clk : IN STD_LOGIC;
            resetn_reset_n : IN STD_LOGIC;
            to_hex_export : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    -- Déclaration du convertisseur 7-segments
    COMPONENT hex7seg
        PORT (
            hex : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            display : OUT STD_LOGIC_VECTOR(0 TO 6)
        );
    END COMPONENT;

    -- Signaux internes pour connecter to_hex_export aux affichages
    SIGNAL to_HEX : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN
    -- Instanciation du système Qsys généré
    U0: embedded_system
        PORT MAP (
            clk_clk => CLOCK_50,
            resetn_reset_n => KEY(0),
            to_hex_export => to_HEX
        );

    -- Instanciation des convertisseurs 7-segments (un par affichage)
    -- Chaque affichage (HEX0-3) affiche 4 bits de to_HEX :
    --   - HEX0 : bits 3-0 (nibble le moins significatif)
    --   - HEX1 : bits 7-4
    --   - HEX2 : bits 11-8
    --   - HEX3 : bits 15-12 (nibble le plus significatif)
    h0: hex7seg
        PORT MAP (
            hex => to_HEX(3 DOWNTO 0),
            display => HEX0
        );
    h1: hex7seg
        PORT MAP (
            hex => to_HEX(7 DOWNTO 4),
            display => HEX1
        );
    h2: hex7seg
        PORT MAP (
            hex => to_HEX(11 DOWNTO 8),
            display => HEX2
        );
    h3: hex7seg
        PORT MAP (
            hex => to_HEX(15 DOWNTO 12),
            display => HEX3
        );

END Structure;