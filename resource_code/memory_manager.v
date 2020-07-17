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
                //stall_mem <= 1'b1;
            end
            else if(dwrite_ce == 1'b1 && dram_write_addr[20] == 1'b0) begin 
                next_state <= s2;
                //stall_mem <= 1'b1;
            end
            else if(iread_ce == 1'b1) begin 
                next_state <= s0;
                //stall_mem <= 1'b0;
            end
            else begin 
                next_state <= s0;
                //stall_mem <= 1'b0;
            end
            stall_mem <= 1'b0;
        end
        s1:begin 
            if(dread_ce == 1'b1 && dram_read_addr[20] == 1'b0) next_state <= s1;
            else next_state <= s0;
        end
        s2:begin 
            if(dwrite_ce == 1'b1 && dram_write_addr[20] == 1'b0) next_state <= s2;
            else next_state <= s0;
        end
        s3:begin 
            if (iread_ce) next_state <= s0;
            else next_state <= s3;
        end
        default:next_state <= s0;
    endcase
end
/*
assign base_read_ce = (cur_state == s0 || cur_state == s1)?1'b1:1'b0;
assign base_write_ce = (cur_state == s2)?1'b1:1'b0;
assign ext_read_ce = (dram_addr[20] && dread_ce && cur_state == s0)?1'b1:1'b0;
assign ext_write_ce = (dram_addr[20] && dwrite_ce && cur_state == s0)?1'b1:1'b0;*/

/*
always @(posedge clk or posedge rst) begin 
    if (rst == 1'b1) begin 
        base_read_ce <= 1'b0;
        base_write_ce <= 1'b0;
        ext_read_ce <= 1'b0;
        ext_write_ce <= 1'b0;
        //ext_addr <= 20'h00000;
        //base_addr <= 20'h00000;
        
        dram_rdata <= 32'h00000000;
        iram_rdata <= 32'h00000000;
        base_wdata <= 32'h00000000;
        ext_wdata <= 32'h00000000;
    end
    else begin 
        case (next_state) 
            s0:begin 
                if (dram_addr[20] == 1'b1 && dread_ce == 1'b1) begin //读ext
                    ext_read_ce <= 1'b1;
                    //ext_addr <= dram_addr[19:0];
                    //dram_rdata <= ext_rdata;
                end
                else if (dram_addr[20] == 1'b1 && dwrite_ce == 1'b1) begin //写ext
                    ext_write_ce <= 1'b1;
                    //ext_addr <= dram_addr[19:0];
                    //ext_wdata <= dram_wdata;
                end
                else begin
                    ext_write_ce <= 1'b0;
                    ext_read_ce <= 1'b0;
                    //ext_addr <= 20'h00000;
                end
                base_read_ce <= 1'b1;
                base_write_ce <= 1'b0;
                //base_addr <= iram_addr[19:0];
            end
            s1:begin 
                base_read_ce <= 1'b1;
                base_write_ce <= 1'b0;
                //base_addr <= dram_addr[19:0];
            end
            s2:begin 
                base_write_ce <= 1'b1;
                base_read_ce <= 1'b0;
                //base_addr <= dram_addr[19:0];
                //base_wdata <= dram_wdata;
            end
            s3:begin 
                base_read_ce <= 1'b0;
                base_write_ce <= 1'b0;
                ext_read_ce <= 1'b0;
                ext_write_ce <= 1'b0;
                //ext_addr <= 20'h00000;
                //base_addr <= 20'h00000;
            end
            default:begin 
                base_read_ce <= 1'b0;
                base_write_ce <= 1'b0;
                ext_read_ce <= 1'b0;
                ext_write_ce <= 1'b0;
                //ext_addr <= 20'h00000;
                //base_addr <= 20'h00000;
            end
        endcase
    end
end*/

assign base_addr = (cur_state == s0)?iram_addr[19:0]:(dwrite_ce)?dram_write_addr[19:0]:dram_read_addr[19:0];
//assign ext_addr = ((dwrite_ce || dread_ce)&&dram_addr[20])?dram_addr:32'h00000;
assign ext_addr = (dwrite_ce && dram_write_addr[20])?dram_write_addr[19:0]:(dread_ce && dram_read_addr[20])?dram_read_addr[19:0]:20'h00000;

assign dram_rdata = (dram_read_addr[20] && dread_ce && next_state == s0)?ext_rdata:base_rdata;
assign iram_rdata = (cur_state == s0)?base_rdata:32'h00000000;
assign ext_wdata = (dram_write_addr[20] && dwrite_ce && next_state == s0)?dram_wdata:32'h00000000;
assign base_wdata = (next_state == s2)?dram_wdata:32'h00000000;

assign ext_read_ce = (next_state == s0 && dram_read_addr[20] && dread_ce)?1'b1:1'b0;
assign ext_write_ce = (next_state == s0 && dram_write_addr[20] && dwrite_ce)?1'b1:1'b0;
assign base_read_ce = (next_state == s0 || next_state == s1)?1'b1:1'b0;
assign base_write_ce = (next_state == s2)?1'b1:1'b0;

endmodule