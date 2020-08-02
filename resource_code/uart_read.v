module uart_read(
    input wire clk,          //9600bps
    input wire clk_98M,
    input wire rst,
    input wire read_ce,
    input wire din,
    output reg rfin,        //读完成信号
    output wire [7:0] dout
);

localparam s0 = 2'b00;      //等待
localparam s1 = 2'b01;      //等待开始位
localparam s2 = 2'b11;      //读波形
localparam s3 = 2'b10;      //等待结束位

reg [1:0] cur_state;
reg [1:0] next_state;
reg state_fin;
reg [3:0] i;
reg [7:0] t_data;

assign dout = t_data;

always @(posedge clk or posedge rst) begin 
    if(rst)
        cur_state <= s0;
    else 
        cur_state <= next_state;
end 

always @(*) begin 
    case (cur_state) 
        s0:begin 
            if(read_ce) next_state <= s1;
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
            if(state_fin && read_ce) next_state <= s1;
            else if (state_fin && !read_ce) next_state <= s0;
            else next_state <= s0;
        end 
    endcase
end

always @(posedge clk or posedge rst) begin 
    if(rst) begin 
        state_fin <= 1'b0;
        i <= 4'h0;
        t_data <= 8'h00;
    end 
    else begin 
        case(next_state)
            s0:begin 
                state_fin <= 1'b0;
            end 
            s1:begin 
                if(din == 1'b0) begin
                    state_fin <= 1'b1;
                    i <= 4'h0;
                end
                else begin
                    state_fin <= 1'b0;
                end
            end 
            s2:begin
                if(i <= 4'd6) begin 
                    state_fin <= 1'b0;
                    t_data[i] <= din;
                    i <= i + 1'b1;
                end 
                else begin 
                    t_data[i] <= din;
                    state_fin <= 1'b1;
                end 
            end 
            s3:begin 
                if(din != 1'b1) state_fin <= 1'b0;
                else begin
                    state_fin <= 1'b1;
                end
            end 
            default:begin 
                t_data <= 8'h00;
                state_fin <= 1'b0;
            end
        endcase
    end
end

always @(posedge clk_98M or posedge rst) begin 
    if (rst) begin 
        rfin <= 1'b0;
    end
    else begin 
        if (cur_state == s3) rfin <= 1'b1;
        else if (cur_state == s2) rfin <= 1'b0;
    end
end

endmodule 