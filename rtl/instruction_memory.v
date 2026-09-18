// ============================================================================
// MODULE 1: INSTRUCTION MEMORY (QUARTUS ROM)
// ============================================================================
module instruction_memory(
    input         clk,
    input  [31:0] pc,
    output [31:0] instruction_code
);
    
    wire [29:0] word_addr = pc[31:2];
 
    altsyncram #(
        .operation_mode("ROM"),
        .width_a(32),
        .widthad_a(10),
        .numwords_a(1024),
        .outdata_reg_a("UNREGISTERED"),
        .address_aclr_a("NONE"),
        .outdata_aclr_a("NONE"),
        .init_file("instruction.mif"),
        .lpm_hint("ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=iROM")
    ) rom_inst (
        .clock0(~clk), 
        .address_a(word_addr[9:0]),
        .q_a(instruction_code)
    );
endmodule
