module mem(
    input clk,
    input [31:0] alu_result,
    input [31:0] din,
    input MemWrite,
    input MemRead,
    input MemtoReg,
    output [31:0] dout
);

reg [31:0] mems[0:1023];
reg [31:0] data_out;

//读数据
always @(*) begin
    if(MemRead) 
        data_out <= mems[alu_result[9:0]];                  //取低10位 因为log1024/log2 = 10  
    else
        data_out <= 32'h00000000;
end

//写数据     在时钟上升沿
always @(posedge clk) begin
    if (MemWrite)
        mems[alu_result[9:0]] <= din;
    else 
        mems[alu_result[9:0]] <= mems[alu_result[9:0]];
end

//决定哪个数据写回寄存器堆
assign dout = (MemtoReg == 1'b1)?data_out:ALU_result;


endmodule 