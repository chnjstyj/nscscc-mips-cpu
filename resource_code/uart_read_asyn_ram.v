module uart_read_asyn_ram(
    input wire wr_clk,
    input wire wr_rst,
    input wire [7:0] wr_uart_rdata,

    input wire rd_clk,
    input wire rd_rst,
    output wire [7:0] rd_uart_rdata
);

reg [7:0] t_uart_rdata;

always @(posedge wr_clk) begin 
    if (wr_rst == 1'b0) begin 
        t_uart_rdata <= wr_uart_rdata;
    end
end
/*
always @(posedge rd_clk) begin 
    if (rd_rst == 1'b0) begin 
        rd_uart_rdata <= t_uart_rdata;
    end
end*/

assign rd_uart_rdata = t_uart_rdata;

endmodule