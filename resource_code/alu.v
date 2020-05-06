module alu(
    input [31:0] data_a.
    input [31:0] data_b,
    input ALUSrc,
    input alu_control,
    output zero_sig,
    output [31:0] reg alu_result
);

always @(alu_control or data_a or data_b) begin 
    case (alu_control) begin
        4'b0010:alu_result <= data_a + data_b;
        4'b0110:alu_result <= data_a + data_b;
        4'b0000:alu_result <= data_a & data_b;
        4'b0001:alu_result <= data_a | data_b;
        4'b0111:alu_result <= data_a < data_b?1:0;
        4'b1100:alu_result <= ~(data_a | data_b);        //Òì»ò
        default:alu_result <= 32'h00000000;
    end
    endcase
end

assign zero_sig = alu_result == 32'h00000000?1:0;

endmodule