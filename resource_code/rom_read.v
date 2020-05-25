`timescale 1ns/1ps
module rom_read(
    input clk,         //2ns
    input rst,
    input read_ce,                 //读使能信号
    input [31:0] address,
    input [31:0] data,
    output reg [31:0] rom_addr,
    output reg [31:0] dout,
    output reg ce,
    output reg we,
    output reg oe,
    output reg rfin               //数据读取完成信号
    //output lb,
    //output ub
);

localparam s0 = 2'b00;
localparam s1 = 2'b01;
localparam s2 = 2'b10;
localparam s3 = 2'b11;

reg [1:0] i;

reg [1:0] cur_state;
reg [1:0] next_state;
reg state_fin;

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
    if (rst || !read_ce) begin
        i <= 2'd0;
        dout <= 32'h00000000;
        ce <= 1'b1;
        oe <= 1'b1;
        rom_addr <= 32'h00000000;
        state_fin <= 1'b0;
    end 
    else begin 
        case (next_state)
            s0:begin           //准备
            i <= 2'd0;
            dout <= 32'h00000000;
            ce <= 1'b1;
            oe <= 1'b1;
            rom_addr <= 32'h00000000;
            state_fin <= 1'b0;
            rfin <= 1'b0;
            end 
            s1:begin i <= 2'd0;          //给出地址，信号拉低 4ns
                if (i < 2'd1) begin 
                    state_fin <= 1'b0;
                    rom_addr <= address;
                    i <= i + 2'd1;
                end 
                else if(i == 2'd1) begin
                    ce <= 1'b0;
                    oe <= 1'b0;
                    state_fin <= 1'b1;
                    i <= 2'd0;
                end 
            end
            s2:begin  i <= 2'd0;         //读数据阶段 4ns
                if (i < 2'd1) begin 
                    state_fin <= 1'b0;
                    dout <= data;
                    i <= i + 2'd1; 
                end 
                else begin 
                    state_fin <= 1'b1;
                    i <= 2'd0;
                end 
            end
            s3: begin                   //维持至少3.5ns
                if (i < 2'd1) begin 
                    state_fin <= 1'b0;
                    oe <= 1'b0;
                    ce <= 1'b0;
                    i <= i + 1;
                end 
                else begin 
                    oe <= 1'b1;
                    ce <= 1'b1;
                    rfin <= 1'b1;
                    state_fin <= 1'b1;
                    i <= 2'd0;
                end 
            end
            default:begin 
                i <= 2'd0;
                dout <= 32'h00000000;
                ce <= 1'b1;
                oe <= 1'b1;
                rom_addr <= 32'h00000000;
                rfin <= 1'b0;
            end 
        endcase
    end
end

always @(*) we <= 1'b1;

endmodule




    