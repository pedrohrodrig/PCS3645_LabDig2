library ieee;
use ieee.std_logic_1164.all;

entity rx_serial_uc is 
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
end entity;

architecture rx_serial_uc_arch of rx_serial_uc is

    type tipo_estado is (inicial, reinicio, preparacao, espera, recepcao, final);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin

  -- memoria de estado
  process (reset, clock)
  begin
      if reset = '1' then
          Eatual <= inicial;
      elsif clock'event and clock = '1' then
          Eatual <= Eprox; 
      end if;
  end process;

  -- logica de proximo estado
  process (start_bit, tick, fim, Eatual) 
  begin

    case Eatual is

    when inicial => if start_bit='0' then Eprox <= preparacao;
                    else                  Eprox <= inicial;
                    end if;

    when preparacao => Eprox <= espera;

    when espera => if tick='1' then   Eprox <= recepcao;
                   elsif fim='0' then Eprox <= espera;
                   else               Eprox <= final;
                   end if;

    when recepcao => if fim='0' then Eprox <= espera;
                     else         Eprox <= final;
                     end if;

    when final => Eprox <= reinicio;
		
	when reinicio => if start_bit='0' then Eprox <= preparacao;
					 else Eprox <= reinicio;
					 end if;

    when others => Eprox <= inicial;

    end case;

  end process;

  -- logica de saida (Moore)
  with Eatual select
      zera <= '1' when preparacao, '0' when others;

  with Eatual select
      desloca <= '1' when recepcao, '0' when others;

  with Eatual select
      conta <= '1' when recepcao, '0' when others;

  with Eatual select
      pronto <= '1' when final, '0' when others;
		
  with Eatual select
      enable <= '1' when final, '0' when others;
   
  with Eatual select
      clear <= '1' when inicial, '0' when others;
		
  with Eatual select
	  conta_tick <= '1' when espera | recepcao, '0' when others;
		
  with Eatual select
	  tem_dado <= '1' when reinicio | final, '0' when others;

  with Eatual select
	  en_paridade_ok <= '1' when reinicio | final, '0' when others;

  -- Sinal de depuração de estado
  db_estado <= "0000" when Eatual = inicial    else
			   "0001" when Eatual = preparacao else 
			   "0010" when Eatual = espera     else
			   "0011" when Eatual = recepcao   else
			   "0100" when Eatual = final      else
			   "0101" when Eatual = reinicio   else
			   "1000";

end architecture rx_serial_uc_arch;
