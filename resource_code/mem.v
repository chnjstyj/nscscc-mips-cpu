    module mem(                   //使用小端模式
    input clk,
    input rst,
    //input rom_clk,
    output reg stall_dram,
    input [31:0] alu_result,
    input [31:0] din,
    input [15:0] imme,
    input MemWrite,
    input MemRead,
    input MemtoReg,
    input [1:0] mem_sel,
    input lui_sig,
    (* dont_touch = "1" *)output reg [31:0] dout,
    output reg [31:0] dram_write_addr,
    output wire [31:0] dram_read_addr,
    output reg write_ce,
    output reg [31:0] wdata,
    output reg read_ce,
    input [31:0] ram_rdata,
    //串口相关
    output reg [7:0] uart_wdata,
    output reg uart_write_ce,
    input [7:0] uart_rdata,
    output reg clean_recv_flag,
    input recv_flag,
    input send_flag
);

wire [31:0] dram_address;


localparam s0 = 1'b0;       //不暂停
localparam s1 = 1'b1;       //暂停

reg cur_state;
reg next_state;


assign dram_address = {5'b00000,alu_result[28:2]};
assign dram_read_addr = dram_address;
//always @(*) dram_address <= dram_addr;
//assign drom_address = drom_addr;
//assign read_ce = clk & MemRead;
reg [31:0] data_out;

always @(posedge clk or posedge rst) begin 
    if (rst == 1'b1) begin 
        write_ce <= 1'b0;
        dram_write_addr <= 32'h00000000;
    end
    else if(MemWrite && dram_address != 32'h7f400fe) begin 
        write_ce <= 1'b1;
        dram_write_addr <= dram_address;
    end
    else write_ce <= 1'b0;
end

//写数据到内存
always @(posedge clk or posedge rst) begin 
    if (rst == 1'b1) begin 
        wdata <= 32'h00000000;
        uart_wdata <= 8'h00;
        uart_write_ce <= 1'b0;
    end
    else begin 
        if(MemWrite && dram_address != 32'h7f400fe) begin 
            //write_ce <= 1'b1;
            //drom_addr <= drom_address;
            uart_write_ce <= 1'b0;
            case (mem_sel)
                2'b00:wdata <= 32'h00000000;
                2'b01:begin 
                    case (alu_result[1:0])
                        2'b11:wdata <= {{24{din[7]}},din[7:0]};
                        2'b10:wdata <= {{24{din[15]}},din[15:8]};
                        2'b01:wdata <= {{24{din[23]}},din[23:16]};
                        2'b00:wdata <= {{24{din[31]}},din[31:24]};
                        default:wdata <= 32'h00000000;
                    endcase
                end
                2'b10:wdata <= {{16{din[15]}},din[15:0]};
                2'b11:wdata <= din;
                default:wdata <= 32'h00000000;
            endcase
        end
        else if(MemWrite && dram_address == 32'h7f400fe) begin 
            uart_wdata <= din[7:0];
            //write_ce <= 1'b0;
            uart_write_ce <= 1'b1;
        end
        else begin 
            uart_write_ce <= 1'b0;
            //write_ce <= 1'b0;
            //drom_addr <= 32'hzzzzzzzz;
            //wdata <= wdata;
            //uart_wdata <= 8'h00;
        end 
    end
end 

//从内存读数据
always @(*) begin 
    if (rst == 1'b1) begin 
        data_out <= 32'h00000000;
        clean_recv_flag <= 1'b0;
        read_ce <= 1'b0;
    end
    else begin
        if(MemRead) begin 
            case (dram_address)
            32'h7f400fe:begin        //读串口的数据  清除接收标志位
                data_out <= {24'b0,uart_rdata};
                clean_recv_flag <= 1'b1;
                read_ce <= 1'b0;
            end
            32'h7f400ff:begin        //读标志位
                data_out <= {30'b0,recv_flag,send_flag};
                clean_recv_flag <= 1'b0;
                read_ce <= 1'b0;
            end
            default:begin
                    read_ce <= 1'b1;
                    //drom_addr <= drom_address;
                    clean_recv_flag <= 1'b0;
                    case(mem_sel)
                    2'b00:data_out <= 32'h00000000;
                    2'b01:begin 
                        case(alu_result[1:0])
                            2'b11:data_out <= {{24{ram_rdata[31]}},ram_rdata[31:24]};
                            2'b10:data_out <= {{24{ram_rdata[23]}},ram_rdata[23:16]};
                            2'b01:data_out <= {{24{ram_rdata[15]}},ram_rdata[15:8]};
                            2'b00:data_out <= {{24{ram_rdata[7]}},ram_rdata[7:0]};
                            default:data_out <= 32'h00000000;
                        endcase
                    end
                    2'b10:data_out <= {16'h0000,ram_rdata[15:0]};
                    2'b11:data_out <= ram_rdata;
                    default:data_out <= ram_rdata;
                    endcase 
            end
            endcase
        end
        else begin 
            clean_recv_flag <= 1'b0;
            data_out <= 32'h00000000;
            //drom_addr <= 32'h00000000;
            read_ce <= 1'b0;
        end
    end
end

//决定哪个数据写回寄存器堆      写回
//assign dout = (MemtoReg == 1'b1)?data_out:alu_result;
always @(*) begin 
    if (rst == 1'b1) dout <= 32'h00000000;
    else if (MemtoReg == 1'b1 && lui_sig != 1'b1)
        dout <= data_out;
    else if (MemtoReg != 1'b1 && lui_sig != 1'b1)
        dout <= alu_result;
    else if (lui_sig == 1'b1)
        dout <= {{imme},16'b0};
     else dout <= 32'h0;
end

always @(posedge clk or posedge rst) begin
    if (rst == 1'b1) cur_state <= s1;
    else cur_state <= next_state;
end

always @(*) begin 
    case (cur_state) 
        s0:begin 
            if ((read_ce || write_ce) &&!dram_address[20]) next_state <= s1;
            else next_state <= s0;
        end
        s1:begin 
            next_state <= s0;
        end
        default:next_state <= s0;
    endcase 
end

always @(*) begin 
    if (rst == 1'b1) stall_dram <= 1'b0;
    else begin 
        case (next_state) 
            s0:stall_dram <= 1'b0;
            s1:stall_dram <= 1'b1;
            default:next_state <= 1'b0;
        endcase 
    end
end

endmodule 