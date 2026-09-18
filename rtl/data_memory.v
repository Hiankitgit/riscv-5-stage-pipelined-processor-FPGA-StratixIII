// ============================================================================
// MODULE 2: DATA MEMORY (QUARTUS RAM)
// ============================================================================
module data_memory(
    input         clk,
    input         mem_write,
    input         mem_read,
    input  [31:0] addr,
    input  [31:0] write_data,
    output [31:0] read_data
);
    reg [31:0] memory [0:1023]; // 4KB
    wire [29:0] word_addr = addr[31:2];
 
    assign read_data = (mem_read) ? memory[word_addr] : 32'b0;
 
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) memory[i] = 32'b0;
    end
 
    always @(posedge clk) begin
        if (mem_write) memory[word_addr] <= write_data;
    end
endmodule
