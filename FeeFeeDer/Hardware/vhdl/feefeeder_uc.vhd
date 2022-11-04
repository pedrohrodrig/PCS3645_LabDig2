library ieee;
use ieee.std_logic_1164.all;

entity feefeeder_uc is
    port (
        clock                 : in  std_logic;
        reset                 : in  std_logic;
        ligar                 : in  std_logic;
        fim_temp_medida       : in  std_logic;
        fim_temp_servomotor   : in  std_logic;
        pronto_trena          : in  std_logic;
        pouca_comida          : in  std_logic;
        comida_suficiente     : in  std_logic;
        zera_temp_medida      : out std_logic;
        zera_temp_servomotor  : out std_logic;
        conta_temp_medida     : out std_logic;
        conta_temp_servomotor : out std_logic;
        enable_trena          : out std_logic;
        posicao_servomotor    : out std_logic_vector(1 downto 0);
        db_estado             : out std_logic_vector(3 downto 0)
    );
end entity;

architecture feefeeder_uc_behavioral of feefeeder_uc is

    type tipo_estado is (
        inicial, 
        preparacao, 
        espera_medida, 
        prepara_trena, 
        medir_e_transmitir, 
        muda_servomotor, 
        espera_servomotor, 
        retorno_servomotor
    );

    signal Eatual, Eprox: tipo_estado;

begin

    -- estado
    process (reset, clock, ligar)
    begin
        if reset = '1' or ligar = '0' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    process (Eatual, ligar, fim_temp_medida, pronto_trena, pouca_comida, fim_temp_servomotor, comida_suficiente) 
    begin
      case Eatual is
        when inicial => if ligar='1' then Eprox <= preparacao;
                        else              Eprox <= inicial;
                        end if;

        when preparacao => Eprox <= espera_medida;

        when espera_medida => if fim_temp_medida='1' then Eprox <= prepara_trena;
							  else                        Eprox <= espera_medida;
							  end if;

        when prepara_trena => Eprox <= medir_e_transmitir;

		when medir_e_transmitir => if pronto_trena='1' and pouca_comida = '1' then Eprox <= muda_servomotor;
                                   elsif pronto_trena='1'                     then Eprox <= preparacao;
                                   else                                            Eprox <= medir_e_transmitir;
							       end if;

		when muda_servomotor => Eprox <= espera_servomotor;

        when espera_servomotor => if fim_temp_servomotor='1' or comida_suficiente='1' then Eprox <= retorno_servomotor;
                                  else                                                     Eprox <= espera_servomotor;
                                  end if;

        when retorno_servomotor => Eprox <= preparacao;

        when others => Eprox <= inicial;
      end case;
    end process;

  -- saidas de controle
    with Eatual select 
        zera_temp_medida <= '1' when preparacao, '0' when others;

    with Eatual select 
        zera_temp_servomotor <= '1' when preparacao, '0' when others;
		
    with Eatual select
        conta_temp_medida <= '1' when espera_medida, '0' when others;

    with Eatual select
        conta_temp_servomotor <= '1' when espera_servomotor, '0' when others;

    with Eatual select
        enable_trena <= '1' when prepara_trena, '0' when others;

    with Eatual select
        posicao_servomotor <= "11" when muda_servomotor,
                              "00" when others;

    with Eatual select
        db_estado <= "0000" when inicial, 
                     "0001" when preparacao, 
                     "0010" when espera_medida, 
                     "0011" when prepara_trena,
                     "0100" when medir_e_transmitir, 
                     "0101" when muda_servomotor,
                     "0110" when espera_servomotor,
                     "0111" when retorno_servomotor,  
                     "1110" when others;
    
end architecture feefeeder_uc_behavioral;