module id(
    input [31:0] inst,
    input RegDst,                 //来自控制信号的regdis
    output [5:0] opcode,
    output [4:0] rreg_a,         //读寄存器1 Rs
    output [4:0] rreg_b,         //读寄存器2 Rt
    output [4:0] wreg,           //写寄存器 Rd
    output [31:0] imme_num,       //立即数
    output [5:0] func,           //指令func段 
    output [4:0] shamt,
    output reg jmp_reg           //jr 信号，连接到pc
);

assign opcode = inst[31:26];
assign rreg_a = inst[25:21];
assign rreg_b = inst[20:16];
assign shamt = inst[10:6];
assign func = inst[5:0];
assign wreg = (RegDst == 1'b0)?inst[20:16]:inst[15:11];
assign imme_num = {{16{inst[15]}},inst[15:0]};       //符号扩展到32位

always @(*) begin 
    if(opcode == 6'h0 && func == 6'h08)
        jmp_reg <= 1'b1;
    else 
        jmp_reg <= 1'b0;
end

endmodule