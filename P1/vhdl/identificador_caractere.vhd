library ieee;
use ieee.std_logic_1164.all;

entity identificador_caractere is
    port (
        caractere_recebido : in  std_logic_vector(6 downto 0);
		  reset			   : in  std_logic;
		  clock		       : in  std_logic;
		  pronto		   : in  std_logic;
		  normal		   : out std_logic;
		  lento   		   : out std_logic
    );
end entity;

architecture identificador_caractere_behavioral of identificador_caractere is
    
    constant caractere_normal : std_logic_vector(7 downto 0) := x"4E";
    constant caractere_lento  : std_logic_vector(7 downto 0) := x"4C";
	
	 signal s_normal, s_lento : std_logic;

begin
    
	 s_normal <= '1' when caractere_recebido = caractere_normal(6 downto 0) else '0';
	 s_lento  <= '1' when caractere_recebido = caractere_lento(6 downto 0) else '0';
	 
	 process(clock, reset) 
		begin 
			if reset = '1' then 
				normal <= '0';
				lento  <= '0'; 
			elsif clock'event and clock = '1' then
				if pronto = '1' and (s_normal = '1' or s_lento = '1') then 
					normal <= s_normal;
					lento  <= s_lento;
				end if;
			end if;
	 end process;
end architecture identificador_caractere_behavioral;