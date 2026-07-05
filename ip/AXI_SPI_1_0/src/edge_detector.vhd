--! { signal: [
--!    { name: "INPUT_SIGNAL_I",        wave: "0h..l." },
--!    { name: "RISING_EDGE_O",         wave: "0hl..."},
--!    { name: "FALLING_EDGE_O",        wave: "0...hl"},
--!    { name: "EDGES_O",               wave: "0hl.hl"},
--!  ]}           
library ieee;
use ieee.std_logic_1164.all;

entity edge_detector is
  port (
    --! Entrada de reloj del módulo.
    CLK_I : in std_logic;
    --! Entrada de señal.
    INPUT_SIGNAL_I : in std_logic;
    --! Detección de subida.
    RISING_EDGE_O : out std_logic;
    --! Detección de bajada.
    FALLING_EDGE_O : out std_logic;
    --! Flancos de subida y bajada.
    EDGES_O : out std_logic
  );
end entity edge_detector;

architecture rtl of edge_detector is

  --! Entrada retardada.
  signal s_input_delay : std_logic;

begin

  --! Biestable D para retardar la entrada.
  DFF : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      s_input_delay <= INPUT_SIGNAL_I;
    end if;
  end process;

  --! Detección de los flancos de subida.
  RISE_EDGE : RISING_EDGE_O <= not s_input_delay and INPUT_SIGNAL_I;

  --! Detección de los flancos de bajada.
  FALL_EDGE : FALLING_EDGE_O <= s_input_delay and not INPUT_SIGNAL_I;

  --! Detección de los flancos de subida y bajada.
  EDGES : EDGES_O <= s_input_delay xor INPUT_SIGNAL_I;

end architecture;