# code
nvc -a ../code/src/edge_detector.vhd
nvc -a ../code/src/SPI.vhd

# testbench
nvc -a ../code/testbench/tb_SPI.vhd

# elaborate
nvc -e SPI_tb

# simulate
nvc -r SPI_tb --stop-time=100us --wave=tb_SPI.vcd