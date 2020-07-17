module rom_rw(
    input clk,
    input rst,
    input read_ce,
    input write_ce,
    input [31:0] write_data,         //写入数据
    input [19:0] addr,
    inout [31:0] rom_rdata,
    output reg [31:0] rom_wdata,
    output wire[19:0] rom_addr,
    output wire ce,
    output reg we,
    output reg oe,
    output reg [31:0] read_data         //读出数据
);
/*
wire [31:0] rom_data_read;
reg [31:0] rom_data_write;
assign rom_data = (write_ce == 1'b1)? rom_data_write:32'hzzzzzzzz;
assign rom_data_read = rom_data;*/

assign rom_addr = addr;

//assign oe = (read_ce == 1'b1)?1'b0:1'b1;
//assign we = (write_ce == 1'b1)?1'b0:1'b1;
assign ce = (write_ce | read_ce == 1'b1)?1'b0:1'b1;
//内存写

localparam w0 = 3'b000;
localparam w1 = 3'b001;
localparam w2 = 3'b011;
localparam w3 = 3'b010;
localparam r0 = 3'b100;
localparam r1 = 3'b101;
localparam r2 = 3'b111;
localparam r3 = 3'b110;
reg [2:0] cur_state;
reg [2:0] next_state;
reg state_fin;
integer i;

always @(posedge clk or posedge rst) begin
    if (rst) begin 
        cur_state <= w0;
    end 
    else 
        cur_state <= next_state;
end

always @(*) begin 
    case (cur_state)
        w0:begin 
            if(write_ce) next_state = w1;
            else if (read_ce) next_state = r1;
            else next_state = w0;
        end
        w1:begin 
            if(state_fin) next_state = w2;
            else next_state = w1;
        end 
        w2:begin
            if(state_fin) next_state = w3;
            else next_state = w2;
        end 
        w3:begin
            if(state_fin) next_state = w0;
            else next_state = w3;
        end
        r0:begin 
            if(write_ce) next_state = w1;
            else if (read_ce) next_state = r1;
            else next_state = r0;
        end
        r1:begin 
            if(state_fin) next_state = r2;
            else next_state = r1;
        end 
        r2:begin
            if(state_fin) next_state = r3;
            else next_state = r2;
        end 
        r3:begin
            if(state_fin) next_state = r0;
            else next_state = r3;
        end
        default: next_state = w0;
    endcase
end


always @(posedge clk or posedge rst) begin 
    if (rst) begin
        i <= 0;
        //ce <= 1'b1;
        oe <= 1'b1;
        we <= 1'b1;
        state_fin <= 1'b0;
    end 
    else begin 
        case (next_state)
            w0:begin 
                state_fin <= 1'b0;
                i <= 0;
                //wfin <= 1'b0;
                //ce <= 1'b1;
                oe <= 1'b1;
                we <= 1'b1;
                rom_wdata <= 32'hzzzzzzzz;
            end
            w1:begin
                //ce <= 1'b0;
                we <= 1'b0;
                //rom_wdata <= write_data;
                state_fin <= 1'b1;
                i <= 0;
            end  
            w2:begin
                if (i == 0) begin
                    rom_wdata <= write_data;
                    state_fin <= 1'b0;
                    i <= i + 1;
                end
                else begin
                state_fin <= 1'b1;
                rom_wdata <= write_data;
                we <= 1'b1;
                end
            end
            w3:begin 
                //we <= 1'b1;
                state_fin <= 1'b1; 
            end 
            r0:begin
                //ce <= 1'b1;
                oe <= 1'b1;
                we <= 1'b1;
                state_fin <= 1'b1;
            end
            r1:begin
                oe <= 1'b0;
                //ce = 1'b0;
                i <= 0;
                state_fin <= 1'b1;
            end
            r2:begin
                 if (i == 0) begin
                    state_fin <= 1'b0;
                    i <= i + 1;
                    //read_data <= rom_rdata;
                 end
                 else begin
                    //i <= 0;
                    state_fin <= 1'b1;
                    oe <= 1'b1;
                    read_data <= rom_rdata;
                 end
            end
            r3:begin 
                //oe <= 1'b1;
                //ce <= 1'b1;
                state_fin <= 1'b1;
                //read_data <= rom_rdata;
            end
            default:begin 
                i <= 0;
                state_fin <= 1'b0;
               // i <= 0;
                //wfin <= 1'b0;
                //ce <= 1'b1;
                oe <= 1'b1;
                we <= 1'b1;
                rom_wdata <= 32'h00000000;
            end 
        endcase 
    end 
end



endmodule