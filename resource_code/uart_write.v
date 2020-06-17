module uart_write(
    input wire clk,          //9600bps
    input wire rst,
    input wire write_ce,
    input wire [7:0] din,
    output reg wfin,        //读完成信号
    output reg dout
);

localparam s0 = 2'b00;      //等待
localparam s1 = 2'b01;      //写开始位
localparam s2 = 2'b11;      //写波形
localparam s3 = 2'b10;      //写结束位

reg [1:0] cur_state;
reg [1:0] next_state;
reg state_fin;
reg [2:0] i;

always @(posedge clk) begin 
    if(rst)
        cur_state <= s0;
    else 
        cur_state <= next_state;
end 

always @(*) begin 
    case (cur_state) 
        s0:begin 
            if(write_ce) next_state <= s1;
            else next_state <= s0;
        end 
        s1:begin 
            if(state_fin) next_state <= s2;
            else next_state <=s1;
        end 
        s2:begin 
            if(state_fin && i == 3'd7) next_state <= s3;
            else next_state <= s2;
        end 
        s3:begin 
            if(state_fin && write_ce) next_state <= s1;
            else if(state_fin && !write_ce) next_state <= s0;
            else next_state <= s3;
        end 
    endcase
end

always @(posedge clk) begin 
    if(rst) begin 
        state_fin <= 1'b0;
        wfin <= 1'b1;
        dout <= 1'b0;
        i <= 3'b0;
    end 
    else begin 
        case(next_state)
            s0:begin 
                dout <= 1'b1;
                wfin <= 1'b1;
                state_fin <= 1'b0;
            end 
            s1:begin 
                wfin <= 1'b1;
                dout <= 1'b0;
                state_fin <= 1'b1;
                i <= 3'b0;
            end 
            s2:begin
                if(i != 8'd7) begin 
                    state_fin <= 1'b0;
                    dout <= din>>(i - 8'd0);
                    i <= i + 1'b1;
                end 
                else begin 
                    dout <= din>>(i - 8'd0);
                    state_fin <= 1'b1;
                end 
            end 
            s3:begin 
                dout <= 1'b1;
                wfin <= 1'b1;
                state_fin <= 1'b1;
            end 
        endcase
    end
end


endmodule 