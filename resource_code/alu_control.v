module alu_control(
    input [5:0] func,
    input [2:0] ALUOp,
    output reg [3:0]  alu_control
);

always @(*) begin 
    case(ALUOp) 
        3'b000:alu_control <= 4'b0010;      //+
        3'b001:alu_control <= 4'b0110;      //-
        3'b011:alu_control <= 4'b0001;         //or
        3'b100:alu_control <= 4'b0000;         //and
        3'b101:alu_control <= 4'b0111;     //小于则置位
        3'b110:alu_control <= 4'b1100;    //或非
        3'b010: begin                     //R-type
            case(func) 
                31:alu_control <= 2;
                34:alu_control <= 6;
                36:alu_control <= 0;
                37:alu_control <= 1;
                39:alu_control <= 12;
                42:alu_control <= 7;
                default:alu_control <= 15;           //²»´æÔÚ
            endcase
        end
        default:alu_control <= 15;
    endcase
end 


endmodule 
