module uart_asyn_ram(
    input wire wr_clk,
    input wire wr_rst,
    input wire wr_uart_write_ce,
    input wire wr_clean_recv_flag,
    input wire [7:0] wr_uart_wdata,

    input wire rd_clk,
    input wire rd_rst,
    output wire rd_uart_write_ce,
    output wire rd_clean_recv_flag,
    output wire [7:0] rd_uart_wdata
);

reg t_uart_write_ce;
reg t_clean_recv_flag;
reg [7:0] t_uart_wdata;


always @(posedge wr_clk or posedge wr_rst) begin 
    if (wr_rst == 1'b0) begin 
        t_uart_write_ce <= wr_uart_write_ce;
        t_clean_recv_flag <= wr_clean_recv_flag;
        t_uart_wdata <= wr_uart_wdata;
    end
    else begin 
        t_uart_wdata <= 8'd0;
        t_clean_recv_flag <= 1'b0;
        t_uart_write_ce <= 1'b0;
    end
end

assign rd_uart_write_ce = t_uart_write_ce;
assign rd_clean_recv_flag = t_clean_recv_flag;
assign rd_uart_wdata = t_uart_wdata;

endmodule
