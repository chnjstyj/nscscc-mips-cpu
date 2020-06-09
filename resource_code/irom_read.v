module irom_read(
    input clk,         //1ns
    input rst,
    input read_ce,                 //读使能信号
    input [31:0] address,
    input [15:0] dout,
    output reg [31:0] rom_addr,
    output reg [15:0] data,
    output ce,
    output we,
    output oe,
    output reg rfin               //数据读取完成信号
    //output lb,
    //output ub
);

localparam s0 = 2'b00;
localparam s1 = 2'b01;
localparam s2 = 2'b11;
localparam s3 = 2'b10;

reg [1:0] i;

reg [1:0] cur_state;
reg [1:0] next_state;
reg state_fin;

assign we = 1'b1;
assign ce = 1'b0;
assign oe = 1'b0;

always @(posedge clk) begin 
    if (rst || !read_ce) begin 
        cur_state <= s0;
    end
    else begin 
        cur_state <= next_state;
    end 
end 

always @(*) begin 
    case (cur_state)
        s0:begin 
            if (read_ce) begin 
                next_state <= s1;
            end
            else next_state <= s0;
        end
        s1:begin 
            if (state_fin) begin 
                next_state <= s2;
            end
            else next_state <= s1;
        end
        s2:begin 
            if (state_fin) begin 
                next_state <= s3;
            end
            else next_state <= s2;
        end
        s3:begin 
            if (state_fin) begin 
                next_state <= s0;
            end
            else next_state <= s3;
        end
        default:begin
            next_state <= s0;
        end 
    endcase
end

always @(posedge clk) begin 
    if(rst || !read_ce) begin 
        i <= 2'b0;
        data <= 16'hxxxx;
        state_fin <= 1'b0;
    end 
    else begin 
        case (next_state)
            s0:begin              //准备
                i <= 2'b0;
                data <= 16'hxxxx;
                state_fin <= 1'b0;
                rom_addr <= 32'hxxxxxxxx;
                rfin <= 1'b0;
                data <= 16'hxxxx;
            end
            s1:begin
                if(i < 2'd1) begin
                    rom_addr <= address;
                    i <= i + 1'b1;
                end 
                else begin 
                    state_fin <= 1'b1;
                    i <= 2'b0;
                end
            end
            s2:begin 
                i <= 2'b0;
                state_fin <= 1'b1;
                data <= dout;
                rfin <= 1'b1;
            end
            s3:begin 
                data <= dout;
                i <= i + 1'b1;
                state_fin <= 1'b1;
                rfin <= 1'b0;
            end
            default:begin 
                i <= 2'b0;
                data <= 16'hxxxx;
                state_fin <= 1'b0;
                rom_addr <= 32'hxxxxxxxx;
                rfin <= 1'b0;
                data <= 16'hxxxx;
            end
        endcase 
    end
end


endmodule 