//重定向 旁路单元
module redirect(
    input [4:0] ex_Rs,
    input [4:0] ex_Rt,
    input [4:0] mem_wb_wreg,
    input mem_wb_RegWrite,
    output control_rdata_a,
    output control_rdata_b
);

always @(*) begin 
    if(mem_wb_RegWrite && mem_wb_wreg != 5'b00000 && ex_Rs == mem_wb_wreg)
        control_rdata_a <= 1'b1;     //数据来自mem/wb阶段写回寄存器的数据
    else 
        control_rdata_a <= 1'b0;
end 

always @(*) begin 
    if(mem_wb_RegWrite && mem_wb_wreg != 5'b00000 && ex_Rd == mem_wb_wreg)
        control_rdata_b <= 1'b1;     //数据来自mem/wb阶段写回寄存器的数据
    else 
        control_rdata_b <= 1'b0;
end 

endmodule