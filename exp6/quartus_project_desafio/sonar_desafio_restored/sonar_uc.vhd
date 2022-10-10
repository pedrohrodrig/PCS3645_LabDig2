library ieee;
use ieee.std_logic_1164.all;

entity sonar_uc is
    port (
        clock           : in  std_logic;
        reset           : in  std_logic;
        ligar           : in  std_logic;
        fim_2seg        : in  std_logic;
        fim_transmissao : in  std_logic;
		pause 			: in  std_logic;
		reinicio		: in  std_logic;
		timeout			: in  std_logic;
        zera            : out std_logic;
        zera_2seg       : out std_logic;
        conta_2seg      : out std_logic;
        conta_updown    : out std_logic;
        mensurar        : out std_logic;
        pronto          : out std_logic;
		zera_timeout    : out std_logic;
		conta_timeout   : out std_logic;
        db_estado       : out std_logic_vector(3 downto 0)
    );
end entity sonar_uc;

architecture sonar_uc_behavioral of sonar_uc is
    
    type tipo_estado is (
        inicial, 
        preparacao, 
        espera_temporizador, 
		prepara_trena,
        medir_e_transmitir, 
        muda_servomotor,
        final, 
		pausado
    );
    signal Eatual, Eprox: tipo_estado;

begin
    
    process (ligar, reset, clock)
    begin
        if reset = '1' or ligar = '0' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox;
        end if;
    end process;

    process(ligar, fim_2seg, fim_transmissao, timeout, reinicio, pause, Eatual)
    begin
        if pause = '1' then
            Eprox <= pausado;
        end if;

        case Eatual is
            when inicial =>             if ligar = '1' then Eprox <= preparacao;
                                        else                Eprox <= inicial;
                                        end if;
            
            when preparacao =>          Eprox <= espera_temporizador;
            
            when espera_temporizador => if fim_2seg = '1' then Eprox <= prepara_trena;
                                        else                   Eprox <= espera_temporizador;
                                        end if;

            when prepara_trena =>       Eprox <= medir_e_transmitir;
                                        
            when medir_e_transmitir =>  if fim_transmissao = '1' then Eprox <= muda_servomotor;
									    elsif timeout = '1' 	 then Eprox <= prepara_trena;
                                        else                          Eprox <= medir_e_transmitir;
                                        end if;

            when muda_servomotor =>     Eprox <= final;
                        
            when final =>               Eprox <= preparacao; 

			when pausado => 			if reinicio = '1' then Eprox <= preparacao;
										else                   Eprox <= pausado;
										end if;
        end case;
    end process;

    -- Saída de controle
    with Eatual select
        zera <= '1' when inicial, '0' when others;

    with Eatual select
        zera_2seg <= '1' when preparacao, '0' when others;

    with Eatual select
        conta_2seg <= '1' when espera_temporizador, '0' when others;

    with Eatual select
        mensurar <= '1' when prepara_trena, '0' when others;

    with Eatual select
        conta_updown <= '1' when muda_servomotor, '0' when others;
		  
	 with Eatual select
		conta_timeout <= '1' when medir_e_transmitir, '0' when others;
	 
	 with Eatual select
		zera_timeout <= '0' when medir_e_transmitir, '1' when others;

    with Eatual select
        pronto <= '1' when final, '0' when others;

    with Eatual select
        db_estado <= "0000" when inicial, 
                     "0001" when preparacao, 
                     "0010" when espera_temporizador, 
                     "0011" when prepara_trena,
                     "0100" when medir_e_transmitir, 
                     "0101" when muda_servomotor,
                     "0110" when final,
					 "1001" when pausado,
                     "1000" when others;
    
end architecture sonar_uc_behavioral;