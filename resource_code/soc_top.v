module soc_top(
    input clk,
    input rst,
    output drom_ce,
    output drom_oe,
    output drom_ew,
    output [31:0] drom_address,
    output [31:0] drom_din,
    input [31:0] drom_dout
    output irom_ce,
    output irom_oe,
    output irom_ew,
    output [31:0] irom_address,
    output [31:0] irom_din,
    input [31:0] irom_dout
    );
    reg reset;
    //wire clk_rom;
    integer i;
    initial i = 0;
    initial uart_clk = 0;
    always @(*) begin
        reset <= 1'b1;
     end
     clk_wiz_0 u_clk_wiz_0(
     .clk_out1(m_clk),
     .clk_out2(clk_rom),
     .reset(reset),
     .clk_in1(clk)
    );
    always @(posedge m_clk) begin 
        if(i <5120) begin 
            i <= i + 1;
        end 
        else begin
            uart_clk = ~uart_clk;
            i <= 0;
        end
     end
     //以上代码中的uart_clk 为104ns，用于串口时钟
     //clk_rom 为2ns，用于内存读写
    wire [31:0] rom_rdata;
    wire [31:0] drom_addr;
    wire dwrite_ce;
    wire [31:0] wdata;
    wire dread_ce;
    wire rfin_a;
    wire rfin_b;
    wire wfin_a;
    wire wfin_b;
    wire iread_ce;
    wire [31:0] irom_addr;
    wire [31:0] rom_inst;
     
    top top(
        .clk(clk),
        .rst(rst),
        //drom
        .rom_rdata(rom_rdata),
        .drom_addr(drom_addr),
        .dwrite_ce(dwrite_ce),
        .wdata(wdata),
        .dread_ce(dread_ce),
        .wfin_a(wfin_a),
        .wfin_b(wfin_b),
        .rfin_a(rfin_a),
        .rfin_b(rfin_b),
        .iread_ce(iread_ce),
        .irom_addr(irom_addr),
        .rom_inst(rom_inst),
        .rfin_c(rfin_c),
        .rfin_d(rfin_d)
    );
rom_write rom_write_a(
    .clk(rom_clk),
    .rst(rst),
    .write_ce(dwrite_ce),
    .wdata(wdata[15:0]),
    .address(drom_addr),
    .dout(drom_dout[15:0]),
    .din(drom_din[15:0]),
    .rom_addr(drom_address),        //给内存的地址
    .wfin(wfin_a),
    .we(drom_we),
    .ce(drom_ce),
    .oe(drom_oe)
);

rom_write rom_write_b(
    .clk(rom_clk),
    .rst(rst),
    .write_ce(dwrite_ce),
    .wdata(wdata[31:16]),
    .address(drom_addr),
    .dout(drom_dout[31:16]),
    .din(drom_din[31:16]),
    .rom_addr(drom_address),
    .wfin(wfin_b),
    .we(drom_we),
    .ce(drom_ce),
    .oe(drom_oe)
);

drom_read drom_read_a(
    .clk(rom_clk),
    .rst(rst),
    .read_ce(dread_ce),
    .address(drom_addr),
    .dout(drom_dout[15:0]),          //内存读入数据
    .rom_addr(drom_address),
    .data(rom_rdata[15:0]),
    .ce(ce),
    .we(we),
    .oe(oe),
    .rfin(rfin_a)
);

drom_read drom_read_b(
    .clk(rom_clk),
    .rst(rst),
    .read_ce(dread_ce),
    .address(drom_addr),
    .dout(drom_dout[31:16]),
    .rom_addr(drom_address),
    .data(rom_rdata[31:16]),
    .ce(ce),
    .we(we),
    .oe(oe),
    .rfin(rfin_b)
);

irom_read irom_read_a(
    .clk(rom_clk),
    .rst(rst),
    .read_ce(iread_ce),
    .address(irom_addr),
    .dout(irom_dout),
    .data(rom_inst[15:0]),
    .rfin(rfin_c),
    .ce(irom_ce),
    .we(irom_we),
    .oe(irom_oe)
);

irom_read irom_read_b(
    .clk(rom_clk),
    .rst(rst),
    .read_ce(iread_ce),
    .address(irom_addr),
    .dout(irom_dout),
    .data(rom_inst[31:16]),
    .rfin(rfin_d),
    .ce(irom_ce),
    .we(irom_we),
    .oe(irom_oe)
);

endmodule
