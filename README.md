RISC-V 5-Stage Pipelined Soft-Core Processor

A custom 32-bit RISC-V (RV32I) soft-core microprocessor featuring a classic 5-stage pipeline, hardware-level hazard management, a custom bare-metal toolchain, and physical hardware deployment on an Altera Stratix III FPGA.

🚀 Key Architectural Features

5-Stage Pipeline: Fully decoupled Fetch, Decode, Execute, Memory, and Write-Back stages enabled by dedicated pipeline registers.

Hazard & Forwarding Units: Built-in Data Forwarding to eliminate Read-After-Write (RAW) stalls and a Hazard Detection Unit to manage Load-Use data hazards.

Branch Optimization: A dedicated branch comparator operating in the Execute stage to evaluate branch conditions in parallel with ALU operations.

Memory-Mapped I/O (MMIO): Maps memory address 0x2000 directly to physical board peripherals (Active-Low LEDs) for real-time debugging and status visualization.

On-Chip BRAM Integration: Utilizes Altera's altsyncram block RAM for zero-latency instruction ROM and data RAM execution at 50 MHz.

🛠️ Tech Stack & Development Environment

HDL Language: Verilog (IEEE 1364-2001)

FPGA Target: Altera Stratix III (EP3SL150)

Synthesis & Timing Engine: Intel Quartus Prime & TimeQuest Timing Analyzer

Simulation Environment: ModelSim (RTL waveform verification via NativeLink)

Software Toolchain: RISC-V GCC Bare-Metal Cross-Compiler (riscv64-unknown-elf-gcc)

Parsing Utilities: Python 3 (mem2mif.py) / PowerShell (mem2mif.ps1)

📂 Repository File Structure & Placement Guide

Where each file belongs in your repository:

riscv-5-stage-processor/
│
├── rtl/
│   └── top_riscv.v             # Complete top-level hardware pipeline and sub-modules
│
├── software/
│   └── main.c                  # Bare-metal C program (Sorting benchmark / custom logic)
│
├── tools/
│   ├── mem2mif.py              # Python parser script to convert .mem to Quartus .mif
│   └── mem2mif.ps1             # PowerShell utility script for Windows environments
│
├── constraints/
│   └── riscv.sdc               # Synopsys Design Constraints file (50 MHz clock definition)
│
├── tcl/
│   └── quartus_pins.tcl        # Pin assignments script for FPGA board mapping
│
├── README.md                   # Project documentation
└── .gitignore                  # Git exclusion rules for build/simulation artifacts


⚙️ Complete Step-by-Step Workflow

To help you understand and replicate the compilation-to-silicon pipeline, follow this strict sequence:

Step 1: Write and Compile Software (main.c)

Write your bare-metal C code in software/main.c. Use a RISC-V GCC cross-compiler to compile the source code into raw machine instructions:

riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -Ttext=0x0 software/main.c -o firmware.elf
riscv64-unknown-elf-objcopy -O verilog firmware.elf instruction.mem


Note: The compiler outputs instruction.mem, which contains raw hex machine code alongside memory address markers (e.g., @00000000).

Step 2: Parse to Memory Initialization File (instruction.mif)

Because Quartus Block RAM requires a specific initialization format, run the parsing script to strip out metadata and format the code:

Using Python:

python tools/mem2mif.py


Using PowerShell:

.\tools\mem2mif.ps1


This script reads instruction.mem, cleans the headers, formats it into a 32-bit wide by 1024-depth array, pads unused spaces with NOP instructions (00000013), and generates instruction.mif.

Step 3: Simulate Waveform Behavior (ModelSim)

Open ModelSim and load your testbench module (tb_stratix inside top_riscv.v).

Link the Altera simulation libraries (altera_mf_ver) to support the altsyncram block RAM macro.

Run the simulation to observe instruction flow across pipeline registers and verify cycle-accurate execution.

Step 4: Synthesize, Constrain, and Flash (Quartus Prime)

Create a new Quartus project targeting your Stratix III (EP3SL150) FPGA.

Add rtl/top_riscv.v as your top-level design file.

Import your pin mapping script into Quartus:

source tcl/quartus_pins.tcl


Add your timing constraints file (constraints/riscv.sdc) to enforce the 20ns (50 MHz) clock constraint using TimeQuest.

Compile the design, connect your board via USB-Blaster (JTAG), and program the .sof file onto the FPGA.
