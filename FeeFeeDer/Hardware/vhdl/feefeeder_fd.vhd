library ieee;
use ieee.std_logic_1164.all;

entity feefeeder_fd is
    port (
        clock                 : in  std_logic;
        reset                 : in  std_logic;
        echo                  : in  std_logic;
        zera_temp_medida      : in  std_logic;
        zera_temp_servomotor  : in  std_logic;
        conta_temp_medida     : in  std_logic;
        conta_temp_servomotor : in  std_logic;
        enable_trena          : in  std_logic;
        posicao_servomotor    : in  std_logic_vector(1 downto 0);
        trigger               : out std_logic;
        saida_serial          : out std_logic;
        fim_temp_medida       : out std_logic;
        fim_temp_servomotor   : out std_logic;
        pronto_trena          : out std_logic;
        pouca_comida          : out std_logic;
        comida_suficiente     : out std_logic;
        pwm                   : out std_logic;
        db_estado_trena       : out std_logic_vector(6 downto 0);
        db_estado_medida      : out std_logic_vector(6 downto 0);
        db_estado_transmissor : out std_logic_vector(6 downto 0);
        db_posicao_servomotor : out std_logic_vector(1 downto 0)
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
            medida                : out std_logic_vector (11 downto 0);
            db_estado 		      : out std_logic_vector (6 downto 0);
            db_estado_medida      : out std_logic_vector (6 downto 0);
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
        port (
            medida            : in std_logic_vector(11 downto 0);
            comida_suficiente : out std_logic;
            pouca_comida      : out std_logic;
        );
    end component;

    signal s_medida : std_logic_vector(11 downto 0);

begin
    
    TRENA: trena_digital
    port map (
        clock 			      => clock,
        reset 		          => reset,
        mensurar 		      => enable_trena,
        echo 			      => echo,
        trigger 		      => trigger,
        saida_serial  	      => saida_serial,
        pronto 			      => pronto_trena,
        medida                => s_medida,
        db_estado 		      => db_estado_trena,
        db_estado_medida      => db_estado_medida,
        db_estado_transmissor => db_estado_transmissor,
    );

    TEMP_MEDIDA: contador_m
    generic map (
        M => 2, -- TODO: definir tempo entre medicoes
        N => 1
    )
    port map (
        clock => clock,
        zera  => zera_temp_medida,
        conta => conta_temp_medida,
        Q     => open,
        fim   => fim_temp_medida,
        meio  => open
    );

    TEMP_SERVOMOTOR: contador_m
    generic map (
        M => 2, -- TODO: definir tempo maximo que servomotor ficará aberto
        N => 1
    )
    port map (
        clock => clock,
        zera  => zera_temp_servomotor,
        conta => conta_temp_servomotor,
        Q     => open,
        fim   => fim_temp_servomotor,
        meio  => open
    );

    SERVO: controle_servo
    port map (
        clock      => clock,
        reset      => reset,
        posicao    => posicao_servomotor,
        pwm        => pwm,
        db_reset   => open,
        db_pwm     => open,
        db_posicao => db_posicao_servomotor,
    );

    VERIFICA_NIVEL : verifica_nivel
    port map (
        medida            => s_medida,
        pouca_comida      => pouca_comida,
        comida_suficiente => comida_suficiente
    );
    
end architecture behavioral;