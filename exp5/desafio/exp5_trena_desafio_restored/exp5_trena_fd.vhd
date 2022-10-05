library ieee;
use ieee.std_logic_1164.all;

entity exp5_trena_fd is
    port(
		clock					: in std_logic;
		reset					: in std_logic;
		mensurar				: in std_logic;
		transmitir     	: in std_logic;
		echo        		: in std_logic;
		zera					: in std_logic;
		conta 				: in std_logic;
		dado					: in std_logic_vector(6 downto 0);
		modo              : in std_logic;
		saida_serial		: out std_logic;
		mensurar_auto     : out std_logic;
		medida_total        : out std_logic_vector(11 downto 0);
		medida0 				: out std_logic_vector (6 downto 0);
		medida1 				: out std_logic_vector (6 downto 0);
		medida2	 			: out std_logic_vector (6 downto 0);
		fim_contagem		: out std_logic;
		fim_medida  		: out std_logic;
		fim_transmissao   : out std_logic;
		trigger     		: out std_logic;
		db_estado_medida  : out std_logic_vector(6 downto 0);
		db_medir				: out std_logic;
		db_echo           : out std_logic;
		db_trigger        : out std_logic;
		contador				: out std_logic_vector(2 downto 0)
    );
end entity exp5_trena_fd;

architecture exp5_trena_fd_arch of exp5_trena_fd is

	component exp4_sensor is
    port (
        clock      : in std_logic;
        reset      : in std_logic;
        medir      : in std_logic;
        echo       : in std_logic;
        trigger    : out std_logic;
		medida     : out std_logic_vector(11 downto 0);
        hex0       : out std_logic_vector(6 downto 0); -- digitos da medida
        hex1       : out std_logic_vector(6 downto 0);
        hex2       : out std_logic_vector(6 downto 0);
        pronto     : out std_logic;
        db_medir   : out std_logic;
        db_echo    : out std_logic;
        db_trigger : out std_logic;
        db_estado  : out std_logic_vector(6 downto 0) -- estado da UC
    );
	end component;
	
	component tx_serial_7E2 is
	port (
		clock : in std_logic;
		reset : in std_logic;
		partida : in std_logic;
		dados_ascii : in std_logic_vector (6 downto 0);
		saida_serial : out std_logic;
		pronto : out std_logic
	);
	end component;
	
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
	

	signal db_medir_s, db_echo_s, db_trigger_s, s_pronto_medida: std_logic;	
	signal s_pronto_transmissao: std_logic;
	signal s_contagem: std_logic_vector(2 downto 0);
	signal db_estado_medida_s: std_logic_vector(6 downto 0);
	
begin

	sensor: exp4_sensor
	port map (
		  clock 	 		=> clock,    
        reset	 		=> reset,    
        medir 	 		=> mensurar,    
        echo    		=> echo,   
        trigger 		=> trigger,  
		medida          => medida_total,
        hex0    		=> medida0,  
        hex1    		=> medida1,  
        hex2    		=> medida2, 
        pronto  		=> s_pronto_medida,  
        db_medir		=> db_medir_s,  
        db_echo   	=> db_echo_s,
        db_trigger	=> db_trigger_s,
        db_estado 	=> db_estado_medida_s
	);
	
	transmissor: tx_serial_7E2
	port map(
		clock 			=> clock,
		reset 			=> reset,
		partida  		=> transmitir,
		dados_ascii 	=> dado,
		saida_serial 	=> saida_serial,
		pronto 			=> s_pronto_transmissao
	);
	
	contagem: contador_m
	generic map(
		M => 4,
		N => 3
	)
	port map(
		clock	 => clock,
		zera 	 => zera, 
		conta  => conta,
		Q 		 => s_contagem,
		fim 	 => fim_contagem
	);
	
	contagem_auto: contador_m
	generic map(
		M => 50000000,
		N => 26
	)
	port map(
		clock => clock,
		zera  => zera,
		conta => modo,
		Q     => open,
		fim   => mensurar_auto
	);
	
	contador 			<= s_contagem;
	db_estado_medida  <= db_estado_medida_s;
	fim_medida 			<= s_pronto_medida;
	fim_transmissao 	<= s_pronto_transmissao;
	db_medir 			<= db_medir_s;			
	db_echo  			<= db_echo_s;         
	db_trigger 			<= db_trigger_s;       
		

end exp5_trena_fd_arch ;