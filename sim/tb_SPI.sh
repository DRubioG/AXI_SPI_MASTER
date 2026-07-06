# code
nvc -a ../ip/AXI_SPI_1_0/src/edge_detector.vhd
nvc -a ../ip/AXI_SPI_1_0/src/SPI.vhd

# testbench
nvc -a ../testbench/tb_SPI.vhd

# elaborate
nvc -e SPI_tb

# simulate
nvc -r SPI_tb --stop-time=100us --wave=tb_SPI.vcd