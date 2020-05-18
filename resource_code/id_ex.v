module id_ex(
    input clk,
    input rst,
    input id_Branch,
    input id_MemRead,
    input id_MemtoReg,
    input [3:0] id_ALUOp,
    input id_MemWrite,
    input id_ALUSrc,
    input id_RegWrite,
    input id_equal_branch,
    input id_store_pc,
    input id_lui_sig,
    input [31:0] id_next_instaddress,
    input [31:0] id_rdata_a,        //Rs读出数据
    input [31:0] id_rdata_b,        //Rt读出数据
    input [31:0] id_imme_num,
    input [5:0] id_func,
    input [4:0] id_shamt,
    input [5:0] id_opcode,
    input [31:0] id_cur_instaddress,
    input [4:0] id_wreg,           //Rd
    input [4:0] id_Rs,
    input [4:0] id_Rt,
    output reg ex_Branch,
    output reg ex_MemRead,
    output reg ex_MemtoReg,
    output reg [3:0] ex_ALUOp,
    output reg ex_MemWrite,
    output reg ex_ALUSrc,
    output reg ex_RegWrite,
    output reg ex_equal_branch,
    output reg ex_store_pc,
    output reg ex_lui_sig,           
    output reg [31:0] ex_next_instaddress,
    output reg [31:0] ex_rdata_a,
    output reg [31:0] ex_rdata_b,
    output reg [31:0] ex_imme_num,
    output reg [5:0] ex_func,
    output reg [4:0] ex_shamt,
    output reg [5:0] ex_opcode,
    output reg [31:0] ex_cur_instaddress,
    output reg [4:0] ex_wreg,
    output reg [4:0] ex_Rs,
    output reg [4:0] ex_Rt
);

always @(posedge clk) begin 
        if(rst == 1'b0) begin 
            ex_Branch <= 1'b0;
            ex_MemRead <= 1'b0;
            ex_MemtoReg <= 1'b0;
            ex_ALUOp <= 4'b0000;
            ex_MemWrite <= 1'b0;
            ex_ALUSrc <= 1'b0;
            ex_RegWrite <= 1'b0;
            ex_equal_branch <= 1'b0;
            ex_store_pc <= 1'b0;
            ex_lui_sig <= 1'b0;
            ex_next_instaddress <= 32'h00000000;
            ex_rdata_a <= 32'h00000000;
            ex_rdata_b <= 32'h00000000;
            ex_imme_num <= 32'h00000000;
            ex_func <= 6'b000000;
            ex_shamt <= 5'b00000;
            ex_opcode <= 6'b000000;
            ex_cur_instaddress <= 32'h00000000;
            ex_wreg <= 5'b00000;
            ex_Rs <= 5'b00000;
            ex_Rt <= 5'b00000;
        end 
        else begin 
            ex_Branch <= id_Branch;
            ex_MemRead <= id_MemRead;
            ex_MemtoReg <= id_MemtoReg;
            ex_ALUOp <= id_ALUOp;
            ex_MemWrite <= id_MemWrite;
            ex_ALUSrc <= id_ALUSrc;
            ex_RegWrite <= id_RegWrite;
            ex_equal_branch <= id_equal_branch;
            ex_store_pc <= id_store_pc;
            ex_lui_sig <= id_lui_sig;
            ex_next_instaddress <= id_next_instaddress;
            ex_rdata_a <= id_rdata_a;
            ex_rdata_b <= id_rdata_b;
            ex_imme_num <= id_imme_num;
            ex_func <= id_func;
            ex_shamt <= id_shamt;
            ex_opcode <= id_opcode;
            ex_cur_instaddress <= id_cur_instaddress;
            ex_wreg <= id_wreg;
            ex_Rs <= id_Rs;
            ex_Rt <= id_Rt;
        end 
end

endmodule 
