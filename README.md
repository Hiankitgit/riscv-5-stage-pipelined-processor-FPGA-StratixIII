RISC-V 5-Stage Pipelined Soft-Core Processor

A custom 32-bit RISC-V (RV32I) soft-core microprocessor featuring a classic 5-stage pipeline, hardware-level hazard management, a custom bare-metal toolchain, and physical hardware deployment on an Altera Stratix III FPGA.

🚀 Key Architectural Features

5-Stage Pipeline: Fully decoupled Fetch, Decode, Execute, Memory, and Write-Back stages enabled by dedicated pipeline registers.

Hazard & Forwarding Units: Built-in Data Forwarding to eliminate Read-After-Write (RAW) stalls and a Hazard Detection Unit to manage Load-Use data hazards.

Branch Optimization: A dedicated branch comparator operating in the Execute stage to evaluate branch conditions in parallel with ALU operations.

Memory-Mapped I/O (MMIO): Maps memory address 0x2000 directly to physical board peripherals (Active-Low LEDs) for real-time debugging and status visualization.

On-Chip BRAM Integration: Utilizes Altera's altsyncram block RAM for zero-latency instruction ROM and data RAM execution at 50 MHz.

🛠️ Tech Stack & Tools

HDL Language: Verilog (IEEE 1364-2001)

FPGA Target: Altera Stratix III (EP3SL150)

Synthesis & Timing: Intel Quartus Prime & TimeQuest Timing Analyzer

Simulation: ModelSim (RTL waveform verification)

Toolchain: GCC Bare-Metal Cross-Compiler & Python/PowerShell MIF Parsers

⚙️ Compilation & Simulation Workflow

Compile Software: Compile your bare-metal C or assembly program using a RISC-V GCC toolchain to generate raw instruction memory (instruction.mem).

Generate MIF: Run the parser script to format the code for FPGA block RAM:

python mem2mif.py


Simulate (ModelSim): Open ModelSim, load the testbench, and observe waveform behavior across pipeline registers and clock cycles.

Synthesize & Flash (Quartus): Compile the project targeting the Stratix III FPGA and program the board via JTAG.
