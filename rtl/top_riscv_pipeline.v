// ============================================================================
// MODULE 9: PHYSICAL STRATIX III TOP LEVEL
// ============================================================================
module top_riscv_pipeline(
    input        clk_50mhz,   
    input        cpu_reset_n, 
    output reg [7:0] user_led     
);
 
    wire clk = clk_50mhz;
    wire reset = ~cpu_reset_n; // Invert active low
 
    // THE VIP LOUNGE (Consolidated Pipeline Register Declarations)
    wire stall; wire pc_override; wire [31:0] pc_target; wire [31:0] instr_IF;
    wire [6:0] opcode_ID; wire [2:0] funct3_ID; wire [4:0] rs1_ID, rs2_ID, rd_ID;
    wire [31:0] read_data1_ID, read_data2_ID, imm_ID;
    wire reg_write_ID, alu_src_B_ID, mem_read_ID, mem_write_ID;
    wire branch_ID, jump_ID, jump_reg_ID;
    wire [1:0] alu_src_A_ID, wb_sel_ID; wire [3:0] alu_op_ID;
    wire [1:0] forward_A, forward_B; wire [31:0] alu_src1, alu_src2, alu_result_EX;
    wire branch_condition; wire [31:0] mem_read_data; wire [31:0] MEMWB_write_data;
 
    reg [31:0] PC; wire [31:0] PC_plus4 = PC + 4;
    reg [31:0] IFID_PC, IFID_PC_plus4, IFID_instr;
 
    reg [31:0] IDEX_PC, IDEX_PC_plus4, IDEX_read_data1, IDEX_read_data2, IDEX_imm;
    reg [4:0]  IDEX_rs1, IDEX_rs2, IDEX_rd; reg [2:0] IDEX_funct3; reg [3:0] IDEX_alu_op;
    reg [1:0]  IDEX_alu_src_A, IDEX_wb_sel; reg IDEX_reg_write, IDEX_alu_src_B, IDEX_mem_read, IDEX_mem_write;
    reg        IDEX_branch, IDEX_jump, IDEX_jump_reg;
 
    reg [31:0] EXMEM_alu_result, EXMEM_write_data, EXMEM_PC_plus4;
    reg [4:0]  EXMEM_rd; reg [1:0] EXMEM_wb_sel; reg EXMEM_reg_write, EXMEM_mem_read, EXMEM_mem_write;
    reg [31:0] fwd_src1, fwd_src2;
 
    reg [31:0] MEMWB_alu_result, MEMWB_mem_data, MEMWB_PC_plus4;
    reg [4:0]  MEMWB_rd; reg [1:0] MEMWB_wb_sel; reg MEMWB_reg_write;
 
    // IF STAGE
    always @(posedge clk) begin
        if (reset) PC <= 32'b0;
        else if (!stall) PC <= (pc_override) ? pc_target : PC_plus4;
    end
 
    instruction_memory imem (.clk(clk), .pc(PC), .instruction_code(instr_IF));
 
    always @(posedge clk) begin
        if (reset || pc_override) begin 
            IFID_PC <= 0; IFID_PC_plus4 <= 0; IFID_instr <= 32'h00000013; 
        end
        else if (!stall) begin
            IFID_PC <= PC; IFID_PC_plus4 <= PC_plus4; IFID_instr <= instr_IF;
        end
    end
 
    // ID STAGE
    assign opcode_ID = IFID_instr[6:0]; assign funct3_ID = IFID_instr[14:12];
    assign rs1_ID    = IFID_instr[19:15]; assign rs2_ID    = IFID_instr[24:20]; 
    assign rd_ID     = IFID_instr[11:7];
 
    control_unit cu (
        .opcode(opcode_ID), .funct3(funct3_ID), .funct7(IFID_instr[31:25]),
        .reg_write(reg_write_ID), .alu_src_A(alu_src_A_ID), .alu_src_B(alu_src_B_ID),
        .mem_read(mem_read_ID), .mem_write(mem_write_ID), .wb_sel(wb_sel_ID),
        .branch(branch_ID), .jump(jump_ID), .jump_reg(jump_reg_ID), .alu_op(alu_op_ID)
    );
 
    register_file rf (
        .clk(clk), .rst(reset), .read_reg1(rs1_ID), .read_reg2(rs2_ID),
        .read_data1(read_data1_ID), .read_data2(read_data2_ID),
        .reg_write(MEMWB_reg_write), .write_reg(MEMWB_rd), .write_data(MEMWB_write_data)
    );
 
    imm_gen ig (.instr(IFID_instr), .imm_out(imm_ID));
    hazard_detection_unit hdu (.IDEX_mem_read(IDEX_mem_read), .IDEX_rd(IDEX_rd), .IFID_rs1(rs1_ID), .IFID_rs2(rs2_ID), .stall(stall));
 
    always @(posedge clk) begin
        if (reset || stall || pc_override) begin
            IDEX_PC <= 0; IDEX_PC_plus4 <= 0; IDEX_read_data1 <= 0; IDEX_read_data2 <= 0; IDEX_imm <= 0;
            IDEX_rs1 <= 0; IDEX_rs2 <= 0; IDEX_rd <= 0; IDEX_funct3 <= 0; IDEX_alu_op <= 0;
            IDEX_alu_src_A <= 0; IDEX_wb_sel <= 0; IDEX_reg_write <= 0; IDEX_alu_src_B <= 0; 
            IDEX_mem_read <= 0; IDEX_mem_write <= 0; IDEX_branch <= 0; IDEX_jump <= 0; IDEX_jump_reg <= 0;
        end else begin
            IDEX_PC <= IFID_PC; IDEX_PC_plus4 <= IFID_PC_plus4; 
            IDEX_read_data1 <= read_data1_ID; IDEX_read_data2 <= read_data2_ID; IDEX_imm <= imm_ID;
            IDEX_rs1 <= rs1_ID; IDEX_rs2 <= rs2_ID; IDEX_rd <= rd_ID; IDEX_funct3 <= funct3_ID;
            IDEX_alu_op <= alu_op_ID; IDEX_alu_src_A <= alu_src_A_ID; IDEX_wb_sel <= wb_sel_ID;
            IDEX_reg_write <= reg_write_ID; IDEX_alu_src_B <= alu_src_B_ID; IDEX_mem_read <= mem_read_ID;
            IDEX_mem_write <= mem_write_ID; IDEX_branch <= branch_ID; IDEX_jump <= jump_ID; IDEX_jump_reg <= jump_reg_ID;
        end
    end
 
    // EX STAGE
    forwarding_unit fwd (.IDEX_rs1(IDEX_rs1), .IDEX_rs2(IDEX_rs2), .EXMEM_rd(EXMEM_rd), .EXMEM_reg_write(EXMEM_reg_write),
                         .MEMWB_rd(MEMWB_rd), .MEMWB_reg_write(MEMWB_reg_write), .forward_A(forward_A), .forward_B(forward_B));
 
    always @(*) begin
        case (forward_A)
            2'b10: fwd_src1 = EXMEM_alu_result; 2'b01: fwd_src1 = MEMWB_write_data; default: fwd_src1 = IDEX_read_data1;
        endcase
        case (forward_B)
            2'b10: fwd_src2 = EXMEM_alu_result; 2'b01: fwd_src2 = MEMWB_write_data; default: fwd_src2 = IDEX_read_data2;
        endcase
    end
 
    assign alu_src1 = (IDEX_alu_src_A == 2'b01) ? IDEX_PC : (IDEX_alu_src_A == 2'b10) ? 32'b0 : fwd_src1;
    assign alu_src2 = (IDEX_alu_src_B) ? IDEX_imm : fwd_src2;
 
    alu alu_unit (.src1(alu_src1), .src2(alu_src2), .alu_op(IDEX_alu_op), .result(alu_result_EX));
    branch_comparator bc (.a(fwd_src1), .b(fwd_src2), .branch_type(IDEX_funct3), .branch_taken(branch_condition));
 
    assign pc_override = (IDEX_branch & branch_condition) | IDEX_jump;
    assign pc_target   = (IDEX_jump_reg) ? (fwd_src1 + IDEX_imm) : (IDEX_PC + IDEX_imm);
 
    always @(posedge clk) begin
        if (reset) begin
            EXMEM_alu_result <= 0; EXMEM_write_data <= 0; EXMEM_PC_plus4 <= 0;
            EXMEM_rd <= 0; EXMEM_wb_sel <= 0; EXMEM_reg_write <= 0; EXMEM_mem_read <= 0; EXMEM_mem_write <= 0;
        end else begin
            EXMEM_alu_result <= alu_result_EX; EXMEM_write_data <= fwd_src2; EXMEM_PC_plus4 <= IDEX_PC_plus4; 
            EXMEM_rd <= IDEX_rd; EXMEM_wb_sel <= IDEX_wb_sel; EXMEM_reg_write <= IDEX_reg_write;
            EXMEM_mem_read <= IDEX_mem_read; EXMEM_mem_write <= IDEX_mem_write;
        end
    end
 
    // MEM STAGE
    data_memory dmem (.clk(clk), .mem_write(EXMEM_mem_write), .mem_read(EXMEM_mem_read),
                      .addr(EXMEM_alu_result), .write_data(EXMEM_write_data), .read_data(mem_read_data));
 
    always @(posedge clk) begin
        if (reset) begin
            MEMWB_alu_result <= 0; MEMWB_mem_data <= 0; MEMWB_PC_plus4 <= 0; MEMWB_rd <= 0; MEMWB_wb_sel <= 0; MEMWB_reg_write <= 0;
        end else begin
            MEMWB_alu_result <= EXMEM_alu_result; MEMWB_mem_data <= mem_read_data; MEMWB_PC_plus4 <= EXMEM_PC_plus4;
            MEMWB_rd <= EXMEM_rd; MEMWB_wb_sel <= EXMEM_wb_sel; MEMWB_reg_write <= EXMEM_reg_write;
        end
    end
 
    // WB STAGE
    assign MEMWB_write_data = (MEMWB_wb_sel == 2'b10) ? MEMWB_PC_plus4 : (MEMWB_wb_sel == 2'b01) ? MEMWB_mem_data : MEMWB_alu_result;
 
    // MEMORY-MAPPED I/O
    always @(posedge clk) begin
        if (reset) begin
            user_led <= 8'hFF; 
        end 
        else if (EXMEM_mem_write && EXMEM_alu_result == 32'h00002000) begin
            user_led <= ~EXMEM_write_data[7:0]; 
        end
    end
endmodule
