module ram_rw(
    input wire clk,
    input wire rst,
    input wire read_ce,
    input wire write_ce,
    input wire [31:0] write_data,         //写入数据
    input wire [19:0] addr,
    inout wire [31:0] rom_rdata,
    output reg fin,
    output wire [31:0] rom_wdata,
    output wire [19:0] rom_addr,
    output wire ce,
    output reg we,
    output reg oe,
    output wire [31:0] read_data         //读出数据
);

assign rom_addr = addr;
assign ce = (write_ce || read_ce)?1'b0:1'b1;
assign read_data =rom_rdata;

localparam prepare = 4'b0000;
localparam r0 = 4'b0001;
localparam r1 = 4'b0011;
localparam r2 = 4'b0010;
localparam r3 = 4'b0110;
localparam r4 = 4'b0111;
localparam r5 = 4'b0101;
localparam w0 = 4'b0100;
localparam w1 = 4'b1000;
localparam w2 = 4'b1001;
localparam w3 = 4'b1010;
localparam w4 = 4'b1011;

reg [3:0] cur_state;
reg [3:0] next_state;

always @(posedge clk or posedge rst) begin
    if (rst == 1'b1) begin
        cur_state <= prepare;
    end
    else begin 
        cur_state <= next_state;
    end 
end

always @(*) begin
    if (rst == 1'b1) begin 
        next_state <= prepare;
    end
    else begin 
        if (write_ce) begin 
        case (cur_state)
            prepare:begin
                if (write_ce == 1'b1) next_state <= w0;
                else next_state <= prepare;
            end
            w0:begin
                next_state <= w1;
            end
            w1:begin
                next_state <= w2;
            end
            w2:begin 
                next_state <= w3;
            end
            w3:begin 
                next_state <= w4;
            end
            w4:begin 
                if (read_ce == 1'b1) next_state <= r0;
                else
                if (write_ce == 1'b1) next_state <= w0;
                else next_state <= prepare;
            end
            default:next_state <= w0;
        endcase
        end
        else begin 
            case(cur_state) 
            prepare:begin
                if (read_ce == 1'b1) next_state <= r0;
                else next_state <= prepare;
            end
            r0:begin
                next_state <= r1;
            end
            r1:begin 
                next_state <= r2;
            end
            r2:begin 
                next_state <= r3;
            end
            r3:begin 
                next_state <= r4;
            end
            r4:begin 
                if (read_ce == 1'b1) next_state <= r0;
                else if (write_ce == 1'b1) next_state <= w0;
                else next_state <= prepare;
            end
            default:next_state <= r0;
            endcase
        end
    end
end

always @(posedge clk or posedge rst) begin 
    if (rst == 1'b1) begin 
        oe <= 1'b1;
        we <= 1'b1;
        fin <= 1'b0;
    end
    else begin 
        case (next_state)
        prepare:begin 
            oe <= 1'b1;
            we <= 1'b1;
        end
        r0:begin 
            oe <= 1'b0;
            we <= 1'b1;
            fin <= 1'b0;
        end
        r1:begin 
            oe <= 1'b0;
            fin <= 1'b0;
        end
        r2:begin
            fin <= 1'b1;
        end
        r3:begin 
            oe <= 1'b0;
            fin <= 1'b0;
        end
        r4:begin 
            oe <= 1'b0;
            fin <= 1'b0;
        end
        w0:begin
            oe <= 1'b1;
            we <= 1'b1;
            fin <= 1'b0;
        end
        w1:begin
            we <= 1'b0;
            fin <= 1'b0;
        end
        w2:begin 
            we <= 1'b0;
        end
        w3:begin 
            we <= 1'b0;
        end
        w4:begin
            we <= 1'b1;
            fin <= 1'b1;
        end 
        default:begin 
            oe <= 1'b1;
            we <= 1'b1;
        end
        endcase 
    end
end

assign rom_wdata = (write_ce)?write_data:32'hzzzzzzzz;

endmodule