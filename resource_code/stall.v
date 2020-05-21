module stall(
    input Jump,
    input jmp_reg,               
    input id_Branch,
    input zero_sig,
    input bgtz_sig,
    input ex_RegWrite,
    output reg flush_if_id,
    output reg flush_id_ex,
    output reg flush_ex_memwb,
    output reg stall_pc,
    output reg stall_if_id
    //output reg flush_id_ex,
    //output reg flush_ex_memw
);

always @(*) begin 
    if (!Jump || jmp_reg) stall_if_id <= 1'b1;
    else flush_if_id <= 1'b0;
end

always @(*) begin 
    if(id_Branch && ex_RegWrite) begin        //暂停流水线一个周期
        stall_pc <= 1'b1;
        stall_if_id <= 1'b1;
    end 
    else begin 
        stall_pc <= 1'b0;
        stall_if_id <= 1'b0;
    end 
end 

always @(*) begin 
    if((id_Branch && zero_sig)||bgtz_sig) begin 
        //stall_if_id <= 1'b1;
        //stall_id_ex <= 1'b1;
    end 
    else begin
        //stall_if_id <= 1'b0;
        //stall_id_ex <= 1'b0; 
    end
end

/*        
always @(*) begin 
    if (jmp_reg) stall_id_ex <= 1'b1;
    else stall_id_ex <= 1'b0;
end*/

endmodule 