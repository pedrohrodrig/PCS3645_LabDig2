library ieee;
use ieee.std_logic_1164.all;

entity interface_hcsr04 is
    port (
        clock 		: in std_logic;
        reset 		: in std_logic;
        medir 		: in std_logic;
        echo 		: in std_logic;
        trigger 	: out std_logic;
        medida 	    : out std_logic_vector (11 downto 0); -- 3 digitos BCD
        pronto 	    : out std_logic;
		db_reset    : out std_logic;
		db_medir    : out std_logic;
			db_cont    : out std_logic_vector(10 downto 0);
        db_estado   : out std_logic_vector (3 downto 0) -- estado da UC
    );
end entity interface_hcsr04;

architecture interface_hcsr04_arch of interface_hcsr04 is

	component interface_hcsr04_uc 
		port (
			clock      : in  std_logic;
			echo       : in  std_logic;
			fim_medida : in  std_logic;
        	medir      : in  std_logic;
			reset      : in  std_logic;
        	zera       : out std_logic;
        	registra   : out std_logic;
        	pronto     : out std_logic;
			gera       : out std_logic;
        	db_estado  : out std_logic_vector(3 downto 0) 
		);
	end component;
	
	component interface_hcsr04_fd
		port(
			clock	   : in std_logic;
			gera	   : in std_logic;
			pulso 	   : in std_logic;
			registra   : in std_logic;
			zera	   : in std_logic;
			medida     : out std_logic_vector(11 downto 0);
			db_cont    : out std_logic_vector(10 downto 0);
			fim_medida : out std_logic;
			trigger    : out std_logic
   		);
	end component;
	
	signal s_zera       : std_logic;
	signal s_trigger    : std_logic;
	signal s_conta      : std_logic;
	signal s_gera       : std_logic;
	signal s_pronto     : std_logic;
	signal s_registra   : std_logic;
	signal s_fim_medida : std_logic;
	signal s_db_estado  : std_logic_vector(3 downto 0);
	signal s_medida     : std_logic_vector(11 downto 0);

begin 

	FD: interface_hcsr04_fd
		port map (
			clock 	   => clock,
			gera	   => s_gera,
			pulso 	   => echo,
			registra   => s_registra,
			zera       => s_zera,
			medida 	   => s_medida,
			fim_medida => s_fim_medida,
			db_cont => db_cont,
			trigger    => s_trigger
		);
	
	UC: interface_hcsr04_uc
		port map (
			clock 	   => clock,
			echo  	   => echo,
			fim_medida => s_fim_medida,
			medir 	   => medir, 	
			reset 	   => reset, 
			zera 	   => s_zera,
			registra   => s_registra,
			pronto     => s_pronto,
			gera 	   => s_gera,
			db_estado  => s_db_estado
			
		);
		
	pronto 	  <= s_pronto;
	medida 	  <= s_medida;
	db_estado <= s_db_estado;
	trigger   <= s_trigger;
	db_reset  <= reset;
	db_medir  <= medir;

end architecture; 