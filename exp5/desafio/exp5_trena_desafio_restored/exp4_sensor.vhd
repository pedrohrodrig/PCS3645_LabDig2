library ieee;
use ieee.std_logic_1164.all;

entity exp4_sensor is
    port (
        clock      : in std_logic;
        reset      : in std_logic;
        medir      : in std_logic;
        echo       : in std_logic;
        trigger    : out std_logic;
        medida     : out std_logic_vector(11 downto 0);
        hex0       : out std_logic_vector(6 downto 0); -- digitos da medida
        hex1       : out std_logic_vector(6 downto 0);
        hex2       : out std_logic_vector(6 downto 0);
        pronto     : out std_logic;
        db_medir   : out std_logic;
        db_echo    : out std_logic;
        db_trigger : out std_logic;
        db_estado  : out std_logic_vector(6 downto 0) -- estado da UC
    );
end entity exp4_sensor;

architecture exp4_sensor_behavioral of exp4_sensor is
    
    component hex7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

    component interface_hcsr04 is
        port (
            clock     : in std_logic;
            reset     : in std_logic;
            medir     : in std_logic;
            echo      : in std_logic;
            trigger   : out std_logic;
            medida 	  : out std_logic_vector(11 downto 0); -- 3 digitos BCD
            pronto 	  : out std_logic;
            db_estado : out std_logic_vector(3 downto 0) -- estado da UC
        );
    end component;

    component edge_detector is
        port (  
            clock     : in  std_logic;
            signal_in : in  std_logic;
            output    : out std_logic
        );
    end component;

    signal s_medir         : std_logic;
    signal s_trigger       : std_logic;
    signal s_db_estado     : std_logic_vector(3 downto 0);
    signal s_medida_high   : std_logic_vector(3 downto 0);
    signal s_medida_middle : std_logic_vector(3 downto 0);
    signal s_medida_low    : std_logic_vector(3 downto 0);
    signal s_medida        : std_logic_vector(11 downto 0);

begin
    
    DB: edge_detector
    port map (
        clock     => clock,
        signal_in => medir,
        output    => s_medir
    );

    INT: interface_hcsr04
    port map (
        clock     => clock,
        reset     => reset,
        medir     => s_medir,
        echo      => echo,
        trigger   => s_trigger,
        medida 	  => s_medida,
        pronto 	  => pronto,
        db_estado => s_db_estado
    );

    s_medida_high   <= s_medida(11 downto 8);
    s_medida_middle <= s_medida(7 downto 4);
    s_medida_low    <= s_medida(3 downto 0);

    H0: hex7seg
    port map (
        hexa => s_medida_low,
        sseg => hex0
    );

    H1: hex7seg
    port map (
        hexa => s_medida_middle,
        sseg => hex1
    );

    H2: hex7seg
    port map (
        hexa => s_medida_high,
        sseg => hex2
    );

    H5: hex7seg
    port map (
        hexa => s_db_estado,
        sseg => db_estado
    );

    -- saídas
    db_trigger <= s_trigger;
    db_echo    <= echo;
    db_medir   <= medir;
    trigger    <= s_trigger;
    medida     <= s_medida;
    
end architecture exp4_sensor_behavioral;