module alu_control(
    input [5:0] func,
    input [3:0] ALUOp,
    input [5:0] opcode,
    output reg unsigned_num,
    output reg [3:0]  alu_control
);

always @(*) begin 
    case(ALUOp) 
        4'b0000:alu_control <= 4'b0010;      //+
        4'b0001:alu_control <= 4'b0110;      //-
        4'b0011:alu_control <= 4'b0001;         //or
        4'b0100:alu_control <= 4'b0000;         //and
        4'b0101:alu_control <= 4'b0111;     //小于则置位
        4'b0110:alu_control <= 4'b1100;    //或非
        4'b0010: begin                     //R-type
            case(func) 
                0:alu_control <= 13;
                2:alu_control <= 14;
                31:alu_control <= 2;
                34:alu_control <= 6;
                36:alu_control <= 0;
                37:alu_control <= 1;
                39:alu_control <= 12;
                42:alu_control <= 7;
                43:alu_control <= 7;
                default:alu_control <= 15;           //²»´æÔÚ
            endcase
        end
        default:alu_control <= 15;
    endcase
end 

always @(*) begin   
    case (opcode)
        6'h9:unsigned_num <= 1'b1;
        6'h24:unsigned_num <= 1'b1;
        6'h25:unsigned_num <= 1'b1;
        6'hb:unsigned_num <= 1'b1;
        6'h0:begin
            case (func) 
                6'h21:unsigned_num <= 1'b1;
                6'h2b:unsigned_num <= 1'b1;
                6'h23:unsigned_num <= 1'b1;
            endcase
        end
    default: unsigned_num <= 1'b0;
    endcase
end

endmodule 
