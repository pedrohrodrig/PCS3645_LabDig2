library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity verifica_nivel is
	 generic (
		  medida_pouca_comida      : std_logic_vector(11 downto 0) := "000000010011";
		  medida_comida_suficiente : std_logic_vector(11 downto 0) := "000000010010"
	 );
    port (
		  clock, reset      : in std_logic;
		  enable_reg        : in std_logic;
        medida            : in std_logic_vector(11 downto 0);
        comida_suficiente : out std_logic;
        pouca_comida      : out std_logic
    );
end entity;

architecture verifica_nivel_behavioral of verifica_nivel is
    
begin

	 process(clock, reset, enable_reg)
	 
	 begin
	 
		if reset = '1' then 
			comida_suficiente <= '0';
			pouca_comida      <= '0';
		elsif clock'event and clock = '1' and enable_reg = '1' then
			if unsigned(medida) < unsigned(medida_comida_suficiente) then 
				comida_suficiente <= '1';
			else
				comida_suficiente <= '0';
			end if;
			
			if unsigned(medida) > unsigned(medida_pouca_comida) then
				pouca_comida <= '1';
			else 
				pouca_comida <= '0';
			end if;
		end if;
		
	end process;
    
end architecture verifica_nivel_behavioral;