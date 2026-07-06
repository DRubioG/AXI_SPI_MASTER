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

// Read Register
#define RDY_BIT 16

class SPI
{
private:
// Esta es la dirección del SPI.
    int _address = 0;

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
    int* transfer(int *buffer, int size);

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
