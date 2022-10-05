
library IEEE;
use IEEE.std_logic_1164.all;

entity rx_serial_7E2 is
	port (
		clock 			  : in  std_logic;
		reset 			  : in  std_logic;
		dado_serial 	  : in  std_logic;
		dado_recebido0    : out std_logic_vector(6 downto 0);
		dado_recebido1    : out std_logic_vector(6 downto 0);
		paridade_recebida : out std_logic;
		tem_dado 		  : out std_logic;
		paridade_ok 	  : out std_logic;
		pronto_rx 		  : out std_logic;
		db_estado 		  : out std_logic_vector(6 downto 0)
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
	 
	component hex7seg
	port (
        hexa : in  std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
	end component;
	 
	 
	signal s_dado_recebido: std_logic_vector (6 downto 0);
	signal s_conta_tick, s_enable, s_clear, s_conta, s_paridade, s_tem_dado: std_logic;
	signal s_reset, s_paridade_ok, s_tick, s_fim, s_zera, pronto, s_desloca: std_logic;
	signal s_saida, s_saida_hexa1, s_saida_hexa0: std_logic_vector (6 downto 0);
	signal s_db_estado: std_logic_vector(3 downto 0);
	signal s_dados_mais_sig: std_logic_vector(3 downto 0);
    signal s_en_paridade_ok: std_logic;


begin 

    s_reset   <= reset;
	s_dados_mais_sig <= '0' & s_saida(6 downto 4); 

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
            pronto         => pronto
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
			paridade_in    => s_paridade,
			dados_saida    => s_saida,
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
    
	 U4_HEX: hex7seg
		port map (
		    hexa => s_db_estado,
		    sseg => db_estado
		);
				 
	 U5_HEX1: hex7seg
		port map (
		    hexa => s_dados_mais_sig,
		    sseg => s_saida_hexa0
		);
	
	 U6_HEX2: hex7seg 
		port map (
		    hexa => s_saida(3 downto 0),
		    sseg => s_saida_hexa1
		);
	 
	 
    -- saida
    dado_recebido0 <= s_saida_hexa0;
	dado_recebido1 <= s_saida_hexa1;
	paridade_ok <= s_paridade_ok;
	paridade_recebida <= s_paridade;
	pronto_rx <= pronto;
	tem_dado <= s_tem_dado;
	 
end architecture;