module soc_top(
    input clk,
    input rst,
    output drom_ce,
    output drom_oe,
    output drom_we,
    output [31:0] drom_address,
    //output [31:0] drom_waddress,
    output [31:0] drom_din,
    (* dont_touch = "1" *)input [31:0] drom_dout,
    output irom_ce,
    output irom_oe,
    output irom_we,
    output [31:0] irom_address,
    //output [31:0] irom_din,
    (* dont_touch = "1" *)input [31:0] irom_dout,
    //串口
    output txd,
    input rxd
    );
    reg reset;
    reg uart_clk;
    wire clk_rom;
    wire locked;
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
     .locked(locked),
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

    //串口
    wire clean_recv_flag;
    wire uart_read_ce;
    wire uart_read_fin;
    wire uart_write_fin;
    wire [7:0] uart_wdata;
    wire [7:0] uart_rdata;    //串口读出数据
    reg recv_flag;           //接收标志位  1:串口收到数据
    reg send_flag;           //发送标志位  1:串口空闲
     
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
        .rfin_d(rfin_d),
        .uart_wdata(uart_wdata),
        .uart_write_ce(uart_write_ce),
        .uart_rdata(uart_rdata),
        .clean_recv_flag(clean_recv_flag),
        .recv_flag(recv_flag),
        .send_flag(send_flag)
    );
rom_write rom_write_a(
    .clk(clk_rom),
    .rst(rst),
    .write_ce(dwrite_ce),
    .wdata(wdata),
    .address(drom_addr),
    .dout(drom_dout),
    .din(drom_din),
    .rom_addr(drom_address),        //给内存的地址
    .wfin(wfin_a),
    .we(drom_we),
    .ce(drom_ce),
    .oe(drom_oe)
);
/*
rom_write rom_write_b(
    .clk(clk_rom),
    .rst(rst),
    .write_ce(dwrite_ce),
    .wdata(wdata[31:16]),
    .address(drom_addr),
    .dout(drom_dout[31:16]),
    .din(drom_din[31:16]),
    .rom_addr(),
    .wfin(wfin_b),
    .we(drom_we),
    .ce(drom_ce),
    .oe(drom_oe)
);
*/
drom_read drom_read_a(
    .clk(clk_rom),
    .rst(rst),
    .read_ce(dread_ce),
    .address(drom_addr),
    .dout(drom_dout),          //内存读入数据
    .rom_addr(drom_address),
    .data(rom_rdata),
    .ce(ce),
    .we(we),
    .oe(oe),
    .rfin(rfin_a)
);
/*
drom_read drom_read_b(
    .clk(clk_rom),
    .rst(rst),
    .read_ce(dread_ce),
    .address(drom_addr),
    .dout(drom_dout[31:16]),
    .rom_addr(),
    .data(rom_rdata[31:16]),
    .ce(ce),
    .we(we),
    .oe(oe),
    .rfin(rfin_b)
);
*/
irom_read irom_read_a(
    .clk(clk_rom),
    .rst(rst),
    .read_ce(iread_ce),
    .address(irom_addr),
    .dout(irom_dout),
    .rom_addr(irom_address),
    .data(rom_inst),
    .rfin(rfin_c),
    .ce(irom_ce),
    .we(irom_we),
    .oe(irom_oe)
);
/*
irom_read irom_read_b(
    .clk(clk_rom),
    .rst(rst),
    .read_ce(iread_ce),
    .address(irom_addr),
    .dout(irom_dout),
    .rom_addr(),
    .data(rom_inst[31:16]),
    .rfin(rfin_d),
    .ce(irom_ce),
    .we(irom_we),
    .oe(irom_oe)
);
*/
initial begin 
    recv_flag <= 1'b0;
    send_flag <= 1'b1;
end

assign uart_read_ce = 1'b1;
always @(*) begin
    if(uart_read_fin == 1'b1) recv_flag <= 1'b1;
    else recv_flag <= recv_flag;
    if(clean_recv_flag) recv_flag <= 1'b0;    //读 清零接受标志位
    else recv_flag <= recv_flag;
end
always @(*) begin 
    if(uart_write_fin) send_flag <= 1'b1;
    else send_flag <= 1'b0;
end

uart_read uart_read(
    .clk(uart_clk),
    .rst(rst),
    .read_ce(uart_read_ce),             //
    .din(rxd),
    .rfin(uart_read_fin),
    .dout(uart_rdata)
);

uart_write uart_write(
    .clk(uart_clk),
    .rst(rst),
    .write_ce(uart_write_ce),                         //写使能
    .din(uart_wdata),                              //来自mem
    .wfin(uart_write_fin),
    .dout(txd)
);

endmodule
