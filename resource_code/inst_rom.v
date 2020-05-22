module inst_rom(                 //指令寄存器
    input clk,
    input [31:0] inst_address,
    input ce,
    output reg [31:0] inst 
);

reg [31:0] inst_rom[0:1023];      //4kb的reg

initial $readmemh( "F:\inst_rom.data", inst_rom );

always @(*) begin 
    if(ce == 1'b0) begin
        inst <= 32'h00000000;
    end 
    else begin 
        inst <= inst_reg[inst_address[11:2]];
/*
mips 按字节寻址，所以指令地址要/2，最后两位不取。
且log2(1024) = 10,所以只取前10位。
*/
    end 
end 

endmodule  