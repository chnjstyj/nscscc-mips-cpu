    module mem(                   //使用小端模式
    input clk,
    input rst,
    input rom_clk,
    input [31:0] alu_result,
    input [31:0] din,
    input [31:0] imme,
    input MemWrite,
    input MemRead,
    input MemtoReg,
    input [1:0] mem_sel,
    input lui_sig,
    //input [4:0] mem_wreg,
    //input mem_RegWrite,
    //output reg wb_RegWrite,
    //output reg [4:0] wb_wreg,
    /*
    input [15:0] rom_data_a,
    input [15:0] rom_data_b,
    output [31:0] rom_din,         //内存写数据
    output [31:0] rom_dout,
    output [31:0] rom_addr,
    output we,
    output ce,
    output oe,
    output reg [31:0] dout*/
    output drom_addr,
    output reg write_ce,
    output reg [31:0] wdata,
    output reg read_ce,
    input [31:0] rom_rdata,
    input wfin_a,
    input wfin_b,
    input rfin_a,
    input rfin_b
);

assign drom_addr = {2'b00,alu_result[31:2]};
/*
//读写内存相关
reg [31:0] wdata;
reg write_ce;
reg read_ce;
wire wfin_a;
wire wfin_b;
wire rfin_a;
wire rfin_b;
wire [31:0] rom_rdata;



reg [7:0] ram_a[0:1023];
reg [7:0] ram_b[0:1023];
reg [7:0] ram_c[0:1023];
reg [7:0] ram_d[0:1023];*/
reg [31:0] data_out;
/*
always @(posedge clk) begin 
    wb_wreg <= mem_wreg;
    wb_RegWrite <= mem_RegWrite;
end
*/
//读数据
/*
always @(*) begin
    if(MemRead) begin         //取低10位 因为log1024/log2 = 10  
        case (mem_sel)
            2'b00:data_out <= 32'hzzzzzzzz;
            2'b01:data_out <= {24'h0,ram_a[alu_result[9:2]]};
            2'b10:data_out <= {16'h0,ram_b[alu_result[9:2]],ram_a[alu_result[9:2]]};
            2'b11:data_out <= {ram_d[alu_result[9:2]],ram_c[alu_result[9:2]],ram_b[alu_result[9:2]],ram_a[alu_result[9:2]]};
        endcase
    end
    else
        data_out <= 32'hzzzzzzzz;
end

//写数据     在时钟上升沿
always @(posedge clk) begin
    if (MemWrite) begin
        case (mem_sel)
            2'b00: ram_a[alu_result[9:2]] <= ram_a[alu_result[9:2]];              //sc指令先不实现
            2'b01:begin                                                         //sb
                ram_a[alu_result[9:2]] <= din[7:0];
                ram_b[alu_result[9:2]] <= ram_b[alu_result[9:2]];
                ram_c[alu_result[9:2]] <= ram_c[alu_result[9:2]];
                ram_d[alu_result[9:2]] <= ram_d[alu_result[9:2]];                    
            end
            2'b10:begin                                                         //sh
                ram_a[alu_result[9:2]] <= din[7:0];
                ram_b[alu_result[9:2]] <= din[15:8];
                ram_c[alu_result[9:2]] <= ram_c[alu_result[9:2]];
                ram_d[alu_result[9:2]] <= ram_d[alu_result[9:2]];
            end
            2'b11:begin
                ram_a[alu_result[9:2]] <= din[7:0];
                ram_b[alu_result[9:2]] <= din[15:8];
                ram_c[alu_result[9:2]] <= din[23:16];
                ram_d[alu_result[9:2]] <= din[31:24];
            end
            default: ram_a[alu_result[9:2]] <= ram_a[alu_result[9:2]];
        endcase 
    end
    else 
        ram_a[alu_result[9:2]] <= ram_a[alu_result[9:2]];
end
*/
//写数据到内存
always @(*) begin 
    if(MemWrite) begin 
        write_ce <= 1'b1;
        case (mem_sel)
            2'b00:write_ce <= 1'b0;
            2'b01:wdata <= {24'h000000,din[7:0]};
            2'b10:wdata <= {16'h0000,din[15:0]};
            2'b11:wdata <= din;
            default:write_ce <= 1'b0;
        endcase
        if(wfin_a && wfin_b) begin
            //write_ce <= 1'b0;
            wdata <= 32'hzzzzzzzz;
        end 
        else begin 
            write_ce <= 1'b1;
        end 
    end 
    else begin 
        write_ce <= 1'b0;
        wdata <= 32'hzzzzzzzz;
    end 
end 
//从内存读数据
always @(*) begin 
    if(MemRead) begin 
        read_ce <= 1'b1;
        if(rfin_a && rfin_b) begin 
            case(mem_sel)
            2'b00:data_out <= 32'hzzzzzzzz;
            2'b01:data_out <= {24'h000000,rom_rdata[7:0]};
            2'b10:data_out <= {16'h0000,rom_rdata[15:0]};
            2'b11:data_out <= rom_rdata;
            default:data_out <= 32'hzzzzzzzz;
            endcase 
        end
        else 
        data_out <= data_out;
    end
    else begin 
        read_ce <= 1'b0;
        data_out <= 32'hzzzzzzzz;
    end
end

//决定哪个数据写回寄存器堆      写回
//assign dout = (MemtoReg == 1'b1)?data_out:alu_result;
always @(*) begin 
    if (MemtoReg == 1'b1 && lui_sig != 1'b1)
        dout <= data_out;
    else if (MemtoReg != 1'b1 && lui_sig != 1'b1)
        dout <= alu_result;
    else if (lui_sig == 1'b1)
        dout <= {{imme[15:0]},16'b0};
end
/*
rom_write rom_write_a(
    .clk(rom_clk),
    .rst(rst),
    .write_ce(write_ce),
    .wdata(wdata[15:0]),
    .address(alu_result[31:2]),
    .dout(rom_dout),
    .din(rom_din),
    .rom_addr(rom_addr),
    .wfin(wfin_a),
    .we(we),
    .ce(ce),
    .oe(oe)
);

rom_write rom_write_b(
    .clk(rom_clk),
    .rst(rst),
    .write_ce(write_ce),
    .wdata(wdata[31:16]),
    .address({2'b00,alu_result[31:2]}),
    .dout(rom_dout),
    .din(rom_din),
    .rom_addr(rom_addr),
    .wfin(wfin_b),
    .we(we),
    .ce(ce),
    .oe(oe)
);

drom_read drom_read_a(
    .clk(rom_clk),
    .rst(rst),
    .read_ce(read_ce),
    .address({2'b00,alu_result[31:2]}),
    .dout(rom_data_a),
    .rom_addr(rom_addr),
    .data(rom_rdata[15:0]),
    .ce(ce),
    .we(we),
    .oe(oe),
    .rfin(rfin_a)
);

drom_read drom_read_b(
    .clk(rom_clk),
    .rst(rst),
    .read_ce(read_ce),
    .address({2'b00,alu_result[31:2]}),
    .dout(rom_data_b),
    .rom_addr(rom_addr),
    .data(rom_rdata[31:16]),
    .ce(ce),
    .we(we),
    .oe(oe),
    .rfin(rfin_b)
);
*/
endmodule 