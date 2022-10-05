library IEEE;
use IEEE.std_logic_1164.all;

entity exp5_trena_desafio is
 port (
	 clock 				: in std_logic;
	 reset 				: in std_logic;
	 mensurar 			: in std_logic;
	 echo 				: in std_logic;
	 modo             : in std_logic;
	 trigger 			: out std_logic;
	 saida_serial  	: out std_logic;
	 medida0 			: out std_logic_vector (6 downto 0);
	 medida1 			: out std_logic_vector (6 downto 0);
	 medida2 			: out std_logic_vector (6 downto 0);
	 pronto 				: out std_logic;
	 db_estado 			: out std_logic_vector (6 downto 0);
	 db_estado_medida : out std_logic_vector (6 downto 0);
	 db_acionado      : out std_logic
 );
end entity exp5_trena_desafio;

architecture exp5_trena_arch of exp5_trena_desafio is

	component exp5_trena_uc is
	port (
		  clock      		: in  std_logic;
		  mensurar   		: in  std_logic;
		  fim_medida 		: in  std_logic;
		  fim_transmissao : in  std_logic;
		  fim_contagem		: in  std_logic;
		  reset      		: in  std_logic;
        zera       		: out std_logic;
        pronto     		: out std_logic;
		  conta				: out std_logic;
	     transmite       : out std_logic;
        db_estado  		: out std_logic_vector(3 downto 0) 
	);
	end component;
	
	component exp5_trena_fd is
	port (
		clock					: in std_logic;
		reset					: in std_logic;
		mensurar				: in std_logic;
		transmitir     	: in std_logic;
		echo        		: in std_logic;
		zera					: in std_logic;
		conta 				: in std_logic;
		dado              : in std_logic_vector(6 downto 0);
		modo              : in std_logic;
		saida_serial		: out std_logic;
		mensurar_auto     : out std_logic;
		medida_total      : out std_logic_vector(11 downto 0);
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
        saida : out std_logic_vector(6 downto 0)
	 );
	 end component;

	signal s_fim_medida, s_fim_transmissao, s_zera, s_saida_serial, s_pronto, s_trigger, s_conta, s_fim_contagem: std_logic;
	signal s_medida0_hex, s_medida1_hex, s_medida2_hex: std_logic_vector(6 downto 0);
	signal s_medida_total : std_logic_vector(11 downto 0);
	signal s_db_estado, s_medida0, s_medida1, s_medida2: std_logic_vector(3 downto 0);
	signal s_ascii0, s_ascii1, s_ascii2, s_dado, final: std_logic_vector(6 downto 0);
	signal s_contagem: std_logic_vector(2 downto 0);
	signal s_transmite : std_logic;
	signal not_mensurar : std_logic;
	signal s_mensurar, mensurar_auto : std_logic;
begin 

	s_medida0 <= s_medida_total(3 downto 0);
	s_medida1 <= s_medida_total(7 downto 4);
	s_medida2 <= s_medida_total(11 downto 8);
	final 	 <= "0100011"; 
	
	not_mensurar <= not mensurar;
	
	s_mensurar <= mensurar_auto when modo='1' else not_mensurar;

	s_dado <= s_ascii2 when s_contagem = "000" else
				 s_ascii1 when s_contagem = "001" else
				 s_ascii0 when s_contagem = "010" else
				 final 	 when s_contagem = "011" else
				 "0000000";

	UC: exp5_trena_uc
	port map(
		  clock      		=> clock,
		  mensurar   		=> s_mensurar,
		  fim_medida 		=> s_fim_medida,
		  fim_transmissao => s_fim_transmissao,
		  fim_contagem    => s_fim_contagem,
		  reset      		=> reset,
        zera       		=> s_zera,
        pronto     		=> s_pronto,
		  conta 				=> s_conta,
		  transmite       => s_transmite,
        db_estado  		=> s_db_estado
	);

	FD: exp5_trena_fd
	port map(
		clock					=> clock,
		reset					=> reset,
		mensurar				=> s_mensurar,
		transmitir     	=> s_transmite,
		echo        		=> echo,
		zera					=> s_zera,
		conta 				=> s_conta,
		dado 					=> s_dado,
		modo              => modo,
		saida_serial		=> s_saida_serial,
		mensurar_auto     => mensurar_auto,
		medida_total      => s_medida_total,
		medida0 				=> s_medida0_hex,
		medida1 				=> s_medida1_hex,
		medida2	 			=> s_medida2_hex,
		fim_contagem      => s_fim_contagem,
		fim_medida  		=> s_fim_medida,
		fim_transmissao   => s_fim_transmissao,
		trigger     		=> s_trigger,
		db_estado_medida  => db_estado_medida,
		db_medir				=> open,
		db_echo           => open,
		db_trigger        => open,
		contador 			=> s_contagem
	);
	
	DB_STATE: hex7seg
	port map(
		hexa => s_db_estado,
		sseg => db_estado
	);
	
	DADO0: ascii
	port map(
		dado  => s_medida0,
		saida => s_ascii0
	);
	
	DADO1: ascii
	port map(
		dado  => s_medida1,
		saida => s_ascii1
	);
	DADO2: ascii
	port map(
		dado  => s_medida2,
		saida => s_ascii2
	);
	
	medida0 			<= s_medida0_hex;
	medida1 			<= s_medida1_hex;
	medida2 			<= s_medida2_hex;
	saida_serial 	<= s_saida_serial;
	trigger 			<= s_trigger;
	pronto 			<= s_pronto;
	db_acionado    <= modo;

end architecture exp5_trena_arch;