module ex_mem(
    input clk,
    input rst,
    input ex_lui_sig,
    input ex_MemRead,
    input ex_MemWrite,
    input ex_MemtoReg,
    input ex_RegWrite,
    input [31:0] ex_alu_result,
    input [31:0] ex_rdata_b,
    input [5:0] ex_opcode,
    input [31:0] ex_imme_num,
    input [4:0] ex_wreg,
    output reg mem_lui_sig,
    output reg mem_MemRead,
    output reg mem_MemWrite,
    output reg mem_MemtoReg,
    output reg mem_RegWrite,
    output reg [31:0] mem_alu_result,
    output reg [31:0] mem_rdata_b,
    output reg [5:0] mem_opcode,
    output reg [31:0] mem_imme_num,
    output reg [4:0] mem_wreg
);

always @(posedge clk) begin 
        if(rst == 1'b0) begin 
            mem_lui_sig <= 1'b0;
            mem_MemRead <= 1'b0;
            mem_MemWrite <= 1'b0;
            mem_MemtoReg <= 1'b0;
            mem_RegWrite <= 1'b0;
            mem_alu_result <= 32'h00000000;
            mem_rdata_b <= 32'h00000000;
            mem_opcode <= 6'b000000;
            mem_imme_num <= 32'h00000000;
            mem_wreg <= 5'b00000;
        end 
        else begin 
            mem_lui_sig <= ex_lui_sig;
            mem_MemRead <= ex_MemRead;
            mem_MemWrite <= ex_MemWrite;
            mem_MemtoReg <= ex_MemtoReg;
            mem_RegWrite <= ex_RegWrite;
            mem_alu_result <= ex_alu_result;
            mem_rdata_b <= ex_rdata_b;
            mem_opcode <= ex_opcode;
            mem_imme_num <= ex_imme_num;
            mem_wreg <= ex_wreg;
        end
end
endmodule 