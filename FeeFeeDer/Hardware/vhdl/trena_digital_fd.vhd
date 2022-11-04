library ieee;
use ieee.std_logic_1164.all;

entity trena_digital_fd is
    port(
		clock			      : in  std_logic;
		reset			      : in  std_logic;
		mensurar		      : in  std_logic;
		transmitir     	      : in  std_logic;
		echo        	      : in  std_logic;
		zera			      : in  std_logic;
		conta 			      : in  std_logic;
		saida_serial	      : out std_logic;
		fim_contagem	      : out std_logic;
		fim_medida  	      : out std_logic;
		fim_transmissao       : out std_logic;
		trigger     	      : out std_logic;
		db_estado_medida      : out std_logic_vector(3 downto 0);
		db_estado_transmissor : out std_logic_vector(3 downto 0);
		db_medir		      : out std_logic;
		db_echo               : out std_logic;
		db_trigger            : out std_logic;
    );
end entity trena_digital_fd;

architecture trena_digital_fd_behavioral of trena_digital_fd is

	component interface_hcsr04
		port (
			clock 	  : in  std_logic;
			reset 	  : in  std_logic;
			medir 	  : in  std_logic;
			echo 	  : in  std_logic;
			trigger   : out std_logic;
			medida 	  : out std_logic_vector (11 downto 0); -- 3 digitos BCD
			pronto 	  : out std_logic;
			db_reset  : out std_logic;
			db_medir  : out std_logic;
			db_estado : out std_logic_vector (3 downto 0) -- estado da UC
		);
	end component;
	
	component tx_serial_7E2 is
		port (
			clock           : in  std_logic;
			reset           : in  std_logic;
			partida         : in  std_logic;
			dados_ascii     : in  std_logic_vector (6 downto 0);
			saida_serial    : out std_logic;
			pronto          : out std_logic;
        	db_partida      : out std_logic;
        	db_saida_serial : out std_logic;
        	db_estado       : out std_logic_vector (3 downto 0)
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
			fim   : out std_logic;
			meio  : out std_logic

		);
    end component;

	component ascii
		port(	
			dado  : in  std_logic_vector(3 downto 0);
			saida : out std_logic_vector(7 downto 0)
		);
	end component;
	
	signal s_pronto_medida      : std_logic;	
	signal s_pronto_transmissao : std_logic;
	signal s_trigger            : std_logic;
	signal s_contagem           : std_logic_vector(2 downto 0);

	signal s_medida0       : std_logic_vector(3 downto 0);
	signal s_medida1       : std_logic_vector(3 downto 0);
	signal s_medida2       : std_logic_vector(3 downto 0);
	signal s_medida_total  : std_logic_vector(11 downto 0);
	signal s_ascii_medida0 : std_logic_vector(7 downto 0);
	signal s_ascii_medida1 : std_logic_vector(7 downto 0);
	signal s_ascii_medida2 : std_logic_vector(7 downto 0);

	constant final : std_logic_vector(7 downto 0) := "00100011";
	
begin

	sensor: interface_hcsr04
	port map (
		clock 	  => clock,
		reset 	  => reset,
		medir 	  => mensurar,
		echo 	  => echo,
		trigger   => s_trigger,
		medida 	  => s_medida_total,
		pronto 	  => s_pronto_medida,
		db_reset  => open,
		db_medir  => db_medir,
		db_estado => db_estado_medida
	);

	s_medida0 <= s_medida_total(3 downto 0);
	s_medida1 <= s_medida_total(7 downto 4);
	s_medida2 <= s_medida_total(11 downto 8);

	-- MUX para selecionar qual dos digitos de medida será transmitido
	s_dado <= s_ascii_medida2 when s_contagem = "00" else
		      s_ascii_medida1 when s_contagem = "01" else
		      s_ascii_medida0 when s_contagem = "10" else
		      final;
	
	transmissor: tx_serial_7E2
	port map(
		clock 			=> clock,
		reset 			=> reset,
		partida  		=> transmitir,
		dados_ascii 	=> s_dado,
		saida_serial 	=> saida_serial,
		pronto 			=> s_pronto_transmissao,
		db_partida      => open,
		db_saida_serial => open,
		db_estado       => db_estado_transmissor
	);
	
	contagem: contador_m
	generic map(
		M => 3,
		N => 2
	)
	port map(
		clock  => clock,
		zera   => zera, 
		conta  => conta,
		Q 	   => s_contagem,
		fim    => fim_contagem,
		meio   => open
	);

	DADO0: ascii
	port map(
		dado  => s_medida0,
		saida => s_ascii_medida0
	);
	
	DADO1: ascii
	port map(
		dado  => s_medida1,
		saida => s_ascii_medida1
	);

	DADO2: ascii
	port map(
		dado  => s_medida2,
		saida => s_ascii_medida2
	);
	
	contador 		<= s_contagem;
	fim_medida 		<= s_pronto_medida;
	fim_transmissao <= s_pronto_transmissao;
	trigger         <= s_trigger;
	db_trigger      <= s_trigger;
	db_echo         <= echo;

end trena_digital_fd_behavioral ;