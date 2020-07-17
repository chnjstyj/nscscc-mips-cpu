module sram_asyn_ram(
    input wire wr_clk,
    input wire wr_rst,
    
    input wire wr_base_read_ce,
    input wire wr_base_write_ce,
    input wire wr_ext_read_ce,
    input wire wr_ext_write_ce,
    input wire [103:0] wr_addr_wdata_ce,
    /*
    input wire [19:0] wr_base_addr,
    input wire [19:0] wr_ext_addr,
    input wire [31:0] wr_base_wdata,
    input wire [31:0] wr_ext_wdata, */

    input wire rd_clk,
    input wire rd_rst,
    
    output reg rd_base_read_ce,
    output reg rd_base_write_ce,
    output reg rd_ext_read_ce,
    output reg rd_ext_write_ce,
    output reg [103:0] rd_addr_wdata_ce
    /*
    output reg [19:0] rd_base_addr,
    output reg [19:0] rd_ext_addr,
    output reg [31:0] rd_base_wdata,
    output reg [31:0] rd_ext_wdata*/

);

reg t_base_read_ce;
reg t_base_write_ce;
reg t_ext_read_ce;
reg t_ext_write_ce;
/*
reg [19:0] t_base_addr;
reg [19:0] t_ext_addr;
reg [31:0] t_base_wdata;
reg [31:0] t_ext_wdata;
*/
reg [103:0] t_addr_wdata_ce;

always @(posedge wr_clk) begin 
    if (wr_rst == 1'b0) begin 
        
        t_base_read_ce <= wr_base_read_ce;
        t_base_write_ce <= wr_base_write_ce;
        t_ext_read_ce <= wr_ext_read_ce;
        t_ext_write_ce <= wr_ext_write_ce;
        t_addr_wdata_ce <= wr_addr_wdata_ce;
        /*
        t_base_addr <= wr_base_addr;
        t_ext_addr <= wr_ext_addr;
        t_base_wdata <= wr_base_wdata;
        t_ext_wdata <= wr_ext_wdata;*/
    end
end
/*
assign rd_base_read_ce = t_base_read_ce;
assign rd_base_write_ce = t_base_write_ce;
assign rd_ext_read_ce = t_ext_read_ce;
assign rd_ext_write_ce = t_ext_write_ce;

assign rd_base_addr = t_base_addr;
assign rd_ext_addr = t_ext_addr;
assign rd_base_wdata = t_base_wdata;
assign rd_ext_wdata = t_ext_wdata;
*/

always @(posedge rd_clk) begin 
    if (rd_rst == 1'b0) begin 
        
        rd_base_read_ce <= t_base_read_ce;
        rd_base_write_ce <= t_base_write_ce;
        rd_ext_read_ce <= t_ext_read_ce;
        rd_ext_write_ce <= t_ext_write_ce;
        /*
        rd_base_addr <= t_base_addr;
        rd_ext_addr <= t_ext_addr;
        rd_base_wdata <= t_base_wdata;
        rd_ext_wdata <= t_ext_wdata;*/
        
        rd_addr_wdata_ce <= t_addr_wdata_ce;
    end
end

//assign rd_addr_wdata_ce = t_addr_wdata_ce;

endmodule
