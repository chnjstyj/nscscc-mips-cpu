module sram_read_asyn_ram(
    input wire wr_clk,
    input wire wr_rst,
    input wire [31:0] wr_base_rdata,
    input wire [31:0] wr_ext_rdata,

    input wire rd_clk,
    input wire rd_rst,
    output wire [31:0] rd_base_rdata,
    output wire [31:0] rd_ext_rdata
);

reg [31:0] t_base_rdata;
reg [31:0] t_ext_rdata;

always @(posedge wr_clk) begin 
    if(wr_rst == 1'b0) begin 
        t_base_rdata <= wr_base_rdata;
        t_ext_rdata <= wr_ext_rdata;
    end
    else begin 
        t_base_rdata <= 32'h00000000;
        t_ext_rdata <= 32'h00000000; 
    end
end
/*
always @(posedge rd_clk) begin 
    if(rd_rst == 1'b0) begin 
        t_base_rdata_ce <= 1'b1;
        t_ext_rdata_ce <= 1'b1;
    end
    else begin 
        t_base_rdata_ce <= 1'b0;
        t_ext_rdata_ce <= 1'b0;
    end
end*/

assign rd_base_rdata = t_base_rdata;
assign rd_ext_rdata = t_ext_rdata;

endmodule