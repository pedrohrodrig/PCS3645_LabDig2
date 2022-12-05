library ieee;
use ieee.std_logic_1164.all;

entity feefeeder_fd is
    port (
        clock                       : in  std_logic;
        reset                       : in  std_logic;
        echo_comedouro              : in  std_logic;
        echo_reservatorio           : in  std_logic;
        zera_temp_medida            : in  std_logic;
        zera_temp_servomotor        : in  std_logic;
        zera_temp_aberto            : in  std_logic;
        zera_timeout                : in  std_logic;
        conta_temp_medida           : in  std_logic;
        conta_temp_servomotor       : in  std_logic;
        conta_temp_aberto           : in  std_logic;
        conta_timeout               : in  std_logic;
        enable_trena                : in  std_logic;
		enable_reg_servomotor       : in  std_logic;
        posicao_servomotor          : in  std_logic_vector(1 downto 0);
        trigger_comedouro           : out std_logic;
        trigger_reservatorio        : out std_logic;
        saida_serial_comedouro      : out std_logic;
        medida_reservatorio         : out std_logic_vector(6 downto 0);
        fim_temp_medida             : out std_logic;
        fim_temp_servomotor         : out std_logic;
        fim_temp_aberto             : out std_logic;
        fim_timeout                 : out std_logic;
        pronto_trena_comedouro      : out std_logic;
        pouca_comida_comedouro      : out std_logic;
        comida_suficiente_comedouro : out std_logic;
		pouca_comida_reservatorio   : out std_logic;
        pwm                         : out std_logic;
        db_estado_trena             : out std_logic_vector(6 downto 0);
        db_estado_medida            : out std_logic_vector(6 downto 0);
        db_estado_transmissor       : out std_logic_vector(6 downto 0);
        db_posicao_servomotor       : out std_logic_vector(1 downto 0)
    );
end entity;

architecture behavioral of feefeeder_fd is

    component trena_digital is
        port (
            clock 			      : in  std_logic;
            reset 		          : in  std_logic;
            mensurar 		      : in  std_logic;
            echo 			      : in  std_logic;
            trigger 		      : out std_logic;
            saida_serial  	      : out std_logic;
            pronto 			      : out std_logic;
			medida_dois           : in  std_logic_vector(11 downto 0);
            medida                : out std_logic_vector (11 downto 0);
            db_estado 		      : out std_logic_vector (6 downto 0);
            db_estado_medida      : out std_logic_vector (6 downto 0);
			db_cont               : out std_logic_vector(10 downto 0);
            db_estado_transmissor : out std_logic_vector (6 downto 0)
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

    component controle_servo is
        port (
            clock      : in  std_logic;
            reset      : in  std_logic;
            posicao    : in  std_logic_vector(1 downto 0);  
            pwm        : out std_logic;
            db_reset   : out std_logic;
            db_pwm     : out std_logic;
            db_posicao : out std_logic_vector(1 downto 0)
        );
    end component;

    component verifica_nivel is
       generic (
			  medida_pouca_comida      : std_logic_vector(11 downto 0) := "000000010101";
			  medida_comida_suficiente : std_logic_vector(11 downto 0) := "000000010010"
		 );
		 port (
			  clock, reset      : in std_logic;
			  enable_reg        : in std_logic;
			  medida            : in std_logic_vector(11 downto 0);
			  comida_suficiente : out std_logic;
			  pouca_comida      : out std_logic
		 );
    end component;

    component registrador_n is
        generic (
           constant N: integer := 8 
        );
        port (
           clock  : in  std_logic;
           clear  : in  std_logic;
           enable : in  std_logic;
           D      : in  std_logic_vector (N-1 downto 0);
           Q      : out std_logic_vector (N-1 downto 0) 
        );
    end component;

    signal s_medida_comedouro          : std_logic_vector(11 downto 0);
    signal s_medida_reservatorio       : std_logic_vector(11 downto 0);
    signal s_posicao_servomotor        : std_logic_vector(1 downto 0);
	signal count                       : std_logic_vector(10 downto 0);
	signal s_pronto_trena_reservatorio : std_logic;
	signal s_pronto_trena_comedouro    : std_logic;

begin
    
    TRENA_COMEDOURO: trena_digital
    port map (
        clock 			      => clock,
        reset 		          => reset,
        mensurar 		      => enable_trena,
        echo 			      => echo_comedouro,
        trigger 		      => trigger_comedouro,
        saida_serial  	      => open,--saida_serial_comedouro,
        pronto 			      => s_pronto_trena_comedouro,
        medida                => s_medida_comedouro,
		medida_dois           => x"000",--s_medida_reservatorio,
        db_estado 		      => db_estado_trena,
        db_estado_medida      => db_estado_medida,
		db_cont               => open,
        db_estado_transmissor => db_estado_transmissor
    );

    TRENA_RESERVATORIO: trena_digital
    port map (
        clock 			      => clock,
        reset 		          => reset,
        mensurar 		      => enable_trena,
        echo 			      => echo_reservatorio,
        trigger 		      => trigger_reservatorio,
        saida_serial  	      => saida_serial_comedouro,--open,
        pronto 			      => s_pronto_trena_reservatorio,
        medida                => s_medida_reservatorio,
		medida_dois           => s_medida_comedouro,--x"000",
        db_estado 		      => open,
        db_estado_medida      => open,
		db_cont               => count,
        db_estado_transmissor => open
    );

    TEMP_MEDIDA_NORMAL: contador_m
    generic map (
        M => 250000000, -- TODO: definir tempo entre medicoes
        N => 28
    )
    port map (
        clock => clock,
        zera  => zera_temp_medida,
        conta => conta_temp_medida,
        Q     => open,
        fim   => fim_temp_medida,
        meio  => open
    );

    TEMP_MEDIDA_ABERTO: contador_m
    generic map (
        M => 50000000, -- TODO: definir tempo entre medicoes quando está aberto
        N => 26
    )
    port map (
        clock => clock,
        zera  => zera_temp_aberto,
        conta => conta_temp_aberto,
        Q     => open,
        fim   => fim_temp_aberto,
        meio  => open
    );

    TEMP_TIMEOUT: contador_m
    generic map (
        M => 275000000,
        N => 29
    )
    port map (
        clock => clock,
        zera  => zera_timeout,
        conta => conta_timeout,
        Q     => open,
        fim   => fim_timeout,
        meio  => open
    );

    TEMP_SERVOMOTOR: contador_m
    generic map (
        M => 25000000, -- TODO: definir tempo maximo que servomotor ficará aberto
        N => 25 
    )
    port map (
        clock => clock,
        zera  => zera_temp_servomotor,
        conta => conta_temp_servomotor,
        Q     => open,
        fim   => fim_temp_servomotor,
        meio  => open
    );

    REG_SERVO: registrador_n
    generic map (N => 2)
    port map (
        clock  => clock,
        clear  => reset,
        enable => enable_reg_servomotor,
        D      => posicao_servomotor,
        Q      => s_posicao_servomotor
    );

    SERVO: controle_servo
    port map (
        clock      => clock,
        reset      => reset,
        posicao    => s_posicao_servomotor,
        pwm        => pwm,
        db_reset   => open,
        db_pwm     => open,
        db_posicao => db_posicao_servomotor
    );

    VN_COMEDOURO : verifica_nivel
    port map (
		  clock             => clock,
		  reset             => reset,
		  enable_reg        => s_pronto_trena_comedouro,
        medida            => s_medida_comedouro,
        pouca_comida      => pouca_comida_comedouro,
        comida_suficiente => comida_suficiente_comedouro
    );
	 
	 VN_RESERVATORIO : verifica_nivel
	 generic map (
		  medida_pouca_comida => "000000100100"
	 )
    port map (
		  clock             => clock,
		  reset             => reset,
		  enable_reg        => s_pronto_trena_reservatorio,
        medida            => s_medida_reservatorio,
        pouca_comida      => pouca_comida_reservatorio,
        comida_suficiente => open
    );

    medida_reservatorio <= count(6 downto 0);
	pronto_trena_comedouro <= s_pronto_trena_comedouro;
    
end architecture behavioral;