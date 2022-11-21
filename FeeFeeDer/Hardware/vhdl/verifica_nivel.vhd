library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity verifica_nivel is
    port (
        medida            : in std_logic_vector(11 downto 0);
        comida_suficiente : out std_logic;
        pouca_comida      : out std_logic
    );
end entity;

architecture verifica_nivel_behavioral of verifica_nivel is
    
    constant medida_comida_suficiente : std_logic_vector(11 downto 0) := "000000001000"; -- 8cm  TODO: atribuir medida para fechamento do servomotor
    constant medida_pouca_comida      : std_logic_vector(11 downto 0) := "000000010110"; -- 22cm TODO: atribuir medida para abertura do servomotor

begin
    
    comida_suficiente <= '1' when unsigned(medida) < unsigned(medida_comida_suficiente) else '0';

    pouca_comida <= '1' when unsigned(medida) > unsigned(medida_pouca_comida) else '0';
    
end architecture verifica_nivel_behavioral;