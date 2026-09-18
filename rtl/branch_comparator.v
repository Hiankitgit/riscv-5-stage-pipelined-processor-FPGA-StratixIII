// ============================================================================
// MODULE 5: BRANCH COMPARATOR
// ============================================================================
module branch_comparator(
    input  [31:0] a,
    input  [31:0] b,
    input  [2:0]  branch_type,
    output reg    branch_taken
);
    always @(*) begin
        case (branch_type)
            3'b000: branch_taken = (a == b);                   
            3'b001: branch_taken = (a != b);                   
            3'b100: branch_taken = ($signed(a) < $signed(b));  
            3'b101: branch_taken = ($signed(a) >= $signed(b)); 
            3'b110: branch_taken = (a < b);                    
            3'b111: branch_taken = (a >= b);                   
            default: branch_taken = 1'b0;
        endcase
    end
endmodule
