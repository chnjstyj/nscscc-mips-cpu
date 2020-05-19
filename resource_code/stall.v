module stall(
    input Jump,
    input jmp_reg,               //À´×Ôex½×¶Î
    output reg stall_if_id,
    output reg stall_id_ex,
    output reg stall_ex_memwb
);

always @(*) begin 
    if (!Jump || jmp_reg) stall_if_id <= 1'b1;
    else stall_if_id <= 1'b0;
end

/*        
always @(*) begin 
    if (jmp_reg) stall_id_ex <= 1'b1;
    else stall_id_ex <= 1'b0;
end*/

endmodule 