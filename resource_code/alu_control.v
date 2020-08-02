module alu_control(
    input [5:0] func,
    input [3:0] ALUOp,
    output reg [3:0]  alu_control
);

always @(*) begin 
    case(ALUOp) 
        4'b0000:alu_control <= 4'd2;      //+
        4'b0001:alu_control <= 4'd6;      //-
        4'b0011:alu_control <= 4'd1;         //or
        4'b0100:alu_control <= 4'd0;         //and
        4'b0101:alu_control <= 4'd7;     //小于则置位
        4'b0110:alu_control <= 4'd12;    //或非
        4'b1001:alu_control <= 4'd15;  //乘法
        4'b0010: begin                     //R-type
            case(func) 
                6'd0:alu_control <= 4'd13;
                6'd2:alu_control <= 4'd14;
                6'd32:alu_control <= 4'd2;
                6'd33:alu_control <= 4'd2;
                6'd34:alu_control <= 4'd6;
                6'd36:alu_control <= 4'd0;
                6'd37:alu_control <= 4'd1;
                6'd38:alu_control <= 4'd12;
                6'd39:alu_control <= 4'd12;
                6'd42:alu_control <= 4'd7;
                6'd43:alu_control <= 4'd7;
                default:alu_control <= 4'd3;           
            endcase
        end
        default:alu_control <= 4'd3;
    endcase
end 

endmodule 
