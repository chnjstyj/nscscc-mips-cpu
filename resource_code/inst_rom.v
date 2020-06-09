module inst_rom(                 //指令寄存器
    input clk,
    input rom_clk,
    input [31:0] inst_address,
    input ce,
    input [15:0] rdata_a,
    input [15:0] rdata_b,
    output [31:0] rom_addr,
    output rom_ce,
    output we,
    output oe,
    output reg [31:0] inst 
);

reg [31:0] inst_rom[0:1023];      //4kb的reg
reg read_ce;
reg [31:0] address;
always @(*) address <= {20'h00000,inst_address[11:2],2'b00};

wire [15:0] data_a;
wire [15:0] data_b;
wire rfin;

//initial $readmemh( "F:\inst_rom.data", inst_rom );

/*
always @(*) begin
    if(ce == 1'b0) begin 
        inst <= 32'h00000000;
    end 
    else begin 
        inst <= inst_rom[inst_address[11:2]];
    end 
end */

//读内存
always @(*) begin 
    if(ce == 1'b0) begin
        inst <= 32'h00000000;
        read_ce <= 1'b0;
    end 
    else begin 
        read_ce <= 1'b1;
        if(rfin) inst <= {data_b,data_a};
        else inst <= inst;
    end
end
/*
mips 按字节寻址，所以指令地址要/2，最后两位不取。
且log2(1024) = 10,所以只取前10位。
*/
irom_read irom_read_a(
    .clk(rom_clk),
    .rst(rst),
    .read_ce(read_ce),
    .address(address),
    .dout(rdata_a),
    .data(data_a),
    .rfin(rfin),
    .ce(rom_ce),
    .we(we),
    .oe(oe)
);

irom_read irom_read_b(
    .clk(rom_clk),
    .rst(rst),
    .read_ce(read_ce),
    .address(address),
    .dout(rdata_b),
    .data(data_b),
    .rfin(rfin),
    .ce(rom_ce),
    .we(we),
    .oe(oe)
);

endmodule  