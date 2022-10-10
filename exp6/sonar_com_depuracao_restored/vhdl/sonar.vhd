library ieee;
use ieee.std_logic_1164.all;

entity sonar is
    port (
        clock        : in  std_logic;
        reset        : in  std_logic;
        ligar        : in  std_logic;
        echo         : in  std_logic;
        trigger      : out std_logic;
        pwm          : out std_logic;
        saida_serial : out std_logic;
        fim_posicao  : out std_logic;
        db_estado    : out std_logic_vector(6 downto 0);
		  db_trigger, db_echo : out std_logic;
		  db_ligar     : out std_logic
    );
end entity;

architecture sonar_behavioral of sonar is
    
    component sonar_fd 
        port (
           clock           : in  std_logic;
			  reset           : in  std_logic;
			  mensurar        : in  std_logic;
			  conta_2seg      : in  std_logic;
			  conta_updown    : in  std_logic;
			  zera            : in  std_logic;
			  zera_2seg       : in  std_logic;
			  echo            : in  std_logic;
			  conta_timeout	: in  std_logic;
			  zera_timeout		: in  std_logic;
			  trigger         : out std_logic;
			  pwm             : out std_logic;
			  saida_serial    : out std_logic;
			  fim_2seg        : out std_logic;
			  fim_transmissao : out std_logic;
			  timeout		   : out std_logic
        );
    end component;

    component sonar_uc is
        port (
           clock           : in  std_logic;
			  reset           : in  std_logic;
			  ligar           : in  std_logic;
			  fim_2seg        : in  std_logic;
			  fim_transmissao : in  std_logic;
			  timeout			: in  std_logic;
			  zera            : out std_logic;
			  zera_2seg       : out std_logic;
			  conta_2seg      : out std_logic;
			  conta_updown    : out std_logic;
			  mensurar        : out std_logic;
			  pronto          : out std_logic;
			  zera_timeout    : out std_logic;
			  conta_timeout   : out std_logic;
			  db_estado       : out std_logic_vector(3 downto 0)
        );
    end component;

    component hex7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

    signal s_mensurar        : std_logic;
    signal s_fim_2seg        : std_logic;
    signal s_conta_2seg      : std_logic;
    signal s_conta_updown    : std_logic;
    signal s_fim_transmissao : std_logic;
    signal s_zera, s_trigger            : std_logic;
    signal s_zera_2seg       : std_logic;
    signal s_db_estado       : std_logic_vector(3 downto 0);
	 signal s_timeout, s_conta_timeout, s_zera_timeout : std_logic;

begin
    
    FD: sonar_fd
    port map (
        clock           => clock,
        reset           => reset,
        mensurar        => s_mensurar,
        conta_2seg      => s_conta_2seg,
        conta_updown    => s_conta_updown,
        zera            => s_zera,
        zera_2seg       => s_zera_2seg,
        echo            => echo,
        trigger         => s_trigger,
        pwm             => pwm,
        saida_serial    => saida_serial,
        fim_2seg        => s_fim_2seg,
        fim_transmissao => s_fim_transmissao,
		  timeout 			=> s_timeout,
		  zera_timeout    => s_zera_timeout,
		  conta_timeout   => s_conta_timeout
    );

    UC: sonar_uc
    port map (
        clock           => clock,
        reset           => reset,
        ligar           => ligar,
        fim_2seg        => s_fim_2seg,
        fim_transmissao => s_fim_transmissao,
        zera            => s_zera,
        zera_2seg       => s_zera_2seg,
        conta_2seg      => s_conta_2seg,
        conta_updown    => s_conta_updown,
        mensurar        => s_mensurar,
        pronto          => fim_posicao,
        db_estado       => s_db_estado, 
		  timeout 			=> s_timeout,
		  zera_timeout    => s_zera_timeout,
		  conta_timeout   => s_conta_timeout
    );

    HEX5: hex7seg
    port map (
        hexa => s_db_estado,
        sseg => db_estado
    );
	 
	 db_ligar <= ligar;
	db_trigger <= s_trigger;
	db_echo <= echo;
	trigger <= s_trigger;
    
end architecture sonar_behavioral;