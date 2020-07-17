module irom_read(
    input wire clk,         //2ns
    input wire rst,
    input wire read_ce,                 //读使能信号
    input wire [19:0] address,
    input wire [31:0] dout,
    output wire [19:0] rom_addr,
    output wire [31:0] data,
    output wire ce,
    output wire we,
    output wire oe,
    output reg rfin               //数据读取完成信号
    //output lb,
    //output ub
);

assign rom_addr = address;
assign data = (rst == 1'b1)?32'h00000000:dout;

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

always @(posedge clk or posedge rst) begin 
    if (rst) begin 
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
            if (state_fin && read_ce == 1'b1) begin 
                next_state <= s1;
            end
            else if (state_fin && read_ce == 1'b0) begin
                next_state <= s0;
            end
            else next_state <= s3;
        end
        default:begin
            next_state <= s0;
        end 
    endcase
end

always @(posedge clk or posedge rst) begin 
    if(rst) begin 
        i <= 2'b0;
        rfin <= 1'b0;
        //data <= 32'h00000000;
        //rom_addr <= 32'h00000000;
        state_fin <= 1'b0;
    end 
    else begin 
        case (next_state)
            s0:begin              //准备
                i <= 2'b0;
                //data <= 32'h00000000;
                state_fin <= 1'b0;
                //rom_addr <= address;
                rfin <= 1'b0;
            end
            s1:begin
                if(i < 2'd1) begin
                   // rom_addr <= address;
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
                //data <= dout;
                rfin <= 1'b1;
            end
            s3:begin 
                //data <= dout;
                i <= i + 1'b1;
                state_fin <= 1'b1;
                rfin <= 1'b0;
            end
            default:begin 
                i <= 2'b0;
                //data <= 32'h00000000;
                state_fin <= 1'b0;
                //rom_addr <= 32'hxxxxxxxx;
                rfin <= 1'b0;
            end
        endcase 
    end
end



endmodule 