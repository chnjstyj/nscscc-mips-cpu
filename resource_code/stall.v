module stall(
    input Jump,
    input jmp_reg,               
    input ex_Branch,
    input zero_sig,
    input bgtz_sig,
    output reg stall_if_id,
    output reg stall_id_ex,
    output reg stall_ex_memwb
);

always @(*) begin 
    if (!Jump || jmp_reg) stall_if_id <= 1'b1;
    else stall_if_id <= 1'b0;
end

always @(*) begin 
    if((ex_Branch && zero_sig)||bgtz_sig) begin 
        stall_if_id <= 1'b1;
        stall_id_ex <= 1'b1;
    end 
    else begin
        stall_if_id <= 1'b0;
        stall_id_ex <= 1'b0; 
    end
end

/*        
always @(*) begin 
    if (jmp_reg) stall_id_ex <= 1'b1;
    else stall_id_ex <= 1'b0;
end*/

endmodule 