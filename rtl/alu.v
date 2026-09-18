// ============================================================================
// MODULE 4: ALU
// ============================================================================
module alu(
    input  [31:0] src1,
    input  [31:0] src2,
    input  [3:0]  alu_op,
    output reg [31:0] result
);
    always @(*) begin
        result = 32'b0;
        case (alu_op)
            4'b0000: result = src1 & src2;                   
            4'b0001: result = src1 | src2;                   
            4'b0010: result = src1 + src2;                   
            4'b0110: result = src1 - src2;                   
            4'b0111: result = ($signed(src1) < $signed(src2)) ? 32'b1 : 32'b0; 
            4'b1000: result = (src1 < src2) ? 32'b1 : 32'b0; 
            4'b1001: result = src1 ^ src2;                   
            4'b1010: result = src1 << src2[4:0];             
            4'b1011: result = src1 >> src2[4:0];             
            4'b1100: result = $signed(src1) >>> src2[4:0];   
            4'b1111: result = src2;                          
            default: result = 32'b0;
        endcase
    end
endmodule

  
