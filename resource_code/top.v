module top(
    input wire clk,
    (* dont_touch = "1" *)input wire rst,
    output wire ce,
    input wire stall_mem,
    //drom
    input wire [31:0] ram_rdata,
    output wire [31:0] dram_write_addr,
    output wire [31:0] dram_read_addr,
    output wire dwrite_ce,
    output wire [31:0] wdata,
    output wire dread_ce,
    //irom
    output wire iread_ce,
    output wire [31:0] iram_addr,
    input wire [31:0] ram_inst,
    input wire irom_fin,
    //串口相关
    output wire [7:0] uart_wdata,
    output wire uart_write_ce,
    input wire [7:0] uart_rdata,
    output wire clean_recv_flag,
    input wire recv_flag,
    input wire send_flag
);
(* dont_touch = "1" *)wire [31:0] inst_address;
(* dont_touch = "1" *)wire [31:0] cur_inst;
wire [31:0] next_instaddress;
wire [5:0] opcode;
wire [4:0] rreg_a;
wire [4:0] rreg_b;
wire [4:0] wreg;
wire [15:0] imme_num;
wire [5:0] func;
wire [3:0] alu_control_sig;
wire ALU_zerotag;
wire [4:0] shamt;
(* dont_touch = "1" *)wire bgtz_sig;
wire Ebranch;
wire stall_pc_flush_if_id;

//id阶段控制信号
wire [31:0] jump_address;
wire RegDst;
wire Branch;
wire MemRead;
wire MemtoReg;
wire [3:0] ALUOp;
wire MemWrite;
wire ALUSrc;
wire RegWrite;
wire Jump;                    //低电平有效
wire equal_branch;
wire store_pc;
wire lui_sig;
wire greater_than;

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

//储存器延迟
wire stall_dram;

//储存器读出数据 //寄存器写入地址 寄存器写入信号
wire [31:0] mem_wdata;

//旁路相关连线
wire control_rdata_a;
wire control_rdata_b;
wire [31:0] Rrs;

//流水线气泡模块连线
wire flush_if_id;
wire flush_id_ex;
wire flush_ex_memwb;
wire stall_pc;
wire stall_if_id;
wire stall_id_ex;
wire stall_ex_memwb;

//流水线相关模块与连线
//if_id
wire [31:0] id_inst;
wire [31:0] id_next_instaddress;
wire [31:0] id_cur_instaddress;
if_id if_id(
    .clk(clk),
    .rst(rst),
    .stall_if_id(stall_if_id),
    .if_inst(cur_inst),
    .if_next_instaddress(next_instaddress),
    .if_cur_instaddress(inst_address),
    .flush_if_id(flush_if_id),
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
wire [15:0] ex_imme_num;
wire [5:0] ex_func;
wire [4:0] ex_shamt;
(* dont_touch = "1" *)wire [5:0] ex_opcode;
wire [31:0] ex_cur_instaddress;
wire [4:0] ex_wreg;
wire [4:0] ex_Rs;
wire [4:0] ex_Rt;
wire ex_greater_than;
wire ex_store_pc;
wire ex_Ebranch;
wire [31:0] ex_jc_instaddress;
 
id_ex id_ex(
    .clk(clk),
    .rst(rst),
    .flush_id_ex(flush_id_ex),
    .stall_id_ex(stall_id_ex),
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
    .id_greater_than(greater_than),
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
    .ex_Rt(ex_Rt),
    .ex_greater_than(ex_greater_than)
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
wire [15:0] mem_imme_num;
wire [4:0] mem_wreg;
ex_mem ex_mem(
    .clk(clk),
    .rst(rst),
    .stall_ex_memwb(stall_ex_memwb),
    .ex_lui_sig(ex_lui_sig),
    .ex_MemRead(ex_MemRead),
    .ex_MemWrite(ex_MemWrite),
    .ex_MemtoReg(ex_MemtoReg),
    .ex_RegWrite(ex_RegWrite),
    .ex_alu_result(alu_result),
    .ex_rdata_b(alu_rdata_b),
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

//流水线气泡模块
stall stall(
    .stall_mem(stall_mem),
    .stall_dram(stall_dram),
    .stall_pc_flush_if_id(stall_pc_flush_if_id),
    .Jump(Jump),
    .jmp_reg(jmp_reg),
    .id_Branch(Branch),
    .mem_read_ce(dread_ce),
    .mem_write_ce(dwrite_ce),
    .bgtz_sig(bgtz_sig),
    .ex_RegWrite(ex_RegWrite),
    .flush_if_id(flush_if_id),
    .flush_id_ex(flush_id_ex),
    .flush_ex_memwb(flush_ex_memwb),
    .stall_pc(stall_pc),
    .stall_if_id(stall_if_id),
    .stall_id_ex(stall_id_ex),
    .stall_ex_memwb(stall_ex_memwb)
);

pc pc(
    .clk(clk),
    .rst(rst),
    .Ebranch(Ebranch),
    .Jump(Jump),
    .imme(imme_num),
    .jmp_reg(jmp_reg),
    .Rrs(Rrs),                
    .jc_instaddress(jc_instaddress),
    .jump_address(jump_address),
    .inst_address(inst_address),
    .next_instaddress(next_instaddress),
    .bgtz_sig(bgtz_sig),
    .stall_pc(stall_pc),
    .ce(ce)
);

inst_rom inst_rom(
    .inst_address(inst_address),
    .clk(clk),
    .stall_pc(stall_pc),
    .rst(rst),
    .stall_pc_flush_if_id(stall_pc_flush_if_id),
    .inst(cur_inst),
    .read_ce(iread_ce),
    .irom_addr(iram_addr),
    .ram_inst(ram_inst),
    .irom_fin(irom_fin)
);

id id(
    .inst(id_inst),
    .next_instaddress(id_next_instaddress),
    .RegDst(RegDst),
    .opcode(opcode),
    .rreg_a(rreg_a),
    .rreg_b(rreg_b),
    .wreg(wreg),
    .imme_num(imme_num),
    .func(func),
    .shamt(shamt),
    .jmp_reg(jmp_reg),
    .jump_address(jump_address)
);

opcode_control opcode_control(
    .opcode(opcode),
    .rst(rst),
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
    .lui_sig(lui_sig),
    .greater_than(greater_than)
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
    .store_pc(ex_store_pc),
    .next_instaddress(id_next_instaddress),          //来自if_id
    .imme(imme_num),                                 //
    .greater_than(greater_than),
    .equal_branch(equal_branch),
    .bgtz_sig(bgtz_sig),
    .Branch(Branch),
    .Ebranch(Ebranch),
    .jc_instaddress(jc_instaddress)
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
    .imme(ex_imme_num),                           //有符号扩展 无符号扩展
    .ALUSrc(ex_ALUSrc),
    .alu_control(alu_control_sig),
    .alu_result(alu_result),
    .shamt(ex_shamt)
);

alu_control alu_control(
    .func(ex_func),
    .ALUOp(ex_ALUOp),
    .alu_control(alu_control_sig)
);

pre_mem pre_mem(
    .opcode(mem_opcode),
    .mem_sel(mem_sel)
);

mem mem(
    .clk(clk),
    .rst(rst),
    .stall_dram(stall_dram),
    .alu_result(mem_alu_result),
    .din(mem_rdata_b),            //来自寄存器堆的第二个读出数据
    .MemWrite(mem_MemWrite),
    .MemRead(mem_MemRead),
    .MemtoReg(mem_MemtoReg),
    .dout(mem_wdata),
    .mem_sel(mem_sel),
    .lui_sig(mem_lui_sig),
    .imme(mem_imme_num),            //来自id阶段的立即数
    .dram_read_addr(dram_read_addr),
    .dram_write_addr(dram_write_addr),
    .write_ce(dwrite_ce),
    .wdata(wdata),
    .read_ce(dread_ce),
    .ram_rdata(ram_rdata),
    .uart_wdata(uart_wdata),
    .uart_write_ce(uart_write_ce),
    .uart_rdata(uart_rdata),
    .clean_recv_flag(clean_recv_flag),
    .recv_flag(recv_flag),
    .send_flag(send_flag)
);

redirect redirect(
    .ex_Rs(ex_Rs),
    .ex_Rt(ex_Rt),
    .mem_wb_wreg(mem_wreg),
    .mem_wb_RegWrite(mem_RegWrite),
    .control_rdata_a(control_rdata_a),
    .control_rdata_b(control_rdata_b),
    .ex_alu_result(alu_result),
    .ex_RegWrite(ex_RegWrite),
    .ex_wreg(ex_wreg),
    .id_rreg_a(rreg_a),
    .id_jmp_reg(jmp_reg),
    .id_rdata_a(rdata_a),
    .Rrs(Rrs)
);

endmodule