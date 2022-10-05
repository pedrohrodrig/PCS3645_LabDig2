library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_cm is
    port(
		clock			: in std_logic;
		pulso 		: in std_logic;
		reset       : in std_logic;
		digito0     : out std_logic_vector(3 downto 0);
		digito1     : out std_logic_vector(3 downto 0);
		digito2     : out std_logic_vector(3 downto 0);
		pronto      : out std_logic
    );
end entity contador_cm;

architecture contador_cm_arch of contador_cm is

    component contador_m
    generic (
        constant M : integer;
        constant N : integer
    );
    port (
        clock : in  std_logic;
        zera  : in  std_logic;
        conta : in  std_logic;
        Q     : out std_logic_vector (N-1 downto 0);
        fim   : out std_logic
    );
    end component;
	 
	 component contador_bcd_3digitos
	 port ( 
        clock   : in  std_logic;
        zera    : in  std_logic;
        conta   : in  std_logic;
        digito0 : out std_logic_vector(3 downto 0);
        digito1 : out std_logic_vector(3 downto 0);
        digito2 : out std_logic_vector(3 downto 0);
        fim     : out std_logic
    );
	 end component;
	 
	 component analisa_m
	 generic (
        constant M : integer := 50;  
        constant N : integer := 6 
    );
    port (
        valor            : in  std_logic_vector (N-1 downto 0);
        zero             : out std_logic;
        meio             : out std_logic;
        fim              : out std_logic;
        metade_superior  : out std_logic
    );
	 end component;
	 
	 
	 signal tick, arredonda: std_logic;
	 signal dig0, dig1, dig2: std_logic_vector(3 downto 0);
	 signal s_valor, resultado, medida: std_logic_vector(11 downto 0);

begin

	resultado <= dig2 & dig1 & dig0;

	contador_tick: contador_m
		generic map (
			M => 2941,
			N => 12
		)
		port map (
			clock	 => clock,
			zera 	 => reset, 
			conta  => pulso,
			Q 		 => s_valor,
			fim 	 => tick
		);
		
	contador_cm: contador_bcd_3digitos
		port map(
			clock 	=> clock,
			zera 		=> reset,
			conta 	=> tick,
			digito0  => dig0,
			digito1  => dig1,
			digito2  => dig2,
			fim		=> open
		);
		
	analisa: analisa_m
		generic map (
			M => 2941,
			N => 12
		)
		port map (
			valor 			 => s_valor, 
			zero 				 => open,
			meio 				 => open,
			fim 				 => open,
			metade_superior => arredonda
		);
		
	medida <= std_logic_vector(to_unsigned((to_integer(unsigned(resultado)) + 1), medida'length)) when arredonda = '1' 
		  else resultado; 
	digito2 <= medida(11 downto 8);
	digito1 <= medida(7 downto 4);
	digito0 <= medida(3 downto 0);
	pronto  <= '1' when pulso='0' and resultado /= "000000000000" else '0';

end contador_cm_arch ;