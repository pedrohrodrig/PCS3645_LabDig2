library IEEE;
use IEEE.std_logic_1164.all;

entity trena_digital is
 port (
		clock 			      : in  std_logic;
		reset 		          : in  std_logic;
		mensurar 		      : in  std_logic;
		echo 			      : in  std_logic;
		angulo                : in  std_logic_vector(23 downto 0);
		trigger 		      : out std_logic;
		saida_serial  	      : out std_logic;
		pronto 			      : out std_logic;
		db_estado 		      : out std_logic_vector (6 downto 0);
		db_estado_medida      : out std_logic_vector (6 downto 0);
		db_estado_transmissor : out std_logic_vector (6 downto 0)
 );
end entity trena_digital;

architecture trena_digital_behavioral of trena_digital is

	component trena_digital_uc is
		port (
			clock      		: in  std_logic;
			mensurar   	    : in  std_logic;
			fim_medida 	    : in  std_logic;
			fim_transmissao : in  std_logic;
			fim_contagem    : in  std_logic;
			reset      	    : in  std_logic;
			zera       		: out std_logic;
			pronto     		: out std_logic;
			conta			: out std_logic;
			transmite       : out std_logic;
			db_estado  		: out std_logic_vector(3 downto 0)  
		);
	end component;
	
	component trena_digital_fd is
		port (
			clock			      : in  std_logic;
			reset			      : in  std_logic;
			mensurar		      : in  std_logic;
			transmitir     	      : in  std_logic;
			echo        	      : in  std_logic;
			zera			      : in  std_logic;
			conta 			      : in  std_logic;
			dado			      : in  std_logic_vector(6 downto 0);
			saida_serial	      : out std_logic;
			medida_total          : out std_logic_vector(11 downto 0);
			fim_contagem	      : out std_logic;
			fim_medida  	      : out std_logic;
			fim_transmissao       : out std_logic;
			trigger     	      : out std_logic;
			db_estado_medida      : out std_logic_vector(3 downto 0);
			db_estado_transmissor : out std_logic_vector(3 downto 0);
			db_medir		      : out std_logic;
			db_echo               : out std_logic;
			db_trigger            : out std_logic;
			contador		      : out std_logic_vector(2 downto 0)
		);
	end component;
	
	component hex7seg
		port (
			hexa : in  std_logic_vector(3 downto 0);
			sseg : out std_logic_vector(6 downto 0)
		);
	end component;
	 
	component ascii
		port(	
			dado  : in  std_logic_vector(3 downto 0);
			saida : out std_logic_vector(7 downto 0)
		);
	end component;

	component mux_8x1_n is
		generic (
			constant BITS: integer := 4
		);
		port ( 
			D0 :     in  std_logic_vector (BITS-1 downto 0);
			D1 :     in  std_logic_vector (BITS-1 downto 0);
			D2 :     in  std_logic_vector (BITS-1 downto 0);
			D3 :     in  std_logic_vector (BITS-1 downto 0);
			D4 :     in  std_logic_vector (BITS-1 downto 0);
			D5 :     in  std_logic_vector (BITS-1 downto 0);
			D6 :     in  std_logic_vector (BITS-1 downto 0);
			D7 :     in  std_logic_vector (BITS-1 downto 0);
			SEL:     in  std_logic_vector (2 downto 0);
			MUX_OUT: out std_logic_vector (BITS-1 downto 0)
		);
	end component;

	signal s_fim_medida            : std_logic;
	signal s_fim_transmissao       : std_logic;
	signal s_zera                  : std_logic;
	signal s_saida_serial          : std_logic;
	signal s_pronto                : std_logic;
	signal s_trigger               : std_logic;
	signal s_conta                 : std_logic;
	signal s_fim_contagem          : std_logic;
	signal s_medida_total          : std_logic_vector(11 downto 0);
	signal s_db_estado             : std_logic_vector(3 downto 0);
	signal s_medida0               : std_logic_vector(3 downto 0);
	signal s_medida1               : std_logic_vector(3 downto 0);
	signal s_medida2               : std_logic_vector(3 downto 0);
	signal s_ascii_medida0         : std_logic_vector(7 downto 0);
	signal s_ascii_medida1         : std_logic_vector(7 downto 0);
	signal s_ascii_medida2         : std_logic_vector(7 downto 0);
	signal s_ascii_angulo0         : std_logic_vector(7 downto 0);
	signal s_ascii_angulo1         : std_logic_vector(7 downto 0);
	signal s_ascii_angulo2         : std_logic_vector(7 downto 0);
	signal s_dado                  : std_logic_vector(7 downto 0);
	signal s_contagem              : std_logic_vector(2 downto 0);
	signal s_transmite             : std_logic;
	signal fim_2seg                : std_logic;
	signal s_db_estado_medida      : std_logic_vector(3 downto 0);
	signal s_db_estado_transmissor : std_logic_vector(3 downto 0);

	constant final   : std_logic_vector(7 downto 0) := "00100011";
	constant virgula : std_logic_vector(7 downto 0) := "00101100";

begin 

	-- Parseamento do vetor do angulo ja em ASCII
	s_ascii_angulo0 <= angulo(7 downto 0);
	s_ascii_angulo1 <= angulo(15 downto 8);
	s_ascii_angulo2 <= angulo(23 downto 16);

	-- Parseamento do vetor de medida ainda em binario
	s_medida0 <= s_medida_total(3 downto 0);
	s_medida1 <= s_medida_total(7 downto 4);
	s_medida2 <= s_medida_total(11 downto 8);
	
	MUX: mux_8x1_n
	generic map (
		BITS => 8
	)
	port map (
		D0      => s_ascii_angulo2,
		D1      => s_ascii_angulo1,
		D2      => s_ascii_angulo0,
		D3      => virgula,
		D4      => s_ascii_medida2,
		D5      => s_ascii_medida1,
		D6      => s_ascii_medida0,
		D7      => final,
		SEL     => s_contagem,
		MUX_OUT => s_dado
	);

	UC: trena_digital_uc
	port map(
		clock           => clock,
		mensurar   	    => mensurar,
		fim_medida 	    => s_fim_medida,
		fim_transmissao => s_fim_transmissao,
		fim_contagem    => s_fim_contagem,
		reset      	    => reset,
        zera       		=> s_zera,
        pronto          => s_pronto,
		conta 		    => s_conta,
		transmite       => s_transmite,
        db_estado  		=> s_db_estado
	);

	FD: trena_digital_fd
	port map(
		clock			      => clock,
		reset			      => reset,
		mensurar		      => mensurar,
		transmitir     	      => s_transmite,
		echo        	      => echo,
		zera			      => s_zera,
		conta 			      => s_conta,
		dado 			      => s_dado(6 downto 0),
		saida_serial	      => s_saida_serial,
		medida_total          => s_medida_total,
		fim_contagem          => s_fim_contagem,
		fim_medida            => s_fim_medida,
		fim_transmissao       => s_fim_transmissao,
		trigger               => s_trigger,
		db_estado_medida      => s_db_estado_medida,
		db_estado_transmissor => s_db_estado_transmissor,
		db_medir		      => open,
		db_echo               => open,
		db_trigger            => open,
		contador 		      => s_contagem
	);

	DB_STATE: hex7seg
	port map(
		hexa => s_db_estado,
		sseg => db_estado
	);
	
	DB_STATE_2: hex7seg
	port map(
		hexa => s_db_estado_medida,
		sseg => db_estado_medida
	);

	DB_STATE_3: hex7seg
	port map (
		hexa => s_db_estado_transmissor,
		sseg => db_estado_transmissor
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
	
	saida_serial <= s_saida_serial;
	trigger 	 <= s_trigger;
	pronto 		 <= s_pronto;

end architecture trena_digital_behavioral;