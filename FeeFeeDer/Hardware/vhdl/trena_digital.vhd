library IEEE;
use IEEE.std_logic_1164.all;

entity trena_digital is
 port (
		clock 			      : in  std_logic;
		reset 		          : in  std_logic;
		mensurar 		      : in  std_logic;
		echo 			      : in  std_logic;
		trigger 		      : out std_logic;
		saida_serial  	      : out std_logic;
		pronto 			      : out std_logic;
		medida                : out std_logic_vector (11 downto 0);
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
			medida                : out std_logic_vector(11 downto 0);
			db_estado_medida      : out std_logic_vector(3 downto 0);
			db_estado_transmissor : out std_logic_vector(3 downto 0);
			db_medir		      : out std_logic;
			db_echo               : out std_logic;
			db_trigger            : out std_logic;
		);
	end component;
	
	component hex7seg
		port (
			hexa : in  std_logic_vector(3 downto 0);
			sseg : out std_logic_vector(6 downto 0)
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
	signal s_db_estado             : std_logic_vector(3 downto 0);
	signal s_dado                  : std_logic_vector(7 downto 0);
	signal s_contagem              : std_logic_vector(2 downto 0);
	signal s_transmite             : std_logic;
	signal fim_2seg                : std_logic;
	signal s_db_estado_medida      : std_logic_vector(3 downto 0);
	signal s_db_estado_transmissor : std_logic_vector(3 downto 0);

begin 

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
		saida_serial	      => s_saida_serial,
		fim_contagem          => s_fim_contagem,
		fim_medida            => s_fim_medida,
		fim_transmissao       => s_fim_transmissao,
		trigger               => s_trigger,
		medida                => medida,
		db_estado_medida      => s_db_estado_medida,
		db_estado_transmissor => s_db_estado_transmissor,
		db_medir		      => open,
		db_echo               => open,
		db_trigger            => open
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
	
	saida_serial <= s_saida_serial;
	trigger 	 <= s_trigger;
	pronto 		 <= s_pronto;

end architecture trena_digital_behavioral;