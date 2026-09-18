// ============================================================================
// MODULE 8: FORWARDING & HAZARD UNITS
// ============================================================================
module forwarding_unit(
    input  [4:0] IDEX_rs1, input  [4:0] IDEX_rs2,
    input  [4:0] EXMEM_rd, input        EXMEM_reg_write,
    input  [4:0] MEMWB_rd, input        MEMWB_reg_write,
    output reg [1:0] forward_A, output reg [1:0] forward_B
);
    always @(*) begin
        forward_A = 2'b00; forward_B = 2'b00;
        if (EXMEM_reg_write && (EXMEM_rd != 5'b0) && (EXMEM_rd == IDEX_rs1)) forward_A = 2'b10;
        else if (MEMWB_reg_write && (MEMWB_rd != 5'b0) && (MEMWB_rd == IDEX_rs1)) forward_A = 2'b01;
 
        if (EXMEM_reg_write && (EXMEM_rd != 5'b0) && (EXMEM_rd == IDEX_rs2)) forward_B = 2'b10;
        else if (MEMWB_reg_write && (MEMWB_rd != 5'b0) && (MEMWB_rd == IDEX_rs2)) forward_B = 2'b01;
    end
endmodule
 
module hazard_detection_unit(
    input        IDEX_mem_read, input  [4:0] IDEX_rd,
    input  [4:0] IFID_rs1,      input  [4:0] IFID_rs2,
    output reg   stall
);
    always @(*) begin
        stall = 1'b0;
        if (IDEX_mem_read && ((IDEX_rd == IFID_rs1) || (IDEX_rd == IFID_rs2))) stall = 1'b1;
    end
endmodule
