# RISC-V 5-Stage Pipelined Soft-Core Processor

A custom 32-bit RISC-V (`RV32I`) soft-core microprocessor featuring a classic 5-stage pipeline, hardware-level hazard management, a custom bare-metal C toolchain, and physical hardware deployment on an Altera Stratix III FPGA.

---

## 🚀 Key Architectural Features

* **5-Stage Pipeline:** Fully decoupled Fetch, Decode, Execute, Memory, and Write-Back stages enabled by dedicated pipeline registers.
* **Hazard & Forwarding Units:** Built-in Data Forwarding to eliminate Read-After-Write (RAW) data stalls and a Hazard Detection Unit to manage Load-Use hazards.
* **Branch Optimization:** A dedicated branch comparator operating in the Execute stage to evaluate branch conditions in parallel with ALU execution.
* **Memory-Mapped I/O (MMIO):** Maps memory address `0x2000` directly to physical board peripherals (Active-Low LEDs) for real-time debugging and status visualization.
* **On-Chip BRAM Integration:** Utilizes Altera's `altsyncram` block RAM for zero-latency instruction ROM and data RAM execution at 50 MHz.

---

## 🛠️ Tech Stack & Development Environment

* **HDL Language:** Verilog (IEEE 1364-2001)
* **FPGA Target:** Altera Stratix III (`EP3SL150`)
* **Synthesis & Timing Engine:** Intel Quartus Prime & TimeQuest Timing Analyzer
* **Simulation Environment:** ModelSim (RTL waveform verification via NativeLink)
* **Software Toolchain:** RISC-V GCC Bare-Metal Cross-Compiler (`riscv64-unknown-elf-gcc`)
* **Parsing Utilities:** Python 3 (`mem2mif.py`) / PowerShell (`mem2mif.ps1`)

---

## 📥 Toolchain Compiler Setup (Prerequisite)

To compile C software into raw machine instructions for this processor, you need the bare-metal GCC cross-compiler. 

### Recommended Distribution: xPack GNU RISC-V Embedded GCC
1. Navigate to the official releases page: [xPack GNU RISC-V Embedded GCC Releases](https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases) *(or the standard GNU toolchain build)*.
2. **Which file to download?** Look for the asset matching your host operating system:
   * **Windows:** Download `xpack-riscv-none-elf-gcc-x-windows-x64.zip` (~**300–400 MB**).
   * **Linux:** Download `xpack-riscv-none-elf-gcc-x-linux-x64.tar.gz` (~**250–350 MB**).
   * **macOS:** Download `xpack-riscv-none-elf-gcc-x-darwin-x64.tar.gz` (~**250–300 MB**).
3. Extract the archive and add its `bin/` directory to your system's `PATH` environment variable so you can invoke `riscv64-unknown-elf-gcc` from your terminal.

---

## 📂 Repository File Structure & Placement Guide

Where each file belongs in your repository:

```text
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
```

---

## ⚙️ Complete Step-by-Step Workflow

To understand and replicate the compilation-to-silicon pipeline, follow this strict sequence:

### Step 1: Write and Compile Software (`main.c`)
Write your bare-metal C code in `software/main.c`. Use the RISC-V GCC cross-compiler to compile the source code into raw machine instructions:
```bash
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -Ttext=0x0 software/main.c -o firmware.elf
riscv64-unknown-elf-objcopy -O verilog firmware.elf instruction.mem
```
> *Note:* The compiler outputs `instruction.mem`, which contains raw hex machine code alongside memory address markers (e.g., `@00000000`). Place this file in your project root or parsing directory.

### Step 2: Parse to Memory Initialization File (`instruction.mif`)
Because Quartus Block RAM requires a specific initialization format, run the parsing script to strip out metadata and format the code:
* **Using Python:**
  ```bash
  python tools/mem2mif.py
  ```
* **Using PowerShell:**
  ```powershell
  .\tools\mem2mif.ps1
  ```
* This script reads `instruction.mem`, cleans the headers, formats it into a 32-bit wide by 1024-depth array, pads unused spaces with NOP instructions (`00000013`), and generates `instruction.mif` for the ROM block.

### Step 3: Simulate Waveform Behavior (ModelSim)
1. Open ModelSim and load your testbench module (`tb_stratix` inside `rtl/top_riscv.v`).
2. Link the Altera simulation libraries (`altera_mf_ver`) to support the `altsyncram` block RAM macro.
3. Run the simulation to observe instruction flow across pipeline registers and verify cycle-accurate execution.

### Step 4: Synthesize, Constrain, and Flash (Quartus Prime)
1. Create a new Quartus project targeting your Stratix III (`EP3SL150`) FPGA.
2. Add `rtl/top_riscv.v` as your top-level design file.
3. Import your pin mapping script into Quartus via the Tcl Console:
   ```tcl
   source tcl/quartus_pins.tcl
   ```
4. Add your timing constraints file (`constraints/riscv.sdc`) to enforce the 20ns (50 MHz) clock constraint using TimeQuest.
5. Compile the design, connect your board via USB-Blaster (JTAG), and program the `.sof` file onto the FPGA.
