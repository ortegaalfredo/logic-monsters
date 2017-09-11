# evillogic.github.io
Collection of malicious logic

1. Malproxy: Small hardware that fits between the bus master (usually the CPU) and a slave I.E. an ARM processor and the memory. When the logic see a 56-bit cookie (32 bits+24 bits) it reads a command, data and proceeds to disconnect the CPU and execute the command over the main memory (command can be read/write memory). This allows to embed malicius data in any bus transfer that can be interpreted by this logic outside control of the main CPU. This works mainly on ARM processors as it is compatible with the AHB LITE bus.
Total logic elements: ~140 (Cyclone IV)
Total registers: ~90 (Cyclone IV)
Author: aortega
