
--! Registros
--! ==
--! | Nombre  | Offset | R/W | Descripción |
--! |---------|--------|-----|-------------|
--! | CNTRL   |   0x0  |  W  | Registro de control del bloque IP |
--! | WRITE   |   0x4  |  W  | Registro para escribir por SPI |
--! | READ    |   0x8  |  R  | Registro para leer por SPI |
--!
--! CNTRL
--! --
--! - **EN**: Bit de habilitación del bloque IP.
--! - **W8**: Bit para transmitir/leer 8 bits.
--! - **W16**: Bit para transmitir/leer 16 bits.
--! {
--!       "config": { 
--!         "hspace": 1000
--!       },
--!     reg:[
--!     { "name": "EN",   		"bits": 1, "attr": "w", "type": 4},
--!     { "name": "W8",   		"bits": 1, "attr": "w", "type": 5 },
--!     { "name": "W16",   		"bits": 1, "attr": "w", "type": 6 },
--!     { "name": "Reserved",   "bits": 29, "attr": "", "type":"not used" }
--! ]}
--! WRITE
--! --
--! - **WRITE**: Dato a escribir por SPI.
--! {
--!       "config": { 
--!         "hspace": 1000
--!       },
--!     reg:[
--!     { "name": "WRITE",   	"bits": 16, "attr": "w", "type":4 },
--!     { "name": "Reserved",   "bits": 16, "attr": "", "type":"not used" }
--! ]}
--! READ
--! --
--! - **READ**: Dato leído por SPI.
--! - **RDY**: Indicador de que el módulo SPI está listo.
--! {
--!       "config": { 
--!         "hspace": 1000
--!       },
--!     reg:[
--!     { "name": "READ",   	"bits": 16, "attr": "r" , "type": 4},
--!     { "name": "RDY",   		"bits": 1, "attr": "r", "type": 5 },
--!     { "name": "Reserved",   "bits": 15, "attr": "", "type":"not used" }
--! ]}

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AXI_SPI_v1_0 is
  generic (
    -- Users to add parameters here
    --! Frecuencia de reloj del módulo.
    G_FPGA_FREQ : integer := 100_000_000;
    --! Frecuencia del SPI.
    G_FREQ_SPI : integer := 1_000_000;
    -- User parameters ends
    -- Do not modify the parameters beyond this line
    -- Parameters of Axi Slave Bus Interface S_AXI
    C_S_AXI_DATA_WIDTH : integer := 32;
    C_S_AXI_ADDR_WIDTH : integer := 4
  );
  port (
    -- Users to add ports here
    --! Señal de reloj del SPI.
    SCK : out std_logic;
    --! Señal MOSI(Master Output Slave Input).
    MOSI : out std_logic;
    --! Señal MISO(Master Input Slave Output).
    MISO : in std_logic;
    -- User ports ends
    -- Do not modify the ports beyond this line
    -- Ports of Axi Slave Bus Interface S_AXI
    s_axi_aclk    : in std_logic;
    s_axi_aresetn : in std_logic;
    s_axi_awaddr  : in std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
    s_axi_awprot  : in std_logic_vector(2 downto 0);
    s_axi_awvalid : in std_logic;
    s_axi_awready : out std_logic;
    s_axi_wdata   : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    s_axi_wstrb   : in std_logic_vector((C_S_AXI_DATA_WIDTH/8) - 1 downto 0);
    s_axi_wvalid  : in std_logic;
    s_axi_wready  : out std_logic;
    s_axi_bresp   : out std_logic_vector(1 downto 0);
    s_axi_bvalid  : out std_logic;
    s_axi_bready  : in std_logic;
    s_axi_araddr  : in std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
    s_axi_arprot  : in std_logic_vector(2 downto 0);
    s_axi_arvalid : in std_logic;
    s_axi_arready : out std_logic;
    s_axi_rdata   : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in std_logic
  );
end AXI_SPI_v1_0;

architecture arch_imp of AXI_SPI_v1_0 is

  -- component declaration
  component AXI_SPI_v1_0_S_AXI is
    generic (
      G_FPGA_FREQ        : integer := 100_000_000;
      G_FREQ_SPI         : integer := 1_000_000;
      C_S_AXI_DATA_WIDTH : integer := 32;
      C_S_AXI_ADDR_WIDTH : integer := 4
    );
    port (
      SCK           : out std_logic;
      MOSI          : out std_logic;
      MISO          : in std_logic;
      S_AXI_ACLK    : in std_logic;
      S_AXI_ARESETN : in std_logic;
      S_AXI_AWADDR  : in std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
      S_AXI_AWPROT  : in std_logic_vector(2 downto 0);
      S_AXI_AWVALID : in std_logic;
      S_AXI_AWREADY : out std_logic;
      S_AXI_WDATA   : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
      S_AXI_WSTRB   : in std_logic_vector((C_S_AXI_DATA_WIDTH/8) - 1 downto 0);
      S_AXI_WVALID  : in std_logic;
      S_AXI_WREADY  : out std_logic;
      S_AXI_BRESP   : out std_logic_vector(1 downto 0);
      S_AXI_BVALID  : out std_logic;
      S_AXI_BREADY  : in std_logic;
      S_AXI_ARADDR  : in std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
      S_AXI_ARPROT  : in std_logic_vector(2 downto 0);
      S_AXI_ARVALID : in std_logic;
      S_AXI_ARREADY : out std_logic;
      S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
      S_AXI_RRESP   : out std_logic_vector(1 downto 0);
      S_AXI_RVALID  : out std_logic;
      S_AXI_RREADY  : in std_logic
    );
  end component AXI_SPI_v1_0_S_AXI;

begin

  -- Instantiation of Axi Bus Interface S_AXI
  AXI_SPI_v1_0_S_AXI_inst : AXI_SPI_v1_0_S_AXI
  generic map(
    G_FPGA_FREQ        => G_FPGA_FREQ,
    G_FREQ_SPI         => G_FREQ_SPI,
    C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
    C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH
  )
  port map
  (
    SCK           => SCK,
    MOSI          => MOSI,
    MISO          => MISO,
    S_AXI_ACLK    => s_axi_aclk,
    S_AXI_ARESETN => s_axi_aresetn,
    S_AXI_AWADDR  => s_axi_awaddr,
    S_AXI_AWPROT  => s_axi_awprot,
    S_AXI_AWVALID => s_axi_awvalid,
    S_AXI_AWREADY => s_axi_awready,
    S_AXI_WDATA   => s_axi_wdata,
    S_AXI_WSTRB   => s_axi_wstrb,
    S_AXI_WVALID  => s_axi_wvalid,
    S_AXI_WREADY  => s_axi_wready,
    S_AXI_BRESP   => s_axi_bresp,
    S_AXI_BVALID  => s_axi_bvalid,
    S_AXI_BREADY  => s_axi_bready,
    S_AXI_ARADDR  => s_axi_araddr,
    S_AXI_ARPROT  => s_axi_arprot,
    S_AXI_ARVALID => s_axi_arvalid,
    S_AXI_ARREADY => s_axi_arready,
    S_AXI_RDATA   => s_axi_rdata,
    S_AXI_RRESP   => s_axi_rresp,
    S_AXI_RVALID  => s_axi_rvalid,
    S_AXI_RREADY  => s_axi_rready
  );

  -- Add user logic here

  -- User logic ends

end arch_imp;
