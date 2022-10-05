library ieee;
use ieee.std_logic_1164.all;

entity interface_hcsr04_fd is
    port(
		clock			: in std_logic;
		gera			: in std_logic;
		pulso 		: in std_logic;
		registra    : in std_logic;
		zera			: in std_logic;
		medida      : out std_logic_vector(11 downto 0);
		fim_medida  : out std_logic;
		trigger     : out std_logic
    );
end entity interface_hcsr04_fd;

architecture interface_hcsr04_arch of interface_hcsr04_fd is

    component contador_cm
		port(
			clock		: in std_logic;
			pulso 		: in std_logic;
			reset       : in std_logic;
			digito0     : out std_logic_vector(3 downto 0);
			digito1     : out std_logic_vector(3 downto 0);
			digito2     : out std_logic_vector(3 downto 0);
			pronto      : out std_logic
		);
	 end component;
	 
	 component gerador_pulso
		generic (
			largura: integer:= 25
		);
		port(
			clock  : in  std_logic;
			reset  : in  std_logic;
			gera   : in  std_logic;
			para   : in  std_logic;
			pulso  : out std_logic;
			pronto : out std_logic
		);
	 end component;
	
	 component registrador_n
		generic(
			constant N : integer 
		);
		port (
			clock  : in  std_logic;
			clear  : in  std_logic;
			enable : in  std_logic;
			D      : in  std_logic_vector (N-1 downto 0);
			Q      : out std_logic_vector (N-1 downto 0) 
		);
	 end component;
	 
	 signal tick, fim_bcd, zera_tick, conta_tick, arredonda, s_trigger: std_logic;
	 signal dig0, dig1, dig2: std_logic_vector(3 downto 0);
	 signal s_valor, s_medida, s_saida: std_logic_vector(11 downto 0);

begin

	s_medida <= dig2 & dig1 & dig0;
	
	gerador: gerador_pulso
		generic map (
			largura => 500
		)
		port map(
			clock  => clock, 
			reset  => zera, 
			gera   => gera,
			para 	 => '0',
			pulso  => s_trigger,
			pronto => open	
		);
		
	registrador: registrador_n
		generic map(
			N => 12
		)
		port map(
			 clock   => clock,  
			 clear   => zera,
			 enable  => registra,
			 D       => s_medida,
			 Q       => s_saida
		
		);
		
	contador: contador_cm
		port map (
			clock 	  => clock, 
			pulso 	  => pulso,
			reset      => zera, 
			digito0    => dig0,  
			digito1    => dig1,  
			digito2    => dig2,  
			pronto     => fim_medida  
			
		);
		
		medida  <= s_saida;
		trigger <= s_trigger;
		

end interface_hcsr04_arch ;