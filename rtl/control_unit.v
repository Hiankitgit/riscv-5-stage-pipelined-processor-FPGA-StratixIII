// ============================================================================
// MODULE 6: CONTROL UNIT
// ============================================================================
module control_unit(
    input  [6:0] opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg       reg_write,
    output reg [1:0] alu_src_A, 
    output reg       alu_src_B, 
    output reg       mem_read,
    output reg       mem_write,
    output reg [1:0] wb_sel,    
    output reg       branch,
    output reg       jump,
    output reg       jump_reg,  
    output reg [3:0] alu_op
);
    always @(*) begin
        reg_write = 1'b0; alu_src_A = 2'b00; alu_src_B = 1'b0;
        mem_read  = 1'b0; mem_write = 1'b0;  wb_sel    = 2'b00;
        branch    = 1'b0; jump      = 1'b0;  jump_reg  = 1'b0;
        alu_op    = 4'b0000;
 
        case (opcode)
            7'b0110011: begin // R-TYPE
                reg_write = 1'b1; alu_src_A = 2'b00; alu_src_B = 1'b0; wb_sel = 2'b00;
                case (funct3)
                    3'b000: alu_op = (funct7 == 7'b0100000) ? 4'b0110 : 4'b0010; 
                    3'b001: alu_op = 4'b1010; 
                    3'b010: alu_op = 4'b0111; 
                    3'b011: alu_op = 4'b1000; 
                    3'b100: alu_op = 4'b1001; 
                    3'b101: alu_op = (funct7 == 7'b0100000) ? 4'b1100 : 4'b1011; 
                    3'b110: alu_op = 4'b0001; 
                    3'b111: alu_op = 4'b0000; 
                endcase
            end
            7'b0010011: begin // I-TYPE
                reg_write = 1'b1; alu_src_A = 2'b00; alu_src_B = 1'b1; wb_sel = 2'b00;
                case (funct3)
                    3'b000: alu_op = 4'b0010; 
                    3'b001: alu_op = 4'b1010; 
                    3'b010: alu_op = 4'b0111; 
                    3'b011: alu_op = 4'b1000; 
                    3'b100: alu_op = 4'b1001; 
                    3'b101: alu_op = (funct7 == 7'b0100000) ? 4'b1100 : 4'b1011; 
                    3'b110: alu_op = 4'b0001; 
                    3'b111: alu_op = 4'b0000; 
                endcase
            end
            7'b0000011: begin // L-TYPE 
                reg_write = 1'b1; alu_src_A = 2'b00; alu_src_B = 1'b1; wb_sel = 2'b01;
                mem_read = 1'b1; alu_op = 4'b0010; 
            end
            7'b0100011: begin // S-TYPE 
                alu_src_A = 2'b00; alu_src_B = 1'b1; mem_write = 1'b1;
                alu_op = 4'b0010; 
            end
            7'b1100011: begin // B-TYPE 
                branch = 1'b1; alu_src_A = 2'b00; alu_src_B = 1'b0;
            end
            7'b1101111: begin // JAL
                reg_write = 1'b1; jump = 1'b1; wb_sel = 2'b10; 
            end
            7'b1100111: begin // JALR
                reg_write = 1'b1; jump = 1'b1; jump_reg = 1'b1; wb_sel = 2'b10; 
            end
            7'b0110111: begin // LUI
                reg_write = 1'b1; alu_src_A = 2'b10; alu_src_B = 1'b1; wb_sel = 2'b00; 
                alu_op = 4'b1111; 
            end
            7'b0010111: begin // AUIPC
                reg_write = 1'b1; alu_src_A = 2'b01; alu_src_B = 1'b1; wb_sel = 2'b00;
                alu_op = 4'b0010; 
            end
        endcase
    end
endmodule
