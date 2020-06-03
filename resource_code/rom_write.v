module rom_write(
    input clk,
    input rst,
    input write_ce,
    input [15:0] wdata,
    input [31:0] address,
    output reg [15:0] dout,
    output reg [15:0] din,
    output reg [31:0] rom_addr,
    output reg wfin,
    output reg we,
    output reg ce,
    output reg oe
);

localparam s0 = 2'b00;
localparam s1 = 2'b01;
localparam s2 = 2'b11;
localparam s3 = 2'b10;
reg [1:0] cur_state;
reg [1:0] next_state;
reg state_fin;
integer i;

always @(posedge clk) begin
    if (rst) begin 
        cur_state <= s0;
    end 
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
            else next_state <= s1;
        end 
        s2:begin
            if(state_fin) next_state <= s3;
            else next_state <= s2;
        end 
        s3:begin
            if(state_fin) next_state <= s0;
            else next_state <= s3;
        end
        default: next_state <= s0;
    endcase
end


always @(posedge clk) begin 
    if (rst) begin
        i <= 0;
        we <= 1'b1;
        ce <= 1'b1;
        oe <= 1'b1;
        rom_addr <= 32'h00000000;
        dout <= 16'hxxxx;
        wfin <= 1'b0;
    end 
    else begin 
        case (next_state)
            s0:begin 
                state_fin <= 1'b0;
                i <= 0;
                we <= 1'b1;
                ce <= 1'b1;
                oe <= 1'b1;
                rom_addr <= 32'h00000000;
                wfin <= 1'b0;
                dout <= 16'hxxxx;
            end
            s1:begin 
                    rom_addr <= address;
                    //state_fin <= 1'b0;
                    ce <= 1'b0;
                    we <= 1'b0;
                    state_fin <= 1'b1;
                    i <= 0;
            end  
            s2:begin 
                state_fin <= 1'b0;
                i <= i + 1;
                dout <= 16'hzzzz;
                if(i == 1) begin
                    state_fin <= 1'b1;
                    i <= 0; 
                end
            end
            s3:begin 
                i <= i + 1;
                state_fin <= 1'b0;
                din <= wdata;
                if(i == 5) begin 
                    ce <= 1'b1;
                    we <= 1'b1;
                end 
                if(i == 7) begin 
                    dout <= 16'hxxxx;
                    state_fin <= 1'b1;
                    i <= 0;
                    wfin <= 1'b1;
                end 
            end 
            default:begin 
                i <= 0;
                we <= 1'b1;
                ce <= 1'b1;
                oe <= 1'b1;
                rom_addr <= 32'h00000000;
                dout <= 16'hxxxx;
            end 
        endcase 
    end 
end

endmodule