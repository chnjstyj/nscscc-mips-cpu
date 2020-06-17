    module mem(                   //使用小端模式
    input clk,
    (* dont_touch = "1" *)input rst,
    //input rom_clk,
    input [31:0] alu_result,
    input [31:0] din,
    (* dont_touch = "1" *)input [31:0] imme,
    input MemWrite,
    input MemRead,
    input MemtoReg,
    input [1:0] mem_sel,
    input lui_sig,
    output reg [31:0] dout,
    output reg [31:0] drom_addr,
    output reg write_ce,
    output reg [31:0] wdata,
    (* dont_touch = "1" *)output reg read_ce,
    input [31:0] rom_rdata,
    input wfin_a,
    input rfin_a,
    //串口相关
    output reg [7:0] uart_wdata,
    output reg uart_write_ce,
    input [7:0] uart_rdata,
    (* dont_touch = "1" *)output reg clean_recv_flag,
    input recv_flag,
    input send_flag
);
wire [31:0] drom_address;

always @(*)  drom_addr <= {5'b00000,alu_result[28:2]};
assign drom_address = drom_addr;
(* dont_touch = "1" *)reg [31:0] data_out;
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
always @(posedge clk or posedge wfin_a) begin 
    if(MemWrite && drom_address != 32'h7f400fe) begin 
        case (mem_sel)
            2'b00:wdata <= 32'h00000000;
            2'b01:wdata <= {24'h000000,din[7:0]};
            2'b10:wdata <= {16'h0000,din[15:0]};
            2'b11:wdata <= din;
            default:wdata <= 32'h00000000;
        endcase
        if(wfin_a) begin
            write_ce <= 1'b0;
            //wdata <= 32'hzzzzzzzz;
        end 
        else begin 
            write_ce <= 1'b1;
        end 
    end
    else if(MemWrite && drom_address == 32'h7f400fe) begin 
        uart_wdata <= din[7:0];
        write_ce <= 1'b0;
        uart_write_ce <= 1'b1;
    end
    else begin 
        uart_write_ce <= 1'b0;
        write_ce <= 1'b0;
        wdata <= 32'hzzzzzzzz;
        uart_wdata <= 8'h00;
    end 
end 
//从内存读数据
always @(*) begin 
    if(MemRead) begin 
        case (drom_addr)
        32'h7f400fe:begin        //读串口的数据  清除接收标志位
            data_out <= {24'h000000,uart_rdata};
            clean_recv_flag <= 1'b1;
        end
        32'h7f400ff:begin        //读标志位
            data_out <= {24'h00000000,recv_flag,send_flag};
            clean_recv_flag <= 1'b0;
        end
        default:begin
            clean_recv_flag <= 1'b0;
            if(rfin_a) begin
                read_ce <= 1'b0; 
                case(mem_sel)
                2'b00:data_out <= 32'hzzzzzzzz;
                2'b01:data_out <= {24'h000000,rom_rdata[7:0]};
                2'b10:data_out <= {16'h0000,rom_rdata[15:0]};
                2'b11:data_out <= rom_rdata;
                default:data_out <= rom_rdata;
                endcase 
            end
            else begin
                data_out <= data_out;
                read_ce <= 1'b1;
            end
        end
        endcase
    end
    else begin 
        clean_recv_flag <= 1'b0;
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
     else dout <= 32'h0;
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