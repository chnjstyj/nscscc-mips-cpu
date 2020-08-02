module stall(
    input rst,
    input stall_mem,
    input stall_dram,
    input Jump,
    input jmp_reg,               
    input id_Branch,
    input mem_read_ce,
    input mem_write_ce,
    (* dont_touch = "1" *)input bgtz_sig,
    input stall_pc_flush_if_id,
    input ex_RegWrite,
    output reg flush_if_id,
    output reg flush_id_ex,
    output reg flush_ex_memwb,
    output reg stall_pc,
    output reg stall_if_id,
    output reg stall_id_ex,
    output reg stall_ex_memwb
);
wire mem_crash;
assign mem_crash = mem_read_ce && mem_write_ce;

always @(*) begin 
    if (rst == 1'b1) begin 
        flush_if_id <= 1'b0;
        flush_id_ex <= 1'b0;
        flush_ex_memwb <= 1'b0;
        stall_pc <= 1'b0;
        stall_if_id <= 1'b0;
        stall_id_ex <= 1'b0;
        stall_ex_memwb <= 1'b0;
    end
    else begin 
        if (!Jump || jmp_reg || stall_pc_flush_if_id) flush_if_id <= 1'b1;
        else flush_if_id <= 1'b0;
        if ((id_Branch && ex_RegWrite)||stall_mem||stall_pc_flush_if_id||stall_dram||mem_crash) stall_pc <= 1'b1;
        else stall_pc <= 1'b0;
        if ((id_Branch && ex_RegWrite)||stall_mem||stall_dram||mem_crash) stall_if_id <= 1'b1;
        else stall_if_id <= 1'b0;
        if (stall_mem||stall_dram||mem_crash) stall_id_ex <= 1'b1;
        else stall_id_ex <= 1'b0;
        if (stall_mem||stall_dram||mem_crash) stall_ex_memwb <= 1'b1;
        else stall_ex_memwb <= 1'b0;
        flush_id_ex <= 1'b0;
        flush_ex_memwb <= 1'b0;
    end
end 

/*
always @(*) begin         //ÑÓ³Ù²ÛÏà¹Ø´úÂë
    if((id_Branch && zero_sig)||bgtz_sig) begin 
        //stall_if_id <= 1'b1;
        //stall_id_ex <= 1'b1;
    end 
    else begin
        //stall_if_id <= 1'b0;
        //stall_id_ex <= 1'b0; 
    end
end*/


endmodule 