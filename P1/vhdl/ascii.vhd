library ieee;
use ieee.std_logic_1164.all;

entity ascii is
    port (
        dado  : in  std_logic_vector(3 downto 0);
        saida : out std_logic_vector(7 downto 0)
    );
end entity;

architecture comportamental of ascii is
	signal s_dado: std_logic_vector(7 downto 0);
begin
    
	 s_dado <= "0011" & dado;
	 saida <= s_dado;
	 
end architecture comportamental;