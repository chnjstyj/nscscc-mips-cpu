module stall(
    input rst,
    input stall_mem,
    input stall_dram,
    input Jump,
    input jmp_reg,               
    input id_Branch,
   // (* dont_touch = "1" *)input zero_sig,
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
    //output reg flush_id_ex,
    //output reg flush_ex_memw
);
/*
always @(*) begin
    flush_id_ex <= 1'b0;
    flush_ex_memwb <= 1'b0;
end
*/
/*
assign flush_if_id = !Jump || jmp_reg;
assign flush_id_ex = 1'b0;
assign flush_ex_memwb = 1'b0;
assign stall_pc = (id_Branch && ex_RegWrite) || stall_mem;
assign stall_if_id = (id_Branch && ex_RegWrite) || stall_mem;
assign stall_id_ex = stall_mem;
assign stall_ex_memwb = stall_mem;*/


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
        if ((id_Branch && ex_RegWrite)||stall_mem||stall_pc_flush_if_id||stall_dram) stall_pc <= 1'b1;
        else stall_pc <= 1'b0;
        if ((id_Branch && ex_RegWrite)||stall_mem||stall_dram) stall_if_id <= 1'b1;
        else stall_if_id <= 1'b0;
        if (stall_mem||stall_dram) stall_id_ex <= 1'b1;
        else stall_id_ex <= 1'b0;
        if (stall_mem||stall_dram) stall_ex_memwb <= 1'b1;
        else stall_ex_memwb <= 1'b0;
        flush_id_ex <= 1'b0;
        flush_ex_memwb <= 1'b0;
        /*

        if(stall_mem) begin 
            stall_pc <= 1'b1;
            stall_if_id <= 1'b1;
            stall_id_ex <= 1'b1;
            stall_ex_memwb <= 1'b1;
        end
        else
       
        if(id_Branch && ex_RegWrite) begin        //暂停流水线一个周期
            stall_pc <= 1'b1;
            stall_if_id <= 1'b1;
            //flush_id_ex <= 1'b1;
        end 
        else begin
            stall_pc <= 1'b0;
            stall_if_id <= 1'b0;
            stall_id_ex <= 1'b0;
            stall_ex_memwb <= 1'b0;
        end*/
    end
end 

/*
always @(*) begin         //延迟槽相关代码
    if((id_Branch && zero_sig)||bgtz_sig) begin 
        //stall_if_id <= 1'b1;
        //stall_id_ex <= 1'b1;
    end 
    else begin
        //stall_if_id <= 1'b0;
        //stall_id_ex <= 1'b0; 
    end
end*/

/*        
always @(*) begin 
    if (jmp_reg) stall_id_ex <= 1'b1;
    else stall_id_ex <= 1'b0;
end*/

endmodule 