library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sonar_fd is
    port (
        clock                 : in  std_logic;
        reset                 : in  std_logic;
        mensurar              : in  std_logic;
        conta_2seg            : in  std_logic;
        conta_updown          : in  std_logic;
        zera                  : in  std_logic;
        zera_2seg             : in  std_logic;
        echo                  : in  std_logic;
		entrada_serial        : in  std_logic;
		conta_timeout	      : in  std_logic;
		zera_timeout	      : in  std_logic;
		pause			      : out std_logic;
		reinicio 		      : out std_logic;
        trigger               : out std_logic;
        pwm                   : out std_logic;
        saida_serial          : out std_logic;
        fim_2seg              : out std_logic;
        fim_transmissao       : out std_logic;
		timeout		          : out std_logic;
		db_estado_trena       : out std_logic_vector (6 downto 0);
		db_estado_medida      : out std_logic_vector (6 downto 0);
        db_estado_transmissor : out std_logic_vector (6 downto 0);
        db_estado_receptor    : out std_logic_vector (6 downto 0);
        db_posicao_servomotor : out std_logic_vector (6 downto 0)
    );
end entity;

architecture sonar_fd_behavioral of sonar_fd is
    
    component trena_digital is
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
    end component;

    component rom_angulos_8x24 
        port (
            endereco : in  std_logic_vector(2 downto 0);
            saida    : out std_logic_vector(23 downto 0)
        ); 
    end component;

    component controle_servo is
        port (
            clock      : in  std_logic;
            reset      : in  std_logic;
            posicao    : in  std_logic_vector(2 downto 0);  
            pwm        : out std_logic;
            db_reset   : out std_logic;
            db_pwm     : out std_logic;
            db_posicao : out std_logic_vector(2 downto 0)
        );
    end component;

    component contadorg_updown_m is
        generic (
            constant M: integer := 50 -- modulo do contador
        );
        port (
            clock   : in  std_logic;
            zera_as : in  std_logic;
            zera_s  : in  std_logic;
            conta   : in  std_logic;
            Q       : out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
            inicio  : out std_logic;
            fim     : out std_logic;
            meio    : out std_logic 
       );
    end component;
	 
	component contador_m is
		generic (
			constant M : integer := 50;  
			constant N : integer := 6 
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

    component rx_serial_7E2 is
        port (
            clock 			: in  std_logic;
            reset 			: in  std_logic;
            dado_serial 	: in  std_logic;
            recebe_dado     : in  std_logic;
            dado_recebido   : out std_logic_vector(6 downto 0);
            tem_dado 		: out std_logic;
            paridade_ok 	: out std_logic;
            pronto  		: out std_logic;
            db_dado_serial  : out std_logic;
            db_estado 		: out std_logic_vector(3 downto 0)
        );
    end component;

    component identificador_caractere is
        port (
            caractere_recebido : in  std_logic_vector(6 downto 0);
			reset			   : in  std_logic;
			clock			   : in  std_logic;
			pronto			   : in  std_logic;
			pause			   : out std_logic;
			reinicio		   : out std_logic
        );
    end component;

    component hex7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

    signal s_angulo                   : std_logic_vector (23 downto 0);
	signal s_contagem_endereco        : std_logic_vector (2 downto 0);
    signal s_dado_recebido            : std_logic_vector (6 downto 0);
    signal s_pronto                   : std_logic; 
    signal s_pause                    : std_logic;
    signal s_reinicio                 : std_logic;
	signal s_zera_trena               : std_logic; 
    signal s_timeout                  : std_logic;
    signal s_db_estado_receptor       : std_logic_vector (3 downto 0);
    signal s_db_posicao_servomotor    : std_logic_vector (2 downto 0);
    signal s_ex_db_posicao_servomotor : std_logic_vector (3 downto 0);

begin

    ID: identificador_caractere
    port map (
        caractere_recebido => s_dado_recebido,
        reset              => reset,
		clock              => clock,
		pronto             => s_pronto,
		pause              => s_pause,
		reinicio           => s_reinicio
    );

    RX: rx_serial_7E2
    port map (
        clock          => clock,
        reset          => reset,
        dado_serial    => entrada_serial, 
        recebe_dado    => '0',
        dado_recebido  => s_dado_recebido,
        tem_dado       => open,
        paridade_ok    => open,
        pronto         => s_pronto,
        db_dado_serial => open,
        db_estado      => s_db_estado_receptor
    );
    
    TRENA: trena_digital
    port map (
        clock 	              => clock,
        reset 		          => reset,
        mensurar 	          => mensurar,
        echo 		          => echo,
        angulo                => s_angulo,
        trigger 	          => trigger,
        saida_serial          => saida_serial,
        pronto 		          => fim_transmissao,
        db_estado 	          => db_estado_trena,
		db_estado_medida      => db_estado_medida,
        db_estado_transmissor => db_estado_transmissor
    );

    ROM_ANG: rom_angulos_8x24
    port map (
        endereco => s_contagem_endereco,
        saida    => s_angulo
    );

    SERVO: controle_servo
    port map (
        clock      => clock,
        reset      => zera,
        posicao    => s_contagem_endereco,
        pwm        => pwm,
        db_reset   => open,
        db_pwm     => open,
        db_posicao => s_db_posicao_servomotor
    );

    CONTADOR_UPDOWN: contadorg_updown_m
    generic map (
        M => 8
    )
    port map (
        clock   => clock,
        zera_as => zera,
        zera_s  => '0',
        conta   => conta_updown,
        Q       => s_contagem_endereco,
        inicio  => open,
        fim     => open,
        meio    => open
    );

    CONT_SEGUNDOS: contador_m
	generic map(
		M => 100000000, -- 2 segundos
		N => 27
	)
	port map(
		clock => clock,
		zera  => zera_2seg,
		conta => conta_2seg,
		Q     => open,
		fim   => fim_2seg,
		meio  => open
	);
	
	CONT_TIMEOUT: contador_m
	generic map(
		M => 50000000, -- 1 segundo
		N => 26
	)
	port map(
		clock => clock,
		zera  => zera_timeout,
		conta => conta_timeout,
		Q     => open,
		fim   => s_timeout,
		meio  => open
	);

    HEX_RECEPTOR: hex7seg
    port map (
        hexa => s_db_estado_receptor,
        sseg => db_estado_receptor
    );

    s_ex_db_posicao_servomotor <= '0' & s_db_posicao_servomotor;

    HEX_SERVOMOTOR : hex7seg
    port map (
        hexa => s_ex_db_posicao_servomotor,
        sseg => db_posicao_servomotor
    );
	
	pause    <= s_pause; 
	reinicio <= s_reinicio;
	timeout  <= s_timeout;
	
end architecture sonar_fd_behavioral;