library ieee;
use ieee.std_logic_1164.all;

entity feefeeder_uc is
    port (
        clock                       : in  std_logic;
        reset                       : in  std_logic;
        ligar                       : in  std_logic;
        fim_temp_medida             : in  std_logic;
        fim_temp_servomotor         : in  std_logic;
        fim_temp_aberto             : in  std_logic;
        fim_timeout                 : in  std_logic;
        pronto_trena_comedouro      : in  std_logic;
        pouca_comida_comedouro      : in  std_logic;
        comida_suficiente_comedouro : in  std_logic;
		pouca_comida_reservatorio   : in  std_logic;
        zera_temp_medida            : out std_logic;
        zera_temp_servomotor        : out std_logic;
        zera_temp_aberto            : out std_logic;
        zera_timeout                : out std_logic;
        conta_temp_medida           : out std_logic;
        conta_temp_servomotor       : out std_logic;
        conta_temp_aberto           : out std_logic;
        conta_timeout               : out std_logic;
        enable_trena                : out std_logic;
        enable_reg_servomotor       : out std_logic;
        posicao_servomotor          : out std_logic_vector(1 downto 0);
        db_estado                   : out std_logic_vector(3 downto 0)
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
        espera_medida_aberto,
        prepara_trena_aberto,
        medir_e_transmitir_aberto,
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
    process (Eatual, ligar, fim_temp_medida, pouca_comida_comedouro, pouca_comida_reservatorio, fim_temp_servomotor, comida_suficiente_comedouro, fim_temp_aberto, fim_timeout, pronto_trena_comedouro) 
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

		when medir_e_transmitir => if pouca_comida_comedouro = '1' and pouca_comida_reservatorio = '0' then Eprox <= muda_servomotor;
                                   elsif pronto_trena_comedouro='1'                                    then Eprox <= preparacao;
                                   elsif fim_timeout = '1'                                             then Eprox <= prepara_trena;
                                   else                                                                     Eprox <= medir_e_transmitir;
							       end if;

		when muda_servomotor => Eprox <= espera_medida_aberto;

        when espera_medida_aberto => if fim_temp_servomotor='1' then Eprox <= retorno_servomotor;
                                     elsif fim_temp_aberto='1'  then Eprox <= prepara_trena_aberto;
                                     else                            Eprox <= espera_medida_aberto;
                                     end if;

        when prepara_trena_aberto => if fim_temp_servomotor='1' then Eprox <= retorno_servomotor;
                                     else                            Eprox <= medir_e_transmitir_aberto;
									 end if;

        when medir_e_transmitir_aberto => if fim_temp_servomotor='1' or (pronto_trena_comedouro='1' and comida_suficiente_comedouro='1') then Eprox <= retorno_servomotor;
                                          elsif pronto_trena_comedouro='1'                                                     then Eprox <= espera_medida_aberto;
                                          else                                                                                      Eprox <= medir_e_transmitir_aberto;
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
        zera_temp_aberto <= '1' when preparacao, '0' when others;
		
    with Eatual select
        conta_temp_medida <= '1' when espera_medida, '0' when others;

    with Eatual select
        conta_temp_servomotor <= '1' when espera_medida_aberto | prepara_trena_aberto | medir_e_transmitir_aberto, '0' when others;

    with Eatual select 
        conta_temp_aberto <= '1' when espera_medida_aberto, '0' when others;

    with Eatual select
        enable_trena <= '1' when prepara_trena | prepara_trena_aberto, '0' when others;

    with Eatual select
        enable_reg_servomotor <= '1' when muda_servomotor | retorno_servomotor, '0' when others;

    with Eatual select
        posicao_servomotor <= "11" when muda_servomotor, "00" when others;

    with Eatual select
        conta_timeout <= '1' when medir_e_transmitir, '0' when others;

    with Eatual select
        zera_timeout <= '0' when medir_e_transmitir, '1' when others;

    with Eatual select
        db_estado <= "0000" when inicial, 
                     "0001" when preparacao, 
                     "0010" when espera_medida, 
                     "0011" when prepara_trena,
                     "0100" when medir_e_transmitir, 
                     "0101" when muda_servomotor,
                     "0110" when espera_medida_aberto,
                     "0111" when prepara_trena_aberto,
					 "1000" when medir_e_transmitir_aberto,
					 "1001" when retorno_servomotor,		
                     "1110" when others;
    
end architecture feefeeder_uc_behavioral;