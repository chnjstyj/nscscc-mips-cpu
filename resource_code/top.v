module top(
    input wire clk,
    //input rom_clk,
    (* dont_touch = "1" *)input wire rst,
    //drom
    input wire [31:0] rom_rdata,
    output wire [31:0] drom_addr,
    output wire dwrite_ce,
    output wire [31:0] wdata,
    output wire dread_ce,
    input wire rfin_a,
    input wire wfin_a,
    //irom
    output wire iread_ce,
    output wire [31:0] irom_addr,
    input wire [31:0] rom_inst,
    input wire rfin_c,
    //串口相关
    output wire [7:0] uart_wdata,
    output wire uart_write_ce,
    input wire [7:0] uart_rdata,
    output wire clean_recv_flag,
    input wire recv_flag,
    input wire send_flag
);

wire ce;
(* dont_touch = "1" *)wire [31:0] inst_address;
(* dont_touch = "1" *)wire [31:0] cur_inst;
wire [31:0] next_instaddress;
wire [5:0] opcode;
wire [4:0] rreg_a;
wire [4:0] rreg_b;
wire [4:0] wreg;
(* dont_touch = "1" *)wire [31:0] imme_num;
wire [5:0] func;
wire [3:0] alu_control_sig;
wire ALU_zerotag;
wire [4:0] shamt;
(* dont_touch = "1" *)wire bgtz_sig;
(* dont_touch = "1" *)wire zero_sig;

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
//wire unsigned_num;           //暂时不用
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

//branch输入
wire [31:0] pr_rdata_a;
wire [31:0] pr_rdata_b;

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

//流水线气泡模块连线
wire flush_if_id;
wire flush_id_ex;
wire flush_ex_memwb;
wire stall_pc;
wire stall_if_id;

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
wire [31:0] ex_imme_num;
wire [5:0] ex_func;
wire [4:0] ex_shamt;
(* dont_touch = "1" *)wire [5:0] ex_opcode;
wire [31:0] ex_cur_instaddress;
wire [4:0] ex_wreg;
wire [4:0] ex_Rs;
wire [4:0] ex_Rt;
wire ex_greater_than;
wire ex_store_pc;
 
id_ex id_ex(
    .clk(clk),
    .rst(rst),
    .flush_id_ex(flush_id_ex),
    //.id_Branch(Branch),
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
   // .ex_Branch(ex_Branch),
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
(* dont_touch = "1" *)wire [31:0] mem_imme_num;
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
    .Jump(Jump),
    .jmp_reg(jmp_reg),
    .id_Branch(Branch),
    .zero_sig(zero_sig),
    .bgtz_sig(bgtz_sig),
    .ex_RegWrite(ex_RegWrite),
    .flush_if_id(flush_if_id),
    .flush_id_ex(flush_id_ex),
    .flush_ex_memwb(flush_ex_memwb),
    .stall_pc(stall_pc),
    .stall_if_id(stall_if_id)
);

pc pc(
    .clk(clk),
    .rst(rst),
    .Branch(Branch),
    .zero_sig(zero_sig),
    .Jump(Jump),
    .imme(imme_num),
    .jmp_reg(jmp_reg),
    .Rrs(ex_rdata_a),                
    .jc_instaddress(jc_instaddress),
    //.id_cur_inst(id_inst),
    //.id_next_instaddress(id_next_instaddress),
    .jump_address(jump_address),
    .inst_address(inst_address),
    .next_instaddress(next_instaddress),
    .bgtz_sig(bgtz_sig),
    .stall_pc(stall_pc),
    .ce(ce)
);

inst_rom inst_rom(
    .clk(clk),
    .inst_address(inst_address),
    .ce(ce),
    //.data(data),
    .inst(cur_inst),
    .read_ce(iread_ce),
    .irom_addr(irom_addr),
    .rom_inst(rom_inst),
    .rfin_c(rfin_c)
    /*
    .rdata_a(irom_data_a),
    .rdata_b(irom_data_b),
    .rom_addr(irom_addr),
    .rom_ce(irom_ce),
    .we(irom_we),
    .oe(irom_oe)
    */
);

id id(
    .inst(id_inst),
    .next_instaddress(id_next_instaddress[31:28]),
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

pre_branch pre_branch(
    .id_rdata_a(rdata_a),
    .id_rdata_b(rdata_b),
    .mem_wb_dout(mem_wdata),
    .control_rdata_a(control_rdata_a),
    .control_rdata_b(control_rdata_b),
    .rdata_a(pr_rdata_a),
    .rdata_b(pr_rdata_b)
);

branch branch(
    .next_instaddress(id_next_instaddress),          //来自id_ex
    .imme(imme_num),
    .rdata_a(pr_rdata_a),
    .rdata_b(pr_rdata_b),
    .greater_than(greater_than),
    .equal_branch(equal_branch),
    .bgtz_sig(bgtz_sig),
    .zero_sig(zero_sig),
    .jc_instaddress(jc_instaddress)
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
    //.zero_sig(ALU_zerotag),
    .alu_result(alu_result),
    //.unsigned_num(unsigned_num),
   // .equal_branch(ex_equal_branch),
    .shamt(ex_shamt)
    //.greater_than(ex_greater_than),
    //.bgtz_sig(bgtz_sig)
);

alu_control alu_control(
    .func(ex_func),
    .ALUOp(ex_ALUOp),
    .opcode(ex_opcode),
    .alu_control(alu_control_sig)
);

pre_mem pre_mem(
    .opcode(mem_opcode),
    .mem_sel(mem_sel)
);

mem mem(
    .clk(clk),
    .rst(rst),
   // .rom_clk(rom_clk),
    .alu_result(mem_alu_result),
    .din(mem_rdata_b),            //来自寄存器堆的第二个读出数据
    .MemWrite(mem_MemWrite),
    .MemRead(mem_MemRead),
    .MemtoReg(mem_MemtoReg),
    .dout(mem_wdata),
    .mem_sel(mem_sel),
    .lui_sig(mem_lui_sig),
    .imme(mem_imme_num),            //来自id阶段的立即数
    .drom_addr(drom_addr),
    .write_ce(dwrite_ce),
    .wdata(wdata),
    .read_ce(dread_ce),
    .rom_rdata(rom_rdata),
    .wfin_a(wfin_a),
    .rfin_a(rfin_a),
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
    .control_rdata_b(control_rdata_b)
);
/*
always @(*) begin 
    if (inst_address == 32'h00000000) data <= 32'h34010001;
    else if (inst_address == 32'h00000004) data <= 32'h34020001;
end*/

endmodule