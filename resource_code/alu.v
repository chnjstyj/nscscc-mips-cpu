module alu(
    input [31:0] data_a,
    input [31:0] data_b,
    input [15:0] imme,
    input ALUSrc,
    input [3:0] alu_control,
    input [4:0] shamt,
    output reg [31:0] alu_result                     
);

wire [31:0] zero_extimm;
wire [31:0] sign_extimm;
reg [31:0] real_imme;

assign zero_extimm = {{16{1'b0}},imme};
assign sign_extimm = {{16{imme[15]}},imme};

wire [31:0] real_data_b;

wire [31:0] add_result;
wire [31:0] sub_result;
wire [31:0] and_result;
wire [31:0] or_result;
wire [31:0] lessthan_result;
wire [31:0] xor_result;
wire [31:0] sll_result;
wire [31:0] srl_result;
wire [31:0] mul_result;

assign add_result = data_a + real_data_b;
assign sub_result = data_a - real_data_b;
assign and_result = data_a & real_data_b;
assign or_result = data_a | real_data_b;
assign lessthan_result = (data_a < real_data_b?32'b1:32'b0);
assign xor_result = data_a ^ real_data_b;
assign sll_result = real_data_b << shamt;
assign srl_result = real_data_b >> shamt;

mul u_mul(
.A(data_a),
.B(real_data_b),
.P(mul_result)
);

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
        4'b1111:alu_result <= mul_result;
        default:alu_result <= 32'h00000000;
    endcase
end

always @(*) begin
    if (alu_control == 4'b0000 || alu_control == 4'b0001 || alu_control == 4'b1100) begin 
        real_imme <= zero_extimm;
    end
    else real_imme <= sign_extimm;
end
assign real_data_b = (ALUSrc == 1'b1)?real_imme:data_b;

endmodule