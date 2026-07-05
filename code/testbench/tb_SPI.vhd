
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SPI_tb is
end;

architecture bench of SPI_tb is
  -- Clock period
  constant CLK_PERIOD : time := 5 ns;
  -- Generics
  constant G_FPGA_FREQ : integer := 100_000_000;
  constant G_FREQ_SPI  : integer := 1_000_000;
  -- Ports
  signal CLK_I            : std_logic := '0';
  signal RST_N_I          : std_logic;
  signal EN_I             : std_logic;
  signal SPI_WRITE8_I     : std_logic;
  signal SPI_WRITE16_I    : std_logic;
  signal SPI_WRITE_DATA_I : std_logic_vector(15 downto 0);
  signal SPI_READ_DATA_O  : std_logic_vector(15 downto 0);
  signal SPI_READY_O      : std_logic;
  signal SCK_O            : std_logic;
  signal MOSI_O           : std_logic;
  signal MISO_I           : std_logic;
begin

  SPI_inst : entity work.SPI
    generic map(
      G_FPGA_FREQ => G_FPGA_FREQ,
      G_FREQ_SPI  => G_FREQ_SPI
    )
    port map
    (
      CLK_I            => CLK_I,
      RST_N_I          => RST_N_I,
      EN_I             => EN_I,
      SPI_WRITE8_I     => SPI_WRITE8_I,
      SPI_WRITE16_I    => SPI_WRITE16_I,
      SPI_WRITE_DATA_I => SPI_WRITE_DATA_I,
      SPI_READ_DATA_O  => SPI_READ_DATA_O,
      SPI_READY_O      => SPI_READY_O,
      SCK_O            => SCK_O,
      MOSI_O           => MOSI_O,
      MISO_I           => MISO_I
    );
  CLK_I            <= not CLK_I after CLK_PERIOD;
  RST_N_I          <= '0', '1' after 50 ns;
  EN_I             <= '1';
  SPI_WRITE_DATA_I <= x"000F";
  process begin
    SPI_WRITE16_I <= '0';
    SPI_WRITE8_I  <= '0';
    wait for 4 us;
    SPI_WRITE8_I <= '1';
    wait for CLK_PERIOD*2;
    SPI_WRITE8_I <= '0';
    wait for 25 us;
    SPI_WRITE16_I <= '1';
    wait for CLK_PERIOD*2;
    SPI_WRITE16_I <= '0';
    wait;
  end process;

  process begin

    MISO_I <= '0';
    wait for 10 us;
    MISO_I <= '1';
    wait for 4.8 us;
    MISO_I <= '0';
    wait for 7 us;
  end process;

end;