library ieee;
use ieee.std_logic_1164.all;

entity identificador_caractere is
    port (
        caractere_recebido : in  std_logic_vector(6 downto 0);
        modo               : out std_logic
    );
end entity;

architecture identificador_caractere_behavioral of identificador_caractere is
    
    constant caractere_novo_modo   : std_logic_vector(6 downto 0) := x"";
    constant caractere_modo_normal : std_logic_vector(6 downto 0) := x""; 

begin
    
    modo <= '1' when caractere_recebido = caractere_novo_modo else 
            '0';
    
end architecture identificador_caractere_behavioral;