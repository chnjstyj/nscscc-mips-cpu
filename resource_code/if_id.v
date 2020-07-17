module if_id(
    input clk,
    input rst,
    input stall_if_id,    
    (* dont_touch = "1" *)input [31:0] if_inst,
    (* dont_touch = "1" *)input [31:0] if_cur_instaddress,                    //jal指令用
    (* dont_touch = "1" *)input [31:0] if_next_instaddress,            //现指令地址+4的下一条指令地址
    input flush_if_id,                            //流水线气泡
    (* dont_touch = "1" *)output reg [31:0] id_inst,
    (* dont_touch = "1" *)output reg [31:0] id_cur_instaddress,
    (* dont_touch = "1" *)output reg [31:0] id_next_instaddress
);

always @(posedge clk or posedge rst) begin
    if(rst == 1'b1) begin
        id_inst <= 32'h00000000;
        id_cur_instaddress <= 32'h80000000;
        id_next_instaddress <= 32'h80000004;
    end
    else if (stall_if_id == 1'b0) begin 
        if (flush_if_id == 1'b1) begin
            id_inst <= 32'h00000000;
            id_cur_instaddress <= 32'h80000000;
            id_next_instaddress <= 32'h80000004;
        end
        else begin 
            id_inst <= if_inst;
            id_cur_instaddress <= if_cur_instaddress;
            id_next_instaddress <= if_next_instaddress;
        end
    end 
end

endmodule