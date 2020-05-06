module alu_control(
    input [5:0] func,
    input [1:0] ALUOp,
    output [3:0] reg alu_control
);

always @(*) begin 
    case(func) begin 
        31:alu_control <= 2;
        34:alu_control <= 6;
        36:alu_control <= 0;
        37:alu_control <= 1;
        39:alu_control <= 12;
        42:alu_control <= 7;
        default:alu_control <= 15;           //²»´æÔÚ
        end
    endcase
end 


endmodule 
