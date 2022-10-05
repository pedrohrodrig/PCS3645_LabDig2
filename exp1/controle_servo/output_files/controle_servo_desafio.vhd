library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo is
  port (
      clock       : in  std_logic;
      reset       : in  std_logic;
      posicao     : in  std_logic_vector(2 downto 0);  
      controle    : out std_logic;
		db_controle : out std_logic
  );
end controle_servo;

architecture rtl of controle_servo is

  constant CONTAGEM_MAXIMA : integer := 1000000;  -- valor para frequencia da saida de 4KHz 
                                               -- ou periodo de 25us
  signal contagem     : integer range 0 to CONTAGEM_MAXIMA-1;
  signal largura_pwm  : integer range 0 to CONTAGEM_MAXIMA-1;
  signal s_largura    : integer range 0 to CONTAGEM_MAXIMA-1;
  
  signal s_controle   : std_logic;
  
begin

  process(clock,reset,s_largura)
  begin
    -- inicia contagem e largura
    if(reset='1') then
      contagem    <= 0;
      s_controle  <= '0';
      largura_pwm <= s_largura;
    elsif(rising_edge(clock)) then
        -- saida
        if(contagem < largura_pwm) then
          s_controle  <= '1';
        else
          s_controle  <= '0';
        end if;
        -- atualiza contagem e largura
        if(contagem=CONTAGEM_MAXIMA-1) then
          contagem   <= 0;
          largura_pwm <= s_largura;
        else
          contagem   <= contagem + 1;
        end if;
    end if;
  end process;

  process(posicao)
  begin
    case posicao is
      when "001" =>    s_largura <=  50000; -- pulso de 1,000 ms
      when "010" =>    s_largura <=  56250; -- pulso de 1,125 ms
      when "011" =>    s_largura <=  62500; -- pulso de 1,250 ms
		when "100" =>    s_largura <=  75000; -- pulso de 1,500 ms
		when "101" =>    s_largura <=  81250; -- pulso de 1,625 ms
		when "110" =>    s_largura <=  87500; -- pulso de 1,750 ms
		when "111" =>    s_largura <=  100000; -- pulso de  2  ms
      when others =>  s_largura <=  0;      -- nulo   saida 0
    end case;
  end process;
  
  db_controle <= s_controle;
  controle <= s_controle;
  
end rtl;