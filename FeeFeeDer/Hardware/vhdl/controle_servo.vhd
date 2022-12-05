library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo is
  port (
      clock       : in  std_logic;
      reset       : in  std_logic;
      posicao     : in  std_logic_vector(1 downto 0);  
      pwm         : out std_logic;
		  db_reset    : out std_logic;
      db_pwm      : out std_logic;
      db_posicao  : out std_logic_vector(1 downto 0)
  );
end controle_servo;

architecture rtl of controle_servo is

  constant CONTAGEM_MAXIMA : integer := 1000000;  -- valor para frequencia da saida de 4KHz 
                                                  -- ou periodo de 25us
  signal contagem    : integer range 0 to CONTAGEM_MAXIMA-1;
  signal largura_pwm : integer range 0 to CONTAGEM_MAXIMA-1;
  signal s_largura   : integer range 0 to CONTAGEM_MAXIMA-1;
 
  signal s_pwm : std_logic;
  
begin

  process(clock, reset, s_largura)
  begin
    -- inicia contagem e largura
    if(reset='1') then
      contagem    <= 0;
      s_pwm       <= '0';
      largura_pwm <= s_largura;
    elsif(rising_edge(clock)) then
        -- saida
        if(contagem < largura_pwm) then
          s_pwm  <= '1';
        else
          s_pwm  <= '0';
        end if;
        -- atualiza contagem e largura
        if(contagem=CONTAGEM_MAXIMA-1) then
          contagem    <= 0;
          largura_pwm <= s_largura;
        else
          contagem    <= contagem + 1;
        end if;
    end if;
  end process;

  process(posicao)
  begin
    case posicao is
      when "00" =>  s_largura <= 73000;  -- pulso de 0,700 ms 
      when "01" =>  s_largura <= 45700;  -- pulso de 0,914 ms 
		  when "10" =>  s_largura <= 99300;  -- pulso de 1,986 ms 
		  when "11" =>  s_largura <= 35000; -- pulso de 2,200 ms 
      when others => s_largura <= 0;      -- nulo saida 0
    end case;
  end process;

  -- Saídas
  pwm        <= s_pwm;
  db_pwm     <= s_pwm;
  db_reset   <= reset;
  db_posicao <= posicao;
  
end rtl;