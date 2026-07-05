/**
 * @file SPI_AXI.cpp
 * @version 0.1
 * @date 2026-07-04
 *
 * @copyright Copyright (c) 2026
 *
 */
#include "SPI.h"

// Constructor de la clase.
SPI::SPI(uint32_t address)
{
    // Asignación de la dirección.
    _address = address;
}

// Desctructor de la clase.
SPI::~SPI()
{
}

// Este método comienza la comunicación SPI.
void SPI::begin()
{
    // Lectura del valor del registro.
    uint32_t reg = Xil_In32(_address + CNTRL_REG);
    // Habilitación del bloque IP.
    Xil_Out32(_address + CNTRL_REG, reg | (1 << ENABLE_BIT));
}

// Este método transmite el dato por SPI.
int SPI::transfer(int value)
{
    // Formatear el registro de escritura.
    Xil_Out32(_address + WRITE_REG, 0);
    // Asignación del valor a transmitir.
    Xil_Out32(_address + WRITE_REG, value);
    // Lectura del valor del registro.
    uint32_t reg = Xil_In32(_address + CNTRL_REG);
    // Ejecutar la escritura.
    Xil_Out32(_address + CNTRL_REG, reg | (1 << WRITE8_BIT));
    // Bajar el valor de la escritura.
    Xil_Out32(_address + CNTRL_REG, reg);
    // Esperar a que SPI termine.
    while((Xil_In32(_address + READ_REG)>>RDY_BIT)&0x1 == 0);
    // Dato leído.
    int read_data = Xil_In32(_address + READ_REG) & 0xFF;
    // Retornar el dato de 16 bits.
    return read_data;
}

// Este método transmite un array de datos.
int *SPI::transfer(int *buffer, int size)
{
    // Definición del registro de salida.
    int *buffer_salida;
    // Ejecución en bucle de la transmisión y recepción.
    for (int i = 0; i < size; i++)
    {
        // Formatear el registro de escritura.
        Xil_Out32(_address + WRITE_REG, 0);
        // Escribir el valor a transmitir.
        Xil_Out32(_address + WRITE_REG, buffer[i]);
        // Lectura del valor del registro.
        uint32_t reg = Xil_In32(_address + CNTRL_REG);
        // Ejecutar la escritura.
        Xil_Out32(_address + CNTRL_REG, reg | (1 << WRITE8_BIT));
        // Bajar el valor de la escritura.
        Xil_Out32(_address + CNTRL_REG, reg);
        // Esperar a que SPI termine.
        while(((Xil_In32(_address + READ_REG)>>RDY_BIT)&0x1) == 0);
        // Dato leído.
        int read_data = Xil_In32(_address + READ_REG) & 0xFF;
        // Poner en el registro el valor.
        buffer_salida[i] = read_data;
    }
    // Retornar el registro de salida.
    return buffer_salida;
}

// Este método transmite un dato de 16 bits.
uint16_t SPI::transfer16(uint16_t value)
{
    // Formatear el registro de escritura.
    Xil_Out32(_address + WRITE_REG, 0);
    // Asignación del valor a transmitir.
    Xil_Out32(_address + WRITE_REG, value);
    // Lectura del valor del registro.
    uint32_t reg = Xil_In32(_address + CNTRL_REG);
    // Ejecutar la escritura.
    Xil_Out32(_address + CNTRL_REG, reg | (1 << WRITE16_BIT));
    // Bajar el valor de la escritura.
    Xil_Out32(_address + CNTRL_REG, reg);
    // Esperar a que SPI termine.
    while((Xil_In32(_address + READ_REG)>>RDY_BIT)&0x1 == 0);
    // Dato leído.
    uint16_t read_data = Xil_In32(_address + READ_REG) & 0xFFFF;
    // Poner en el registro el valor.
    return read_data;
}
