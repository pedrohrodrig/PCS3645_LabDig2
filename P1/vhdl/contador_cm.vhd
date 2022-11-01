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
        fim   : out std_logic;
		  meio  : out std_logic
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
	 signal dig0, dig1, dig2, dig0_arredondado,dig1_arredondado, dig2_arredondado: std_logic_vector(3 downto 0);
	 signal s_valor, resultado: std_logic_vector(11 downto 0);

begin

	resultado <= dig2_arredondado & dig1_arredondado & dig0_arredondado;

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
			fim 	 => tick,
			meio   => open
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
		
	dig0_arredondado <= std_logic_vector(to_unsigned((to_integer(unsigned(dig0)) + 1), dig0'length)) when (arredonda = '1' and dig0 /= x"9") else
							                                                                          x"0" when (arredonda = '1' and dig0 = x"9" and (dig1 /= x"9" and dig2 /= x"9")) else 
																															  dig0;
		
	dig1_arredondado <= std_logic_vector(to_unsigned((to_integer(unsigned(dig1)) + 1), dig1'length)) when (arredonda = '1' and dig0 = x"9" and dig1 /= x"9" and dig2 /= x"9") else
																															  x"0" when (arredonda = '1' and dig1 = x"9" and dig0_arredondado /= dig0) else
																															  dig1; 
		  
	dig2_arredondado <= std_logic_vector(to_unsigned((to_integer(unsigned(dig2)) + 1), dig2'length)) when (arredonda = '1' and dig2 /= x"9" and dig1_arredondado /= dig1)
		                                                                                              else dig2; 
		
	digito2 <= resultado(11 downto 8);
	digito1 <= resultado(7 downto 4);
	digito0 <= resultado(3 downto 0);
	pronto  <= '1' when pulso='0' and resultado /= "000000000000" else '0';

end contador_cm_arch ;