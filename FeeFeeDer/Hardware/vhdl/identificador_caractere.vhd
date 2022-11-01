library ieee;
use ieee.std_logic_1164.all;

entity identificador_caractere is
    port (
        caractere_recebido : in  std_logic_vector(6 downto 0);
		  reset					: in  std_logic;
		  clock					: in  std_logic;
		  pronto					: in  std_logic;
		  pause					: out std_logic;
		  reinicio				: out std_logic
    );
end entity;

architecture identificador_caractere_behavioral of identificador_caractere is
    
    constant caractere_pause    : std_logic_vector(7 downto 0) := x"70";
    constant caractere_reinicio : std_logic_vector(7 downto 0) := x"72";
	
	 signal s_pause, s_reinicio : std_logic;

begin
    
	 s_pause <= '1' when caractere_recebido = caractere_pause(6 downto 0) else '0';
	 s_reinicio <= '1' when caractere_recebido = caractere_reinicio(6 downto 0) else '0';
	 
	 process(clock, reset) 
		begin 
			if reset = '1' then 
				pause <= '0';
				reinicio <= '0'; 
			elsif clock'event and clock = '1' then
				if pronto = '1' and (s_pause = '1' or s_reinicio = '1') then 
					pause <= s_pause;
					reinicio <= s_reinicio;
				end if;
			end if;
	 end process;
end architecture identificador_caractere_behavioral;