library ieee;
use ieee.std_logic_1164.all;

entity exp5_trena_uc is 
    port ( 
        clock      		: in  std_logic;
		  mensurar   		: in  std_logic;
		  fim_medida 		: in  std_logic;
		  fim_transmissao : in  std_logic;
		  fim_contagem    : in  std_logic;
		  reset      		: in  std_logic;
        zera       		: out std_logic;
        pronto     		: out std_logic;
		  conta				: out std_logic;
        transmite      : out std_logic;
        db_estado  		: out std_logic_vector(3 downto 0) 
    );
end exp5_trena_uc;

architecture exp5_trena_uc_arch of exp5_trena_uc is
    type tipo_estado is (inicial, preparacao, medir, prepara_transmitir, transmitir, fim_transmitir, final, reinicio);
    signal Eatual, Eprox: tipo_estado;
begin

    -- estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    process (mensurar, fim_medida, fim_transmissao, fim_contagem, Eatual) 
    begin
      case Eatual is
        when inicial =>         if mensurar='1' then Eprox <= preparacao;
                                else                 Eprox <= inicial;
                                end if;
        when preparacao =>      Eprox <= medir;
        when medir =>   		  if fim_medida='1' then Eprox <= prepara_transmitir;
										  else                   Eprox <= medir;
										  end if;
		  when prepara_transmitir =>	Eprox <= transmitir;
		  when transmitir =>      if fim_transmissao='1' then Eprox <= fim_transmitir;
										  else 								Eprox <= transmitir;
										  end if;
		  when fim_transmitir =>  if fim_contagem='1' then Eprox <= final;
										  else 					 		Eprox <= prepara_transmitir;
										  end if;
        when final =>			  Eprox <= reinicio;
        when reinicio =>		  if mensurar='1' then Eprox <= preparacao;
										  else 					  Eprox <= reinicio;
										  end if;
        when others =>          Eprox <= inicial;
      end case;
    end process;

  -- saidas de controle
  with Eatual select 
      zera <= '1' when preparacao, '0' when others;
		
  with Eatual select
      conta <= '1' when fim_transmitir, '0' when others;

  with Eatual select
      transmite <= '1' when transmitir, '0' when others;
		
  with Eatual select
      pronto <= '1' when final | reinicio, '0' when others;

  with Eatual select
      db_estado <= "0000" when inicial, 
                   "0001" when preparacao, 
                   "0010" when medir, 
                   "0011" when transmitir,
                   "0100" when final, 
                   "0101" when reinicio,  
                   "1110" when others;

end architecture exp5_trena_uc_arch;