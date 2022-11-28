library ieee;
use ieee.std_logic_1164.all;

entity feefeeder is
    port (
        clock                 : in  std_logic;
        reset                 : in  std_logic;
        echo                  : in  std_logic;
        ligar                 : in  std_logic;
        trigger               : out std_logic;
		  saida_serial          : out std_logic;
		  pwm                   : out std_logic;
          db_ligar              : out std_logic;
		  db_posicao_servomotor : out std_logic_vector(1 downto 0);
        db_estado_trena       : out std_logic_vector(6 downto 0);
        db_estado_medida      : out std_logic_vector(6 downto 0);
        db_estado_transmissor : out std_logic_vector(6 downto 0);
        db_estado             : out std_logic_vector(6 downto 0)
    );
end entity;

architecture feefeeder_behavioral of feefeeder is
    
    component feefeeder_fd is
        port (
        clock                 : in  std_logic;
        reset                 : in  std_logic;
        echo                  : in  std_logic;
        zera_temp_medida      : in  std_logic;
        zera_temp_servomotor  : in  std_logic;
        zera_temp_aberto      : in  std_logic;
        conta_temp_medida     : in  std_logic;
        conta_temp_servomotor : in  std_logic;
        conta_temp_aberto     : in  std_logic;
        enable_trena          : in  std_logic;
		  enable_reg_servomotor : in  std_logic;
        posicao_servomotor    : in  std_logic_vector(1 downto 0);
        trigger               : out std_logic;
        saida_serial          : out std_logic;
        fim_temp_medida       : out std_logic;
        fim_temp_servomotor   : out std_logic;
        fim_temp_aberto       : out std_logic;
        pronto_trena          : out std_logic;
        pouca_comida          : out std_logic;
        comida_suficiente     : out std_logic;
        pwm                   : out std_logic;
        db_estado_trena       : out std_logic_vector(6 downto 0);
        db_estado_medida      : out std_logic_vector(6 downto 0);
        db_estado_transmissor : out std_logic_vector(6 downto 0);
        db_posicao_servomotor : out std_logic_vector(1 downto 0)
    );
	end component;

    component feefeeder_uc is
        port (
			  clock                 : in  std_logic;
			  reset                 : in  std_logic;
			  ligar                 : in  std_logic;
			  fim_temp_medida       : in  std_logic;
			  fim_temp_servomotor   : in  std_logic;
			  fim_temp_aberto       : in  std_logic;
			  pronto_trena          : in  std_logic;
			  pouca_comida          : in  std_logic;
			  comida_suficiente     : in  std_logic;
			  zera_temp_medida      : out std_logic;
			  zera_temp_servomotor  : out std_logic;
			  zera_temp_aberto      : out std_logic;
			  conta_temp_medida     : out std_logic;
			  conta_temp_servomotor : out std_logic;
			  conta_temp_aberto     : out std_logic;
			  enable_trena          : out std_logic;
			  enable_reg_servomotor : out std_logic;
			  posicao_servomotor    : out std_logic_vector(1 downto 0);
			  db_estado             : out std_logic_vector(3 downto 0)
        );
    end component;

    component hex7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

    signal s_zera_temp_medida      : std_logic;
    signal s_zera_temp_servomotor  : std_logic;
    signal s_zera_temp_aberto      : std_logic;
    signal s_conta_temp_medida     : std_logic;
    signal s_conta_temp_servomotor : std_logic;
    signal s_conta_temp_aberto     : std_logic;
    signal s_enable_trena          : std_logic;
	 signal s_enable_reg_servomotor : std_logic;
    signal s_posicao_servomotor    : std_logic_vector(1 downto 0);
    signal s_saida_serial          : std_logic;
    signal s_fim_temp_medida       : std_logic;
    signal s_fim_temp_servomotor   : std_logic;
    signal s_fim_temp_aberto       : std_logic;
    signal s_pronto_trena          : std_logic;
    signal s_pouca_comida          : std_logic;
    signal s_comida_suficiente     : std_logic;
    signal s_pwm                   : std_logic;
    signal s_db_estado             : std_logic_vector(3 downto 0);

begin
    
    FD: feefeeder_fd
    port map (
        clock                 => clock,
        reset                 => reset,
        echo                  => echo,
        zera_temp_medida      => s_zera_temp_medida,
        zera_temp_servomotor  => s_zera_temp_servomotor,
        zera_temp_aberto      => s_zera_temp_aberto,
        conta_temp_medida     => s_conta_temp_medida,
        conta_temp_servomotor => s_conta_temp_servomotor,
        conta_temp_aberto     => s_conta_temp_aberto,
        enable_trena          => s_enable_trena,
        posicao_servomotor    => s_posicao_servomotor,
        trigger               => trigger,
        saida_serial          => s_saida_serial,
        fim_temp_medida       => s_fim_temp_medida,
        fim_temp_servomotor   => s_fim_temp_servomotor,
        fim_temp_aberto       => s_fim_temp_aberto,
        pronto_trena          => s_pronto_trena,
        pouca_comida          => s_pouca_comida,
        comida_suficiente     => s_comida_suficiente,
        pwm                   => s_pwm,
        db_estado_trena       => db_estado_trena,
        db_estado_medida      => db_estado_medida,
        db_estado_transmissor => db_estado_transmissor,
		  enable_reg_servomotor => s_enable_reg_servomotor,
        db_posicao_servomotor => db_posicao_servomotor
    );

    UC: feefeeder_uc
    port map (
        clock                 => clock,
        reset                 => reset,
        ligar                 => ligar,
        fim_temp_medida       => s_fim_temp_medida,
        fim_temp_servomotor   => s_fim_temp_servomotor,
		  fim_temp_aberto       => s_fim_temp_aberto,
        pronto_trena          => s_pronto_trena,
        pouca_comida          => s_pouca_comida,
        comida_suficiente     => s_comida_suficiente,
        zera_temp_medida      => s_zera_temp_medida,
        zera_temp_servomotor  => s_zera_temp_servomotor,
		  zera_temp_aberto      => s_zera_temp_aberto,
        conta_temp_medida     => s_conta_temp_medida,
        conta_temp_servomotor => s_conta_temp_servomotor,
		  conta_temp_aberto     => s_conta_temp_aberto,
        enable_trena          => s_enable_trena,
        posicao_servomotor    => s_posicao_servomotor,
		  enable_reg_servomotor => s_enable_reg_servomotor,
        db_estado             => s_db_estado
    );

    HEX: hex7seg
    port map (
        hexa => s_db_estado,
        sseg => db_estado
    );
	 
	 saida_serial <= s_saida_serial;
	 pwm          <= s_pwm;
     db_ligar     <= ligar;
    
end architecture feefeeder_behavioral;