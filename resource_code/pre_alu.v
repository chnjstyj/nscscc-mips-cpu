module pre_alu(
    input [31:0] ex_rdata_a,
    input [31:0] ex_rdata_b,
    input [31:0] mem_wb_dout,
    input control_rdata_a,
    input control_rdata_b,
    output wire [31:0] rdata_a,
    output wire [31:0] rdata_b
);

assign rdata_a = (control_rdata_a == 1'b1)?mem_wb_dout:ex_rdata_a;
assign rdata_b = (control_rdata_b == 1'b1)?mem_wb_dout:ex_rdata_b;

endmodule 