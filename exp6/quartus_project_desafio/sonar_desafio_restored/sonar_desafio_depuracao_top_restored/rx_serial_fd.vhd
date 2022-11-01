library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_serial_fd is
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
end entity;

architecture rx_serial_fd_arch of rx_serial_fd is
     
    component deslocador_n
    generic (
        constant N : integer
    );
    port (
        clock          : in  std_logic;
        reset          : in  std_logic;
        carrega        : in  std_logic; 
        desloca        : in  std_logic; 
        entrada_serial : in  std_logic; 
        dados          : in  std_logic_vector (N-1 downto 0);
        saida          : out std_logic_vector (N-1 downto 0)
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
        fim   : out std_logic
    );
    end component;
	 
	component testador_paridade
	port (
        dado     : in  std_logic_vector (6 downto 0);
        paridade : in  std_logic;
        par_ok   : out std_logic;
        impar_ok : out std_logic
    );
	end component;
	 
	component registrador_n
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
    
    signal s_dados: std_logic_vector (11 downto 0);
	signal s_paridade_ok, s_paridade: std_logic;
	signal s_saida: std_logic_vector (6 downto 0);

begin

	 s_paridade <= s_dados(8);

    U1: deslocador_n 
        generic map (
            N => 12
        )  
        port map (
            clock          => clock, 
            reset          => reset, 
            carrega        => carrega, 
            desloca        => desloca, 
            entrada_serial => dado_serial, 
            dados          => "111111111111", 
            saida          => s_dados
        );

    U2: contador_m 
        generic map (
            M => 13, 
            N => 4
        ) 
        port map (
            clock => clock, 
            zera  => zera, 
            conta => conta, 
            Q     => open, 
            fim   => fim
        );
		  
	  U3: testador_paridade 
        port map (
            dado     => s_dados(7 downto 1),
			paridade => s_paridade,
			par_ok   => s_paridade_ok,
			impar_ok => open
        );
	
	  U4: registrador_n
		generic map (
			N => 7
		)
		port map (
			clock => clock,
			clear => clear,
			enable => enable,
			D => s_dados(7 downto 1),
			Q => s_saida
		);

	paridade_ok <= s_paridade_ok and en_paridade_ok;
	paridade_in <= s_paridade;
    dados_saida <= s_saida;
    
end architecture;