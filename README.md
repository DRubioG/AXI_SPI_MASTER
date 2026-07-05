# AXI_SPI_MASTER
This is an SPI IP block with the Arduino drivers.

## Registers

### CNTRL
![CNTRL](./img/CNTRL.png)

### WRITE
![WRITE](./img/WRITE.png)

## READ
![READ](./img/READ.png)

## Example

### Arduino Example

``` C++
#include <SPI.h>

const int csPin = 10;

void setup() {
  pinMode(csPin, OUTPUT);
  SPI.begin(); 
}

void loop() {
  digitalWrite(csPin, LOW);
  
  int respuesta = SPI.transfer(0xA5); 
  
  digitalWrite(csPin, HIGH);
  
  delay(1000);
}

```

### SPI driver Example

``` C++

#include "xparameters.h"
#include "SPI.h"

#define ADDRESS XPAR_AXI_SPI_0_S_AXI_BASEADDR

SPI SPI(ADDRESS);

int main(){
	  SPI.begin(); 

    while(1){
      // CS -> '0'

	  int respuesta = SPI.transfer(0xA5); 

      // CS -> '1'

      for (int i=0; i < 10000000; i++);
    }
	return 0;
}


```

