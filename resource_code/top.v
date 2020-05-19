module top(
    input clk,
    input rst
);

wire ce;
wire [31:0] inst_address;
wire [31:0] cur_inst;
wire [31:0] next_instaddress;
wire [5:0] opcode;
wire [4:0] rreg_a;
wire [4:0] rreg_b;
wire [4:0] wreg;
wire [31:0] imme_num;
wire [5:0] func;
wire [3:0] alu_control_sig;
wire ALU_zerotag;
wire [4:0] shamt;

//id阶段控制信号
wire RegDst;
wire Branch;
wire MemRead;
wire MemtoReg;
wire [3:0] ALUOp;
wire MemWrite;
wire ALUSrc;
wire RegWrite;
wire Jump;                    //低电平有效
wire unsigned_num;           //暂时不用
wire equal_branch;
wire store_pc;
wire lui_sig;

//ex阶段控制信号
wire jmp_reg;                //jr 信号线

//地址计算结果
wire [31:0] jc_instaddress;

//寄存器堆读出数据
wire [31:0] rdata_a;
wire [31:0] rdata_b;

//alu输入
wire [31:0] alu_rdata_a;
wire [31:0] alu_rdata_b;

//alu计算结果
wire [31:0] alu_result;

//储存器片选信号
wire [1:0] mem_sel;

//储存器读出数据 //寄存器写入地址 寄存器写入信号
wire [31:0] mem_wdata;
/*wire [4:0] wb_wreg;
wire wb_RegWrite;*/

//旁路相关连线
wire control_rdata_a;
wire control_rdata_b;

//流水线气泡模块
wire stall_if_id;
wire stall_id_ex;
wire stall_ex_memwb;
stall stall(
    .Jump(Jump),
    .jmp_reg(jmp_reg),
    .stall_if_id(stall_if_id),
    .stall_id_ex(stall_id_ex),
    .stall_ex_memwb(stall_ex_memwb)
);

//流水线相关模块与连线
//if_id
wire [31:0] id_inst;
wire [31:0] id_next_instaddress;
wire [31:0] id_cur_instaddress;
if_id if_id(
    .clk(clk),
    .rst(rst),
    .if_inst(cur_inst),
    .if_next_instaddress(next_instaddress),
    .if_cur_instaddress(inst_address),
    .stall_if_id(stall_if_id),
    .id_inst(id_inst),
    .id_next_instaddress(id_next_instaddress),
    .id_cur_instaddress(id_cur_instaddress)
);

//id_ex
wire ex_Branch;
wire ex_MemRead;
wire ex_MemtoReg;
wire [3:0] ex_ALUOp;
wire ex_MemWrite;
wire ex_ALUSrc;
wire ex_RegWrite;
wire ex_equal_branch;
wire ex_lui_sig;
wire [31:0] ex_next_instaddress;
wire [31:0] ex_rdata_a;
wire [31:0] ex_rdata_b;
wire [31:0] ex_imme_num;
wire [5:0] ex_func;
wire [4:0] ex_shamt;
wire [5:0] ex_opcode;
wire [31:0] ex_cur_instaddress;
wire [4:0] ex_wreg;
wire [4:0] ex_Rs;
wire [4:0] ex_Rt;
 
id_ex id_ex(
    .clk(clk),
    .rst(rst),
    .stall_id_ex(stall_id_ex),
    .id_Branch(Branch),
    .id_MemRead(MemRead),
    .id_MemtoReg(MemtoReg),
    .id_ALUOp(ALUOp),
    .id_MemWrite(MemWrite),
    .id_ALUSrc(ALUSrc),
    .id_RegWrite(RegWrite),
    .id_equal_branch(equal_branch),
    .id_store_pc(store_pc),
    .id_lui_sig(lui_sig),
    .id_next_instaddress(id_next_instaddress),
    .id_rdata_a(rdata_a),
    .id_rdata_b(rdata_b),
    .id_imme_num(imme_num),
    .id_func(func),
    .id_shamt(shamt),
    .id_opcode(opcode),
    .id_cur_instaddress(id_cur_instaddress),
    .id_wreg(wreg),
    .id_Rs(rreg_a),
    .id_Rt(rreg_b),
    .ex_Branch(ex_Branch),
    .ex_MemRead(ex_MemRead),
    .ex_MemtoReg(ex_MemtoReg),
    .ex_ALUOp(ex_ALUOp),
    .ex_MemWrite(ex_MemWrite),
    .ex_ALUSrc(ex_ALUSrc),
    .ex_RegWrite(ex_RegWrite),
    .ex_equal_branch(ex_equal_branch),
    .ex_store_pc(ex_store_pc),
    .ex_lui_sig(ex_lui_sig),
    .ex_next_instaddress(ex_next_instaddress),
    .ex_rdata_a(ex_rdata_a),
    .ex_rdata_b(ex_rdata_b),
    .ex_imme_num(ex_imme_num),
    .ex_func(ex_func),
    .ex_shamt(ex_shamt),
    .ex_opcode(ex_opcode),
    .ex_cur_instaddress(ex_cur_instaddress),
    .ex_wreg(ex_wreg),
    .ex_Rs(ex_Rs),
    .ex_Rt(ex_Rt)
);

//ex_mem
wire mem_lui_sig;
wire mem_MemRead;
wire mem_MemWrite;
wire mem_MemtoReg;
wire mem_RegWrite;
wire [31:0] mem_alu_result;
wire [31:0] mem_rdata_b;
wire [5:0] mem_opcode;
wire [31:0] mem_imme_num;
wire [4:0] mem_wreg;
ex_mem ex_mem(
    .clk(clk),
    .rst(rst),
    .ex_lui_sig(ex_lui_sig),
    .ex_MemRead(ex_MemRead),
    .ex_MemWrite(ex_MemWrite),
    .ex_MemtoReg(ex_MemtoReg),
    .ex_RegWrite(ex_RegWrite),
    .ex_alu_result(alu_result),
    .ex_rdata_b(ex_rdata_b),
    .ex_opcode(ex_opcode),
    .ex_imme_num(ex_imme_num),
    .ex_wreg(ex_wreg),
    .mem_lui_sig(mem_lui_sig),
    .mem_MemRead(mem_MemRead),
    .mem_MemWrite(mem_MemWrite),
    .mem_MemtoReg(mem_MemtoReg),
    .mem_RegWrite(mem_RegWrite),
    .mem_alu_result(mem_alu_result),
    .mem_rdata_b(mem_rdata_b),
    .mem_opcode(mem_opcode),
    .mem_imme_num(mem_imme_num),
    .mem_wreg(mem_wreg)
);

pc pc(
    .clk(clk),
    .rst(rst),
    .Branch(ex_Branch),
    .ALU_zerotag(ALU_zerotag),
    .Jump(Jump),
    .imme(imme_num),
    .jmp_reg(jmp_reg),
    .Rrs(ex_rdata_a),                
    .jc_instaddress(jc_instaddress),
    .id_cur_inst(id_inst),
    .id_next_instaddress(id_next_instaddress),
    .inst_address(inst_address),
    .next_instaddress(next_instaddress),
    .ce(ce)
);

inst_reg inst_reg(
    .clk(clk),
    .inst_address(inst_address),
    .ce(ce),
    .inst(cur_inst)
);

id id(
    .inst(id_inst),
    .RegDst(RegDst),
    .opcode(opcode),
    .rreg_a(rreg_a),
    .rreg_b(rreg_b),
    .wreg(wreg),
    .imme_num(imme_num),
    .func(func),
    .shamt(shamt),
    .jmp_reg
);

opcode_control opcode_control(
    .opcode(opcode),
    .RegDst(RegDst),
    .Branch(Branch),
    .MemRead(MemRead),
    .MemtoReg(MemtoReg),
    .ALUOp(ALUOp),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite),
    .Jump(Jump),
    .equal_branch(equal_branch),
    .store_pc(store_pc),
    .lui_sig(lui_sig)
);

regs regs(
    .clk(clk),
    .rst(rst),
    .rreg_a(rreg_a),
    .rreg_b(rreg_b),
    .wreg(mem_wreg),
    .wdata(mem_wdata),
    .RegWrite(mem_RegWrite),
    .rdata_a(rdata_a),
    .rdata_b(rdata_b),
    .inst_address(ex_cur_instaddress),
    .store_pc(ex_store_pc)
);

pre_alu pre_alu(
    .ex_rdata_a(ex_rdata_a),
    .ex_rdata_b(ex_rdata_b),
    .mem_wb_dout(mem_wdata),
    .control_rdata_a(control_rdata_a),
    .control_rdata_b(control_rdata_b),
    .rdata_a(alu_rdata_a),
    .rdata_b(alu_rdata_b)
);

alu alu(
    .data_a(alu_rdata_a),
    .data_b(alu_rdata_b),
    .imme(ex_imme_num),
    .ALUSrc(ex_ALUSrc),
    .alu_control(alu_control_sig),
    .zero_sig(ALU_zerotag),
    .alu_result(alu_result),
    .unsigned_num(unsigned_num),
    .equal_branch(ex_equal_branch),
    .shamt(ex_shamt)
);

alu_control alu_control(
    .func(ex_func),
    .ALUOp(ex_ALUOp),
    .opcode(ex_opcode),
    .alu_control(alu_control_sig)
);

cal_address cal_address(
    .next_instaddress(ex_next_instaddress),          //来自id_ex
    .imme(ex_imme_num),
    .jc_instaddress(jc_instaddress)
);

pre_mem pre_mem(
    .opcode(mem_opcode),
    .mem_sel(mem_sel)
);

mem mem(
    .clk(clk),
    .alu_result(mem_alu_result),
    .din(mem_rdata_b),            //来自寄存器堆的第二个读出数据
    .MemWrite(mem_MemWrite),
    .MemRead(mem_MemRead),
    .MemtoReg(mem_MemtoReg),
    .dout(mem_wdata),
    .mem_sel(mem_sel),
    .lui_sig(mem_lui_sig),
    //.mem_wreg(mem_wreg),
    //.mem_RegWrite(mem_RegWrite),
    //.wb_RegWrite(wb_RegWrite),
    //.wb_wreg(wb_wreg),
    .imme(mem_imme_num)            //来自id阶段的立即数
);

redirect redirect(
    .ex_Rs(ex_Rs),
    .ex_Rt(ex_Rt),
    .mem_wb_wreg(mem_wreg),
    .mem_wb_RegWrite(mem_RegWrite),
    .control_rdata_a(control_rdata_a),
    .control_rdata_b(control_rdata_b)
);

endmodule