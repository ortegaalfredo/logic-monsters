# https://ortegaalfredo.github.io/logic-monsters/

Collection of malicious logic

Site at: https://ortegaalfredo.github.io/logic-monsters/

1. Malproxy: Small hardware that fits between the bus master (usually the CPU) and a slave I.E. an ARM processor and the memory. When the logic see a 56-bit cookie (32 bits+24 bits) it reads a command, data and proceeds to disconnect the CPU and execute the command over the main memory (command can be read/write memory). This allows to embed malicious data in any bus transfer that can be interpreted by this logic outside control of the main CPU. This works mainly on ARM processors as it is compatible with the AHB LITE bus.
Total logic elements: ~140 (Cyclone IV)
Total registers: ~90 (Cyclone IV)

2. Sorath: Tiny state-machine that recognizes a 64-bit magic number in a 32-bit bus and activates a flag. When the logic see the cookie (32 bits+32 bits) it enables a single-bit register. This can be attached to a privilege register, so it elevates privileges when the magic-number is seen. "The mystery of Sorath and his number 666 holds the secret of black magic."
Total logic elements: ~17 (Cyclone IV)
Total registers: ~2 (Cyclone IV)

3. CrashProcessUnit: Small CPU-like state-machine that when parsed by Icarus Verilog v11-20200724 or older, causes a stack-based buffer overflow. This particular example demonstrates code execution on win32.

