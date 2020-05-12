module alu(
    input [31:0] data_a,
    input [31:0] data_b,
    input [31:0] imme,
    input ALUSrc,
    input [3:0] alu_control,
    input unsigned_num,
    input equal_branch,
    output reg zero_sig,
    output reg [31:0] alu_result
);

wire [31:0] real_data_b;

always @(alu_control or data_a or data_b) begin 
    case (alu_control)
        4'b0010:alu_result <= data_a + real_data_b;
        4'b0110:alu_result <= data_a - real_data_b;
        4'b0000:alu_result <= data_a & real_data_b;
        4'b0001:alu_result <= data_a | real_data_b;
        4'b0111:alu_result <= data_a < real_data_b?1:0;
        4'b1100:alu_result <= ~(data_a | real_data_b);        //??
        default:alu_result <= 32'h00000000;
    endcase
end

assign real_data_b = (ALUSrc == 1'b1)?imme:data_b;                  //?????????????????

always @(*) begin
    if(equal_branch) begin  
        if(alu_result == 32'h00000000)
            zero_sig <= 1'b1;
        else
            zero_sig <= 1'b0;
    end
    else begin
        if(alu_result == 32'h00000000)
            zero_sig <= 1'b0;
        else
            zero_sig <= 1'b1;
    end 
end

endmodule