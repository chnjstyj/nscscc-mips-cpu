module memory_manager(      //数据直接连接到内存端口
    input wire clk,
    input wire rst,
    input wire [31:0] dram_write_addr,
    input wire [31:0] dram_read_addr,
    input wire [31:0] iram_addr,
    input wire [31:0] base_rdata,
    input wire [31:0] ext_rdata,
    input wire [31:0] dram_wdata,
    input wire dwrite_ce,
    input wire dread_ce,
    input wire iread_ce,
    output reg stall_mem,
    output wire [31:0] iram_rdata,
    output wire [31:0] dram_rdata,
    output wire [31:0] base_wdata,
    output wire [31:0] ext_wdata,
    output wire base_read_ce,
    output wire base_write_ce,
    output wire ext_read_ce,
    output wire ext_write_ce,
    output wire [19:0] base_addr,
    output wire [19:0] ext_addr
);

always @(*) stall_mem <= 1'b0;

localparam s0 = 2'b00;  //指令访存 并读写ext内存
localparam s1 = 2'b01;  //数据读base内存
localparam s2 = 2'b11;  //数据写base内存
localparam s3 = 2'b10;  //暂停

reg [1:0] cur_state; 
reg [1:0] next_state;

always @(posedge clk or posedge rst) begin
    if (rst == 1'b1) 
        cur_state <= s3;
    else 
        cur_state <= next_state;
end

always @(*) begin 
    case (cur_state) 
        s0:begin 
            if(dread_ce == 1'b1 && dram_read_addr[20] == 1'b0) begin 
                next_state <= s1;
            end
            else if(dwrite_ce == 1'b1 && dram_write_addr[20] == 1'b0) begin 
                next_state <= s2;
            end
            else if(iread_ce == 1'b1) begin 
                next_state <= s0;
            end
            else begin 
                next_state <= s0;
            end
        end
        s1:begin 
            next_state <= s0;
        end
        s2:begin 
            next_state <= s0;
        end
        s3:begin 
            if (iread_ce) next_state <= s0;
            else next_state <= s3;
        end
        default:begin 
            next_state <= s0;
        end
    endcase
end

assign base_addr = (next_state == s0)?iram_addr[19:0]:(dwrite_ce)?dram_write_addr[19:0]:dram_read_addr[19:0];
assign ext_addr = (dwrite_ce && dram_write_addr[20])?dram_write_addr[19:0]:(dread_ce && dram_read_addr[20])?dram_read_addr[19:0]:20'h00000;

assign dram_rdata = (dram_read_addr[20] && dread_ce && next_state == s0)?ext_rdata:base_rdata;
assign iram_rdata = (next_state == s0)?base_rdata:32'h00000000;
assign ext_wdata = (dram_write_addr[20] && dwrite_ce && next_state == s0)?dram_wdata:32'h00000000;
assign base_wdata = (next_state == s2)?dram_wdata:32'h00000000;

assign ext_read_ce = (dram_read_addr[20] && dread_ce)?1'b1:1'b0;
assign ext_write_ce = (dram_write_addr[20] && dwrite_ce)?1'b1:1'b0;
assign base_read_ce = (next_state == s0 || next_state == s1)?1'b1:1'b0;
assign base_write_ce = (next_state == s2)?1'b1:1'b0;

endmodule