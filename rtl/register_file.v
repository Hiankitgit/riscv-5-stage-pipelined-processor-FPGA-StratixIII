// ============================================================================
// MODULE 3: REGISTER FILE (With Internal Bypass)
// ============================================================================
module register_file(
    input         clk,
    input         rst,
    input  [4:0]  read_reg1,
    input  [4:0]  read_reg2,
    output [31:0] read_data1,
    output [31:0] read_data2,
    input         reg_write,
    input  [4:0]  write_reg,
    input  [31:0] write_data
);
    reg [31:0] registers [31:0];
    integer i;
 
    assign read_data1 = (read_reg1 == 5'b0) ? 32'b0 : 
                        (reg_write && write_reg == read_reg1) ? write_data : 
                        registers[read_reg1];
 
    assign read_data2 = (read_reg2 == 5'b0) ? 32'b0 : 
                        (reg_write && write_reg == read_reg2) ? write_data : 
                        registers[read_reg2];
 
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) registers[i] <= 32'b0;
        end
        else if (reg_write && write_reg != 5'b0)
            registers[write_reg] <= write_data;
    end
endmodule
