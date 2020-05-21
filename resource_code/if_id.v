module if_id(
    input clk,
    input rst,
    input stall_if_id,    
    input [31:0] if_inst,
    input [31:0] if_cur_instaddress,                    //jal指令用
    input [31:0] if_next_instaddress,            //现指令地址+4的下一条指令地址
    input flush_if_id,                            //流水线气泡
    output reg [31:0] id_inst,
    output reg [31:0] id_cur_instaddress,
    output reg [31:0] id_next_instaddress
);

always @(posedge clk) begin
    if(rst == 1'b0 || flush_if_id == 1'b1) begin
        id_inst <= 32'h00000000;
        id_cur_instaddress <= 32'h00000000;
        id_next_instaddress <= 32'h00000000;
    end
    else if (stall_if_id == 1'b1) begin 
        id_inst <= id_inst;
        id_cur_instaddress <= id_cur_instaddress;
        id_next_instaddress <= id_next_instaddress;
    end
    else begin 
        id_inst <= if_inst;
        id_cur_instaddress <= if_cur_instaddress;
        id_next_instaddress <= if_next_instaddress;
    end 
end

endmodule