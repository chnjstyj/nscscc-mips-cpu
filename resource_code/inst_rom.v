module inst_rom(                 //指令寄存器
    (* dont_touch = "1" *)input clk,
    //input rom_clk,
    (* dont_touch = "1" *)input [31:0] inst_address,
    input ce,
    output wire read_ce,
    output [31:0] irom_addr,
    (* dont_touch = "1" *)input [31:0] rom_inst,
    input rfin_c,
    (* dont_touch = "1" *)output reg [31:0] inst 
);
assign irom_addr = {5'b00000,inst_address[28:2]};
reg flag;

//wire [15:0] data_a;
//wire [15:0] data_b;
//wire rfin;

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
assign read_ce = (ce == 1'b1)?1'b1:1'b0;
always @(inst_address or ce) begin
     if(ce == 1'b0) flag <= 1'b0;
     else flag = ~flag;
end
always @(*) begin 
    if(ce == 1'b0) begin
        inst <= 32'h00000000;
    end 
    else if(rfin_c) begin 
       inst <= rom_inst;
    end
    else inst <= inst;
end
/*
mips 按字节寻址，所以指令地址要/2，最后两位不取。
且log2(1024) = 10,所以只取前10位。
*/
endmodule  