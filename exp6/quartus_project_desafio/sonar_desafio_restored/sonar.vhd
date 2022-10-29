library ieee;
use ieee.std_logic_1164.all;

entity sonar is
    port (
        clock                 : in  std_logic;
        reset                 : in  std_logic;
        ligar                 : in  std_logic;
        echo                  : in  std_logic;
		entrada_serial        : in  std_logic;
        trigger               : out std_logic;
        pwm                   : out std_logic;
        saida_serial          : out std_logic;
        fim_posicao           : out std_logic;
        db_estado             : out std_logic_vector(6 downto 0);
		db_trigger            : out std_logic;
        db_echo               : out std_logic;
        db_pause              : out std_logic;
		db_ligar              : out std_logic;
		db_estado_trena       : out std_logic_vector (6 downto 0);
		db_estado_medida      : out std_logic_vector (6 downto 0);
        db_estado_transmissor : out std_logic_vector (6 downto 0);
        db_estado_receptor    : out std_logic_vector (6 downto 0);
        db_posicao_servomotor : out std_logic_vector (6 downto 0)
    );
end entity;

architecture sonar_behavioral of sonar is
    
    component sonar_fd 
        port (
            clock            : in  std_logic;
			reset            : in  std_logic;
			mensurar         : in  std_logic;
			conta_2seg       : in  std_logic;
			conta_updown     : in  std_logic;
			zera             : in  std_logic;
			zera_2seg        : in  std_logic;
			echo             : in  std_logic;
			entrada_serial   : in  std_logic;
			conta_timeout	 : in  std_logic;
			zera_timeout	 : in  std_logic;
			pause			 : out std_logic;
			reinicio 		 : out std_logic;
			trigger          : out std_logic;
			pwm              : out std_logic;
			saida_serial     : out std_logic;
			fim_2seg         : out std_logic;
			fim_transmissao  : out std_logic;
			timeout		     : out std_logic;
			db_estado_trena  : out std_logic_vector(6 downto 0);
			db_estado_medida : out std_logic_vector (6 downto 0);
            db_estado_transmissor : out std_logic_vector (6 downto 0);
            db_estado_receptor    : out std_logic_vector (6 downto 0);
            db_posicao_servomotor : out std_logic_vector (6 downto 0)
        );
    end component;

    component sonar_uc is
        port (
            clock           : in  std_logic;
			reset           : in  std_logic;
			ligar           : in  std_logic;
			fim_2seg        : in  std_logic;
			fim_transmissao : in  std_logic;
			pause 		    : in  std_logic;
			reinicio	    : in  std_logic;
			timeout		    : in  std_logic;
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
    signal s_zera            : std_logic; 
    signal s_trigger         : std_logic;
    signal s_zera_2seg       : std_logic;
    signal s_db_estado       : std_logic_vector(3 downto 0);
	signal s_timeout         : std_logic;
    signal s_conta_timeout   : std_logic;
    signal s_zera_timeout    : std_logic;
	signal s_pause           : std_logic;
    signal s_reinicio        : std_logic;
    signal s_reset_via_ligar : std_logic;

begin

    s_reset_via_ligar <= reset or not ligar;
    
    FD: sonar_fd
    port map (
        clock                 => clock,
        reset                 => s_reset_via_ligar,
		entrada_serial        => entrada_serial,
		timeout               => s_timeout,
		conta_timeout         => s_conta_timeout,
		zera_timeout          => s_zera_timeout,
        mensurar              => s_mensurar,
        conta_2seg            => s_conta_2seg,
        conta_updown          => s_conta_updown,
        zera                  => s_zera,
        zera_2seg             => s_zera_2seg,
        echo                  => echo,
        trigger               => s_trigger,
        pwm                   => pwm,
        saida_serial          => saida_serial,
        fim_2seg              => s_fim_2seg,
		pause                 => s_pause,
		reinicio              => s_reinicio,
        fim_transmissao       => s_fim_transmissao,
		db_estado_trena       => db_estado_trena,
		db_estado_medida      => db_estado_medida,
        db_estado_transmissor => db_estado_transmissor,
        db_estado_receptor    => db_estado_receptor,
        db_posicao_servomotor => db_posicao_servomotor
    );

    UC: sonar_uc
    port map (
        clock           => clock,
        reset           => reset,
		pause           => s_pause,
		reinicio        => s_reinicio,
        ligar           => ligar,
        fim_2seg        => s_fim_2seg,
		timeout         => s_timeout,
		conta_timeout   => s_conta_timeout,
		zera_timeout    => s_zera_timeout,
        fim_transmissao => s_fim_transmissao,
        zera            => s_zera,
        zera_2seg       => s_zera_2seg,
        conta_2seg      => s_conta_2seg,
        conta_updown    => s_conta_updown,
        mensurar        => s_mensurar,
        pronto          => fim_posicao,
        db_estado       => s_db_estado
    );

    HEX5: hex7seg
    port map (
        hexa => s_db_estado,
        sseg => db_estado
    );
    
	db_ligar   <= ligar;
	db_trigger <= s_trigger;
	db_echo    <= echo;
	trigger    <= s_trigger;
	db_pause   <= s_pause;
	 
end architecture sonar_behavioral;