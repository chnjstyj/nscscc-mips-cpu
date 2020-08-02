`default_nettype none

module thinpad_top(
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入（备用，可不用）

    input wire clock_btn,         //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input wire reset_btn,         //BTN6手动复位按钮开关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到“ON”时为1
    output wire[15:0] leds,       //16位LED，输出时1点亮
    output wire[7:0]  dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,       //数码管高位信号，包括小数点，输出1点亮

    //BaseRAM信号
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
    output wire [19:0] base_ram_addr, //BaseRAM地址
    output wire [3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire base_ram_ce_n,       //BaseRAM片选，低有效
    output wire base_ram_oe_n,       //BaseRAM读使能，低有效
    output wire base_ram_we_n,       //BaseRAM写使能，低有效

    //ExtRAM信号
    inout wire [31:0] ext_ram_data,  //ExtRAM数据
    output wire [19:0] ext_ram_addr, //ExtRAM地址
    output wire[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire ext_ram_ce_n,       //ExtRAM片选，低有效
    output wire ext_ram_oe_n,       //ExtRAM读使能，低有效
    output wire ext_ram_we_n,       //ExtRAM写使能，低有效

    //直连串口信号
    output wire txd,  //直连串口发送端
    input  wire rxd,  //直连串口接收端

    //Flash存储器信号，参考 JS28F640 芯片手册
    output wire [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效，16bit模式无意义
    inout  wire [15:0]flash_d,      //Flash数据
    output wire flash_rp_n,         //Flash复位信号，低有效
    output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧写
    output wire flash_ce_n,         //Flash片选信号，低有效
    output wire flash_oe_n,         //Flash读使能信号，低有效
    output wire flash_we_n,         //Flash写使能信号，低有效
    output wire flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1

    //图像输出信号
    output wire[2:0] video_red,    //红色像素，3位
    output wire[2:0] video_green,  //绿色像素，3位
    output wire[1:0] video_blue,   //蓝色像素，2位
    output wire video_hsync,       //行同步（水平同步）信号
    output wire video_vsync,       //场同步（垂直同步）信号
    output wire video_clk,         //像素时钟输出
    output wire video_de           //行数据有效信号，用于区分消隐区
);

/* =========== Demo code begin =========== */
assign base_ram_be_n = 4'b0000;
assign ext_ram_be_n = 4'b0000;

// PLL分频示例
wire locked, clk_98M, clk_500M;
reg clk_top;
reg clk_uart;
integer i;
reg [3:0] k;

pll_example clock_gen 
 (
  // Clock in ports
  .clk_in1(clk_50M),  // 外部时钟输入
  // Clock out ports
  .clk_out1(clk_98M), // 时钟输出1，频率在IP配置界面中设置
  .clk_out2(clk_500M), // 时钟输出2，频率在IP配置界面中设置
  // Status and control signals
  .reset(reset_btn), // PLL复位输入
  .locked(locked)    // PLL锁定指示输出，"1"表示时钟稳定，
                     // 后级电路复位信号应当由它生成（见下）
 );

reg reset_of_clk98M;
reg reset_of_clk500M;
reg reset_of_clktop;
// 异步复位，同步释放，将locked信号转为后级电路的复位reset_of_clk98M
always@(posedge clk_98M or negedge locked) begin
    if(~locked) reset_of_clk98M <= 1'b1;
    else        reset_of_clk98M <= 1'b0;
end
always@(posedge clk_500M or negedge locked) begin
    if(~locked) reset_of_clk500M <= 1'b1;
    else        reset_of_clk500M <= 1'b0;
end

always@(posedge clk_500M or negedge locked) begin
    if(~locked) reset_of_clktop <= 1'b1;
    else        reset_of_clktop <= 1'b0;
end
/*
always @(posedge clk_500M) begin 
    if (reset_of_clk500M) begin 
        k <= 0;
        clk_top <= 1'b0;
    end
    else begin
         if (k < 4'd4) begin
            k <= k + 4'd1;
        end
        else begin 
            clk_top <= ~clk_top;
            k <= 4'd0;
        end
    end
end*/


always @(posedge clk_500M or posedge reset_of_clk500M) begin 
    if (reset_of_clk500M) begin 
        k <= 0;
        clk_top <= 1'b0;
    end
    else begin
     if (k < 4'd5) begin
        clk_top <= 1'b0;
        k <= k + 4'd1;
    end
    else if (k < 4'd9) begin 
        clk_top <= 1'b1;
        k <= k + 4'd1;
    end
    else begin 
        clk_top <= 1'b1;
        k <= 4'd0;
    end
    end
end

always @(posedge clk_98M) begin
    if (reset_of_clk98M) begin 
        i <= 0;
        clk_uart <= 1'b0;
    end
    else if (i < 5120) i <= i + 1;
    else begin 
        clk_uart <= ~clk_uart;
        i <= 0;
    end 
end

    wire ce;
    
    wire [31:0] ram_rdata;
    wire [31:0] dram_write_addr;
    wire [31:0] dram_read_addr;
    wire dwrite_ce;
    wire [31:0] wdata;
    wire dread_ce;
    wire rfin_a;
    wire wfin_a;
    wire rfin_c;
    wire iread_ce;
    wire [31:0] iram_addr;
    wire [31:0] ram_inst;

    //串口
    wire clean_recv_flag;
    wire uart_read_ce;
    wire uart_read_fin;
    wire uart_write_ce;
    wire uart_write_fin;
    wire [7:0] uart_wdata;
    wire [7:0] uart_rdata;    //串口读出数据
    reg recv_flag;           //接收标志位  1:串口收到数据
    reg send_flag;           //发送标志位  1:串口空闲
    reg t_recv_flag;
    reg t_send_flag;
    reg rd_recv_flag;
    reg rd_send_flag;
     
    wire rd_uart_write_ce;
    wire [7:0] rd_uart_wdata;
    wire rd_clean_recv_flag;
    wire [7:0] rd_uart_rdata;
    
    
    wire [31:0] base_rdata;
    wire [31:0] ext_rdata;
    wire [31:0] base_wdata;
    wire [31:0] ext_wdata;
    wire base_read_ce;
    wire base_write_ce;
    wire ext_read_ce;
    wire ext_write_ce;
    wire [19:0] base_addr;
    wire [19:0] ext_addr;
    wire stall_mem;
    
    wire rd_base_read_ce;
    wire rd_base_write_ce;
    wire rd_ext_read_ce;
    wire rd_ext_write_ce;
    wire [19:0] rd_base_addr;
    wire [19:0] rd_ext_addr;
    wire [31:0] rd_base_wdata;
    wire [31:0] rd_ext_wdata;
    
    wire [31:0] rd_base_rdata;
    wire [31:0] rd_ext_rdata;
    
    wire base_fin;
    wire ext_fin;
    
    wire [31:0] base_ram_wdata;
    wire [31:0] base_ram_rdata;
    assign base_ram_data = (base_write_ce == 1'b1)? base_ram_wdata:32'hzzzzzzzz;
    assign base_ram_rdata = base_ram_data;
            
    wire [31:0] ext_ram_wdata;
    wire [31:0] ext_ram_rdata;
    assign ext_ram_data = (ext_write_ce == 1'b1)?ext_ram_wdata:32'hzzzzzzz;
    assign ext_ram_rdata = ext_ram_data;
    
    wire uart_txd;
    
    wire uart_write_flag;
    //wire uart_read_flag;
    
    
    
assign uart_read_ce = (reset_of_clk98M == 1'b1)?1'b0:1'b1;
/*
reg t_recv_flag;
always @(posedge clk_98M) t_recv_flag <= recv_flag;*/
/*
always @(posedge clk_98M or posedge reset_of_clk98M) begin
    if (reset_of_clk98M)
        t_recv_flag <= 1'b0;
    else
        t_recv_flag <= recv_flag;
end*/

reg uart_read_flag;

always @(posedge clk_top or posedge reset_of_clk500M) begin 
    if (reset_of_clk500M) uart_read_flag <= 1'b0;
    else if (clean_recv_flag) uart_read_flag <= 1'b1;
    else if (uart_read_fin == 1'b0) uart_read_flag <= 1'b0;
end

    always @(*) begin
            if (uart_read_fin == 1'b1 && !uart_read_flag) recv_flag <= 1'b1;
            else if (uart_read_flag) recv_flag <= 1'b0;
            else recv_flag <= 1'b0;
    end
    
    
//assign recv_flag = (uart_read_fin)?((uart_read_flag)?1'b0:1'b1):1'b0;

/*
reg t_send_flag;
always @(posedge clk_98M) t_send_flag <= send_flag;*/

always @(*) begin 
        if (uart_write_fin) begin 
            if (uart_write_flag) send_flag <= 1'b0;            
            else send_flag <= 1'b1;
        end
        else send_flag <= 1'b0;
end

//assign send_flag = (uart_write_fin)?((uart_write_flag)?1'b0:1'b1):1'b0;

assign txd = uart_txd;

    top top(
        .clk(clk_top),
        .rst(reset_of_clktop),
        .ce(ce),
        .stall_mem(stall_mem),
        .ram_rdata(ram_rdata),
        .dram_write_addr(dram_write_addr),
        .dram_read_addr(dram_read_addr),
        .dwrite_ce(dwrite_ce),
        .wdata(wdata),
        .dread_ce(dread_ce),
        .iread_ce(iread_ce),
        .iram_addr(iram_addr),
        .ram_inst(ram_inst),
        .irom_fin(base_fin),
        .uart_wdata(uart_wdata),
        .uart_write_ce(uart_write_ce),
        .uart_rdata(rd_uart_rdata),
        .clean_recv_flag(clean_recv_flag),
        .recv_flag(recv_flag),
        .send_flag(send_flag)
    );

uart_asyn_ram uart_asyn_ram(
    .wr_clk(clk_top),
    .wr_rst(reset_of_clktop),
    .wr_uart_write_ce(uart_write_ce),
    .wr_clean_recv_flag(clean_recv_flag),
    .wr_uart_wdata(uart_wdata),
    .rd_clk(clk_uart),
    .rd_rst(reset_of_clk98M),
    .rd_uart_write_ce(rd_uart_write_ce),
    .rd_clean_recv_flag(rd_clean_recv_flag),
    .rd_uart_wdata(rd_uart_wdata)
    );


uart_read_asyn_ram uart_read_asyn_ram(
    .wr_clk(clk_uart),
    .wr_rst(reset_of_clk98M),
    .wr_uart_rdata(uart_rdata),
    .rd_clk(clk_top),
    .rd_rst(reset_of_clk500M),
    .rd_uart_rdata(rd_uart_rdata)
    );
        
uart_read uart_read(
    .clk(clk_uart),
    .clk_98M(clk_98M),
    //.clk_top(clk_top),
    .rst(reset_of_clk98M),
    //.rst_top(reset_of_clk500M),
    .read_ce(uart_read_ce),             //
    .din(rxd),
    //.clean_recv_flag(clean_recv_flag),
    .rfin(uart_read_fin),
    //.flag(uart_read_flag),
    .dout(uart_rdata)
);

uart_write uart_write(
    .clk(clk_uart),
    .clk_top(clk_top),
    .rst(reset_of_clk98M),
    .rst_top(reset_of_clktop),
    .write_ce(rd_uart_write_ce),                         //写使能
    .din(rd_uart_wdata),                              //来自mem
    .wfin(uart_write_fin),
    .flag(uart_write_flag),
    .dout(uart_txd)
);

memory_manager memory_manager(
.clk(clk_top),
.rst(reset_of_clktop),
.stall_mem(stall_mem),
.dram_write_addr(dram_write_addr),
.dram_read_addr(dram_read_addr),
.iram_addr(iram_addr),
.base_rdata(base_rdata),
.ext_rdata(ext_rdata),
.dram_wdata(wdata),
.dwrite_ce(dwrite_ce),
.dread_ce(dread_ce),
.iread_ce(iread_ce),
.iram_rdata(ram_inst),
.dram_rdata(ram_rdata),
.base_wdata(base_wdata),
.ext_wdata(ext_wdata),
.base_read_ce(base_read_ce),
.base_write_ce(base_write_ce),
.ext_read_ce(ext_read_ce),
.ext_write_ce(ext_write_ce),
.base_addr(base_addr),
.ext_addr(ext_addr)
);

ram_rw base_ram(
.clk(clk_500M),
.rst(reset_of_clk500M),
.read_ce(base_read_ce),
.write_ce(base_write_ce),
.write_data(base_wdata),
.addr(base_addr),
.fin(base_fin),
.rom_rdata(base_ram_rdata),
.rom_wdata(base_ram_wdata),
.rom_addr(base_ram_addr),
.we(base_ram_we_n),
 .ce(base_ram_ce_n),
.oe(base_ram_oe_n),
.read_data(base_rdata)
);

ram_rw ext_ram(
.clk(clk_500M),
.rst(reset_of_clk500M),
.read_ce(ext_read_ce),
.write_ce(ext_write_ce),
.write_data(ext_wdata),
.addr(ext_addr),
.rom_rdata(ext_ram_rdata),
.rom_wdata(ext_ram_wdata),
.rom_addr(ext_ram_addr),
.we(ext_ram_we_n),
 .ce(ext_ram_ce_n),
.oe(ext_ram_oe_n),
.read_data(ext_rdata)
);
/*
ila_0 u_ila_0(
.clk(clk_50M),
.probe0(base_addr),
.probe1(base_ram_rdata)
);*/

endmodule
