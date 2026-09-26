
--! Interfaz
--! ==
--! { signal: [
--!   { name: "CLK_I",            wave: "p....|...." },
--!   { name: "SPI_WRITE8_I",     wave: "l.hl.|....", data: ["WRITE"] , "phase":0.5},
--!   { name: "SPI_WRITE_DATA_I", wave: "l3.0.|....", data: ["data"] , "phase":0.5},
--!   { name: "SPI_READ_DATA_O",  wave: "l....|.5..", data: ["read"] , "phase":0.5},
--!   { name: "CS",   wave: "h.l..|..h.", "phase":0.5}
--! ]}

--! SPI interfaz
--! --
--! { signal: [
--!   { name: "SCK",      wave: "lp|.....l" },
--!   { name: "MOSI",     wave: "l3|.....0", data: ["WRITE"] },
--!   { name: "MISO",     wave: "l4|.....0", data: ["READ"] },
--!   { name: "CS",       wave: "hl|.....h"},
--!   {},
--!   { name: "Estado",   wave: "l5|555550", data: ["1", "4/12", "5/13", "6/14", "7/15", "8/16"] }
--! ]}

library ieee;
use ieee.std_logic_1164.all;

entity SPI is
  generic (
    --! Frecuencia de reloj del módulo.
    G_FPGA_FREQ : integer := 100_000_000;
    --! Frecuencia del SPI.
    G_FREQ_SPI : integer := 1_000_000
  );
  port (
    --! Este es el reloj del módulo.
    CLK_I : in std_logic;
    --! Este es el reset del módulo. Activo a nivel bajo.
    RST_N_I : in std_logic;
    --! Esta es la habilitación del módulo. Activo nivel alto.
    EN_I : in std_logic;
    --! Señal de escritura de 8 bits. Activo a nivel alto.
    SPI_WRITE8_I : in std_logic;
    --! Señal de escritura de 16 bits. Activo a nivel alto.
    SPI_WRITE16_I : in std_logic;
    --! Modo de operación del SPI.
    --! Modos: 
    --! 0 = Modo 0  /
    --! 1 = Modo 1  /
    --! El resto de modos no está contemplado.
    MODO_I : in std_logic_vector(1 downto 0);
    --! Este puerto selecciona el tipo de lectura que se hace, si de MSB a LSB o de LSB a MSB.
    --! Si es 0, se lee de MSB a LSB. Si es 1, se lee de LSB a MSB.
    MSB_LSB_I : in std_logic;
    --! Dato a transmitir por SPI.
    SPI_WRITE_DATA_I : in std_logic_vector(15 downto 0);
    --! Dato leído por SPI.
    SPI_READ_DATA_O : out std_logic_vector(15 downto 0);

    -- SPI
    --! Señal de reloj del SPI.
    SCK_O : out std_logic;
    --! Señal MOSI(Master Output Slave Input).
    MOSI_O : out std_logic;
    --! Señal MISO(Master Input Slave Output).
    MISO_I : in std_logic;
    --! Señal que indica que el SPI está activo. Nivel bajo: esto operativo.
    --! Este puerto hace la doble funcionalidad, puerto CS y puerto READY.
    CS : out std_logic
  );
end entity SPI;

architecture rtl of SPI is

  --! Máquina de estados que controla este módulo.
  type fsm is (
    --! Señal de espera del SPI.
    SM_IDLE,
    --! Estado de espera para escribir 8 bits.
    SM_WAIT8,
    --! Estado de escritura de 8 bits.
    SM_WRITE8,
    --! Estado de espera para escribir 16 bits.
    SM_WAIT16,
    --! Estado de escritura de 16 bits.
    SM_WRITE16,
    --! Registro previo para volver la máquina de estados al estado inicial.
    SM_WAIT_FINISH
  );

  --! Registro con el valor de la máquina de estado.
  signal re_state : fsm;
  --! Señal de 1 ciclo de reloj para el detector de flanco.
  signal s_spi8_write, s_spi16_write : std_logic;
  --! Contador del número de flancos de reloj del SPI.
  signal r_cont : integer range 0 to 16;
  --! Tamaño de datos de 8 bits.
  constant C_DATA8 : integer := 8;
  --! Tamaño de datos de 16 bits.
  constant C_DATA16 : integer := 16;
  --! Número de ciclos de reloj para un periodo del SPI.
  constant C_PULSES_PERIOD : integer := G_FPGA_FREQ/G_FREQ_SPI;
  --! Contador de medio periodo de SPI.
  constant C_SPI_MID_PERIOD : integer := C_PULSES_PERIOD/2;
  --! Contador de ciclos de reloj para medio periodo.
  signal r_sck_cont : integer range 0 to C_SPI_MID_PERIOD;

  --! Señal de reloj del SPI.
  signal s_sck : std_logic;
  --! Señales con los detectores de flancos para el SPI.
  signal s_rise_edge, s_fall_edge : std_logic;
  --! Registro con los datos de escritura y lectura.
  signal r_write, r_read : std_logic_vector(15 downto 0);

  --! Contador para reiniciar la máquina de estados.
  signal r_cont_wait : integer range 0 to C_PULSES_PERIOD;
  --! Modo 0 de operación del SPI.
  constant C_MODO_0 : std_logic_vector(1 downto 0) := "00";
  --! Modo 1 de operación del SPI.
  constant C_MODO_1 : std_logic_vector(1 downto 0) := "01";
  --! Modo 2 de operación del SPI.
  -- constant C_MODO_2 : std_logic_vector(1 downto 0) := "10";
  --! Modo 3 de operación del SPI.
  -- constant C_MODO_3 : std_logic_vector(1 downto 0) := "11";

  --! Constante con 8 ceros.
  constant ZEROS : std_logic_vector(7 downto 0) := (others => '0');

begin

  --! @brief Detector de flancos de la señal de 8 bits.
  SPI8_edge_detector_inst : entity work.edge_detector
    port map
    (
      CLK_I          => CLK_I,
      INPUT_SIGNAL_I => SPI_WRITE8_I,
      RISING_EDGE_O  => s_spi8_write,
      FALLING_EDGE_O => open,
      EDGES_O        => open
    );

  --! @brief Detector de flancos de la señal de 16 bits.
  SPI16_edge_detector_inst : entity work.edge_detector
    port map
    (
      CLK_I          => CLK_I,
      INPUT_SIGNAL_I => SPI_WRITE16_I,
      RISING_EDGE_O  => s_spi16_write,
      FALLING_EDGE_O => open,
      EDGES_O        => open
    );

  --! @brief Este process controla la máquina de estados.
  FSM_PROCESS : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        re_state <= SM_IDLE;
      elsif EN_I = '1' then
        case re_state is
          when SM_IDLE =>
            re_state <= SM_IDLE;
            if s_spi8_write = '1' then
              re_state <= SM_WAIT8;
            elsif s_spi16_write = '1' then
              re_state <= SM_WAIT16;
            end if;

          when SM_WAIT8 =>
            re_state <= SM_WAIT8;
            if MODO_I = C_MODO_1 then
              if s_fall_edge = '1' then
                re_state <= SM_WRITE8;
              end if;
            else
              re_state <= SM_WRITE8;
            end if;

          when SM_WRITE8 =>
            re_state <= SM_WRITE8;
            if r_cont >= C_DATA8 - 1 and s_fall_edge = '1' then
              re_state <= SM_WAIT_FINISH;
            end if;

          when SM_WAIT16 =>
            re_state <= SM_WAIT16;
            if MODO_I = C_MODO_1 then
              if s_fall_edge = '1' then
                re_state <= SM_WRITE16;
              end if;
            else
              re_state <= SM_WRITE16;
            end if;

          when SM_WRITE16 =>
            re_state <= SM_WRITE16;
            if r_cont >= C_DATA16 - 1 and s_fall_edge = '1' then
              re_state <= SM_WAIT_FINISH;
            end if;

          when SM_WAIT_FINISH =>
            re_state <= SM_WAIT_FINISH;
            if r_cont_wait >= C_PULSES_PERIOD - 1 then
              re_state <= SM_IDLE;
            end if;

          when others =>
            re_state <= SM_IDLE;
        end case;
      end if;
    end if;
  end process;

  --! @brief Este process cuenta una el número de flancos de reloj para
  --! generar la mitad del periodo del reloj del SPI.
  CONTADOR_RELOJ : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        r_sck_cont <= 0;
      elsif EN_I = '1' then
        if re_state = SM_IDLE or re_state = SM_WAIT_FINISH then
          r_sck_cont <= 0;
        else
          r_sck_cont <= r_sck_cont + 1;
          if r_sck_cont >= C_SPI_MID_PERIOD - 1 then
            r_sck_cont <= 0;
          end if;
        end if;
      end if;
    end if;
  end process;

  --! @brief Asignación de reloj de salida.
  SCK_ASSIGN : SCK_O <= s_sck;

  --! @brief Este process genera el reloj de SPI.
  SDK_GENERATOR : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        s_sck <= '0';
      elsif EN_I = '1' then
        if re_state = SM_IDLE or re_state = SM_WAIT_FINISH then
          s_sck <= '0';
        else
          if r_sck_cont >= C_SPI_MID_PERIOD - 1 then
            s_sck <= not s_sck;
          end if;
        end if;
      end if;
    end if;
  end process;

  --! @brief Este es el detector de flancos para el reloj del SPI.
  SCK_edge_detector_inst : entity work.edge_detector
    port map
    (
      CLK_I          => CLK_I,
      INPUT_SIGNAL_I => s_sck,
      RISING_EDGE_O  => s_rise_edge,
      FALLING_EDGE_O => s_fall_edge,
      EDGES_O        => open
    );

  --! @brief Este es el contador de ciclos de reloj del SPI.
  CONTADOR_CICLOS_RELOJ : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        r_cont <= 0;
      elsif EN_I = '1' then
        if re_state = SM_IDLE or re_state = SM_WAIT_FINISH then
          r_cont <= 0;
        else
          if s_fall_edge = '1' then
            r_cont <= r_cont + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  --! @brief Esta es la asignación del puerto MOSI.
  MOSI_ASSIGNS : MOSI_O <= r_write(15);

  --! @brief Este process es el generador de pulsos por MOSI. Para
  --! ello se utiliza un desplazmiento a izquierdas.
  ESCRITURA_SPI : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        r_write <= (others => '0');
      elsif EN_I = '1' then
        if re_state = SM_IDLE then
          -- reseteo del valor de escritura
          r_write <= (others => '0');
        elsif re_state = SM_WAIT16 then
          -- Asignación del valor de escritura de 16 bits
          r_write <= SPI_WRITE_DATA_I; -- 16 bits
        elsif re_state = SM_WAIT8 then
          -- Asignación del valor de escritura de 8 + 8 ceros.
          r_write <= SPI_WRITE_DATA_I(7 downto 0) & ZEROS; -- 8 bits + 0's
        else
          if MODO_I = C_MODO_0 then
            if s_fall_edge = '1' then
              if MSB_LSB_I = '0' then
                r_write <= r_write(14 downto 0) & r_write(0);
              else
                r_write <= r_write(0) & r_write(15 downto 1);
              end if;
            end if;
          elsif MODO_I = C_MODO_1 then
            if s_rise_edge = '1' then
              if MSB_LSB_I = '0' then
                r_write <= r_write(14 downto 0) & r_write(0);
              else
                r_write <= r_write(0) & r_write(15 downto 1);
              end if;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;

  --! @brief Esta es la asignación del dato leído para la salida.
  READ_DATA : SPI_READ_DATA_O <= r_read;

  --! @brief Este process lee los datos por SPI.
  LECTURA_MISO : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        r_read <= (others => '0');
      elsif EN_I = '1' then
        if re_state = SM_WAIT8 or re_state = SM_WAIT16 then
          r_read <= (others => '0');
        elsif re_state = SM_WRITE16 then

          if MODO_I = C_MODO_0 then
            if s_rise_edge = '1' then
              if MSB_LSB_I = '0' then
                -- Desplazamiento del valor de lectura desde la derecha.
                r_read <= r_read(14 downto 0) & MISO_I;
              else
                -- Desplazamiento del valor de lectura desde la izquierda.
                r_read <= MISO_I & r_read(15 downto 1);
              end if;
            end if;
          elsif MODO_I = C_MODO_1 then
            if s_fall_edge = '1' then
              if MSB_LSB_I = '0' then
                -- Desplazamiento del valor de lectura desde la derecha.
                r_read <= r_read(14 downto 0) & MISO_I;
              else
                -- Desplazamiento del valor de lectura desde la izquierda.
                r_read <= MISO_I & r_read(15 downto 1);
              end if;
            end if;
          end if;

        elsif re_state = SM_WRITE8 then

          if MODO_I = C_MODO_0 then
            if s_rise_edge = '1' then
              if MSB_LSB_I = '0' then
                -- Desplazamiento del valor de lectura desde la derecha.
                r_read <= r_read(14 downto 0) & MISO_I;
              else
                -- Desplazamiento del valor de lectura desde la izquierda.
                -- Se utilizan solo los últimos 8 bits.
                r_read <= ZEROS & MISO_I & r_read(7 downto 1);
              end if;
            end if;
          elsif MODO_I = C_MODO_1 then
            if s_fall_edge = '1' then
              if MSB_LSB_I = '0' then
                -- Desplazamiento del valor de lectura desde la derecha.
                r_read <= r_read(14 downto 0) & MISO_I;
              else
                -- Desplazamiento del valor de lectura desde la izquierda.
                -- Se utilizan solo los últimos 8 bits.
                r_read <= ZEROS & MISO_I & r_read(7 downto 1);
              end if;
            end if;
          end if;
        end if;

      end if;
    end if;
  end process;

  --! @brief Este process genera la salida del puerto READY y CS.
  CS_GENERATOR : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        CS <= '0';
      elsif EN_I = '1' then
        CS <= '0';
        if re_state = SM_IDLE then
          CS <= '1';
        end if;
      end if;
    end if;
  end process;

  --! Este process cuenta el número de ciclos de reloj para poder levantar la línea CS.
  FINISH_COUNTER : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        r_cont_wait <= 0;
      elsif EN_I = '1' then
        r_cont_wait <= 0;
        if re_state = SM_WAIT_FINISH then
          r_cont_wait <= r_cont_wait + 1;
        end if;
      end if;
    end if;
  end process;

end architecture;