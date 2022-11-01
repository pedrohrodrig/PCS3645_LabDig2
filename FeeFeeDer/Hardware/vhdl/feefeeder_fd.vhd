library ieee;
use ieee.std_logic_1164.all;

entity feefeeder_fd is
    port (

    );
end entity;

architecture behavioral of feefeeder_fd is

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
            posicao    : in  std_logic_vector(2 downto 0);  
            pwm        : out std_logic;
            db_reset   : out std_logic;
            db_pwm     : out std_logic;
            db_posicao : out std_logic_vector(2 downto 0)
        );
    end component;

begin
    
    
    
end architecture behavioral;