module alu(
    input [31:0] data_a,
    input [31:0] data_b,
    input [31:0] imme,
    input ALUSrc,
    input [3:0] alu_control,
    //input unsigned_num,
    //input equal_branch,
    input [4:0] shamt,
    //input greater_than,
    //output reg zero_sig
    output reg [31:0] alu_result
    //output reg bgtz_sig                       //bgtz ĞÅºÅÏß
);

wire [31:0] real_data_b;
//?????¨¢??
wire [31:0] add_result;
wire [31:0] sub_result;
wire [31:0] and_result;
wire [31:0] or_result;
wire [31:0] lessthan_result;
wire [31:0] xor_result;
wire [31:0] sll_result;
wire [31:0] srl_result;

assign add_result = data_a + real_data_b;
assign sub_result = data_a - real_data_b;
assign and_result = data_a & real_data_b;
assign or_result = data_a | real_data_b;
assign lessthan_result = (data_a < real_data_b?32'b1:32'b0);
assign xor_result = ~(data_a | real_data_b);
assign sll_result = real_data_b << shamt;
assign srl_result = real_data_b >>> shamt;


always @(*) begin 
    case (alu_control)
        4'b0010:alu_result <= add_result;
        4'b0110:alu_result <= sub_result;
        4'b0000:alu_result <= and_result;
        4'b0001:alu_result <= or_result;
        4'b0111:alu_result <= lessthan_result;
        4'b1100:alu_result <= xor_result;        //xor
        4'b1101:alu_result <= sll_result;
        4'b1110:alu_result <= srl_result;
        default:alu_result <= 32'h00000000;
    endcase
end

assign real_data_b = (ALUSrc == 1'b1)?imme:data_b;                  

/*always @(*) begin
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
end*/

/*always @(*) begin 
    if (greater_than && alu_result[31] != 1'b1)
        bgtz_sig <= 1'b1;
    else bgtz_sig <= 1'b0;
end*/

endmodule