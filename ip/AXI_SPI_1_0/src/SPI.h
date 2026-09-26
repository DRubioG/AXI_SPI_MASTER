/**
 * @file SPI.h
 * @version 0.1
 * @date 2026-07-04
 *
 * @copyright Copyright (c) 2026
 *
 */
#include "xil_io.h"

// Registers
#define BASE_REG 0x00
#define CNTRL_REG BASE_REG + 0x00
#define WRITE_REG BASE_REG + 0x04
#define READ_REG BASE_REG + 0x08

// CNTRL Register
#define ENABLE_BIT 0
#define WRITE8_BIT 1
#define WRITE16_BIT 2
#define MODE_BIT 3
#define MLSB_BIT 5

// Read Register
#define RDY_BIT 16

// Selección de orden de lectura/escritura
enum BitOrder
{
    MSB_FIRST = 0,
    LSB_FIRST = 1
};

// Selección del modo del SPI.
enum SPIMode
{
    SPI_MODE0 = 0,
    SPI_MODE1 = 1
};

// Estructura para la selección de parámetros del SPI.
struct SPISettings
{
    // Definiciones.
    uint32_t clock;
    BitOrder bitOrder;
    SPIMode mode;

    // Función interna de configuración.
    SPISettings(uint32_t clock,
                BitOrder bitOrder,
                SPIMode mode)
        : clock(clock),
          bitOrder(bitOrder),
          mode(mode) {}
};

class SPI
{
private:
    // Esta es la dirección del SPI.
    int _address = 0;

    /**
     * @brief Configuración del orden de lectura/escritura.
     * 
     * @param order Ordenación del bit de escritura/lectura.
     */
    void configureBitOrder(BitOrder order);
    
    /**
     * @brief Configuración del modo del SPI.
     * 
     * @param mode Modo del SPI.
     */
    void configureMode(SPIMode mode);

public:
    /**
     * @brief Constructor de la clase.
     *
     * @code {.C++}
     *
     * #include "xparameters.h"
     *
     * #include "SPI.h"
     *
     * #define ADDRESS XPAR_AXI_SPI_0_S_AXI_BASEADDR
     *
     * SPI SPI(ADDRESS);
     * @endcode
     *
     *
     * @param address Dirección del bloque IP.
     */
    SPI(uint32_t address);

    /**
     * @brief Desctructor de la clase.
     *
     */
    ~SPI();

    /**
     * @brief Este método comienza la comunicación SPI.
     *
     * @code {.C++}
     *
     * #include "xparameters.h"
     *
     * #include "SPI.h"
     *
     * #define ADDRESS XPAR_AXI_SPI_0_S_AXI_BASEADDR
     *
     * SPI SPI(ADDRESS);
     *
     * SPI.begin();
     * @endcode
     */
    void begin();

    /**
     * @brief Este método inicializa el SPI con los parámetros de entrada.
     *
     * @code {.C++}
     *
     * #include "xparameters.h"
     *
     * #include "SPI.h"
     *
     * #define ADDRESS XPAR_AXI_SPI_0_S_AXI_BASEADDR
     *
     * SPI SPI(ADDRESS);
     *
     * SPI.beginTransaction(SPISettings(14000000, MSB_FIRST, SPI_MODE1));
     * @endcode
     *
     * @param settings Estos son los parámetros de configuración de entrada.
     */
    void beginTransaction(const SPISettings &settings);

    /**
     * @brief Este método transmite el dato por SPI.
     *
     * @code {.C++}
     *
     * #include "xparameters.h"
     *
     * #include "SPI.h"
     *
     * #define ADDRESS XPAR_AXI_SPI_0_S_AXI_BASEADDR
     *
     * SPI SPI(ADDRESS);
     *
     * SPI.begin();
     *
     * // CS -> '0'
     *
     * int respuesta = SPI.transfer(0xA5);
     *
     *
     * // CS -> '1'
     * @endcode
     *
     * @param value Valor a transmitir.
     * @return int Valor leído.
     */
    int transfer(int value);

    /**
     * @brief Este método transmite un array de datos.
     *
     * @code {.C++}
     *
     * #include "xparameters.h"
     *
     * #include "SPI.h"
     *
     * #define ADDRESS XPAR_AXI_SPI_0_S_AXI_BASEADDR
     *
     * SPI SPI(ADDRESS);
     *
     * SPI.begin();
     *
     * int buffer[5]= {0, 1, 2, 3, 4};
     *
     *
     * // CS -> '0'
     *
     * SPI.transfer(buffer, 5);
     *
     *
     * // CS -> '1'
     * @endcode
     *
     * @param buffer Array de datos a transmitir.
     * @param size Tamaño de los datos.
     * @return int* Buffer con los datos leídos.
     */
    int *transfer(int *buffer, int size);

    /**
     * @brief Este método transmite un dato de 16 bits.
     *
     * @code {.C++}
     *
     * #include "xparameters.h"
     *
     * #include "SPI.h"
     *
     * #define ADDRESS XPAR_AXI_SPI_0_S_AXI_BASEADDR
     *
     * SPI SPI(ADDRESS);
     *
     * SPI.begin();
     *
     * // CS -> '0'
     *
     * uint16_t respuesta = SPI.transfer16(0xA5);
     *
     * // CS -> '1'
     * @endcode
     *
     * @param value Datos de 16 bits a transmitir.
     * @return uint16_t Datos de 16 bits leído.
     */
    uint16_t transfer16(uint16_t value);
};
