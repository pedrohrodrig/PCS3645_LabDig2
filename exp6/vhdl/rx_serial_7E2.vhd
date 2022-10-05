
library IEEE;
use IEEE.std_logic_1164.all;

entity rx_serial_7E2 is
	port (
		clock 			  : in  std_logic;
		reset 			  : in  std_logic;
		dado_serial 	  : in  std_logic;
        recebe_dado       : in  std_logic;
		dado_recebido     : out std_logic_vector(6 downto 0);
        tem_dado 		  : out std_logic;
        paridade_ok 	  : out std_logic;
        pronto  		  : out std_logic;
        db_dado_serial    : out std_logic;
		db_estado 		  : out std_logic_vector(3 downto 0)
	);
end entity;

architecture arch of rx_serial_7E2 is
	
	component rx_serial_uc
	port ( 
        clock  	       : in  std_logic;
        reset  	       : in  std_logic;
        start_bit      : in  std_logic;
        tick   	       : in  std_logic;
        fim            : in  std_logic;
        zera           : out std_logic;
        conta          : out std_logic;
        carrega        : out std_logic;
		enable         : out std_logic;
		clear          : out std_logic;
        desloca        : out std_logic;
		conta_tick     : out std_logic;
		db_estado      : out std_logic_vector(3 downto 0);
		tem_dado       : out std_logic;
        en_paridade_ok : out std_logic;
        pronto         : out std_logic
    );
    end component;
	 
	component rx_serial_fd
	port (
        clock          : in  std_logic;
        reset          : in  std_logic;
        zera           : in  std_logic;
        conta          : in  std_logic;
        carrega        : in  std_logic;
        desloca        : in  std_logic;
        dado_serial    : in  std_logic;
		clear          : in  std_logic;
		enable         : in  std_logic;
        en_paridade_ok : in  std_logic;
		paridade_ok    : out std_logic;
		paridade_in    : out std_logic;
		dados_saida    : out std_logic_vector (6 downto 0);
        fim            : out std_logic
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
	  
	signal s_dado_recebido  : std_logic_vector (6 downto 0);
	signal s_conta_tick     : std_logic;
    signal s_enable         : std_logic;
    signal s_clear          : std_logic;
    signal s_conta          : std_logic;
    signal s_tem_dado       : std_logic;
	signal s_reset          : std_logic;
    signal s_paridade_ok    : std_logic;
    signal s_tick           : std_logic;
    signal s_fim            : std_logic;
    signal s_zera           : std_logic;
    signal s_pronto         : std_logic;
    signal s_desloca        : std_logic;
	signal s_db_estado      : std_logic_vector(3 downto 0);
    signal s_en_paridade_ok : std_logic;

begin 

    s_reset   <= reset; 

    U1_UC: rx_serial_uc 
        port map (
            clock          => clock, 
            reset          => s_reset, 
            start_bit      => dado_serial, 
            tick           => s_tick, 
            fim            => s_fim,
            zera           => s_zera, 
            conta          => s_conta, 
            carrega        => open, 
			enable         => s_enable,
			clear          => s_clear,
            desloca        => s_desloca,
			conta_tick     => s_conta_tick,
			db_estado      => s_db_estado,
			tem_dado       => s_tem_dado,
            en_paridade_ok => s_en_paridade_ok,
            pronto         => s_pronto
        );

    U2_FD: rx_serial_fd 
        port map (
            clock          => clock, 
            reset          => s_reset, 
            zera           => s_zera, 
            conta          => s_conta, 
            carrega        => '0', 
            desloca        => s_desloca, 
            dado_serial    => dado_serial, 
            clear          => s_clear,
			enable         => s_enable,
			paridade_ok    => s_paridade_ok,
			paridade_in    => open,
			dados_saida    => s_dado_recebido,
            en_paridade_ok => s_en_paridade_ok,
            fim            => s_fim
        );

    -- gerador de tick
    -- fator de divisao para 9600 bauds (5208=50M/9600)
    -- fator de divisao para 115.200 bauds (434=50M/115200)
    U3_TICK: contador_m 
        generic map (
            M => 434, -- 9600 bauds
            N => 9
        ) 
        port map (
            clock => clock, 
            zera  => s_zera, 
            conta => s_conta_tick, 
            Q     => open,
			fim   => open, 
            meio  => s_tick
        );
	 
    -- saida
    dado_recebido  <= s_dado_recebido;
	paridade_ok    <= s_paridade_ok;
	pronto         <= s_pronto;
	tem_dado       <= s_tem_dado;
    db_estado      <= s_db_estado;
	 
end architecture;