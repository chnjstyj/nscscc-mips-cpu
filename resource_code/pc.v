module pc(
    input clk,
    input rst,
    input Branch,                  //有条件跳转信号
    input ALU_zerotag,             //ALU零标志位
    input Jump,                    //无条件跳转信号 低电平有效
    input [31:0] imme,             //来自于id.v 的imme_num
    input jmp_reg,                 //jr 信号
    input [31:0] Rrs,                     //R[rs] 寄存器内容
    input [31:0] jc_instaddress,   //有条件跳转指令地址
    input [31:0] id_cur_inst,         //正在执行的指令
    input [31:0] id_next_instaddress,
    input bgtz_sig,
    output reg [31:0] inst_address,
    output [31:0] next_instaddress,
    output reg ce           
);

wire ifbranch;
//wire [31:0] next_instaddress ;


assign Ebranch = Branch && ALU_zerotag;
assign next_instaddress = inst_address + 4'b0100;         //现指令地址+4

always @(posedge clk) begin 
    if(ce == 1'b0) begin 
        inst_address <= 32'h00000000;
    end 
    else if(!Ebranch&&Jump&&!jmp_reg&&!bgtz_sig) begin       //不执行有条件跳转与无条件跳转
        inst_address <= next_instaddress;
    end 
    else if(Ebranch&&Jump) begin                              //执行有条件跳转
        inst_address <= jc_instaddress;          
    end
    else if(bgtz_sig) begin 
        inst_address <= jc_instaddress; 
    end
    else if(jmp_reg) begin 
        inst_address <= Rrs;
    end
    else if (!Jump) begin 
        inst_address <= {id_next_instaddress[31:28],id_cur_inst[25:0],2'b00};
    end 
end

always @(posedge clk) begin 
    if(rst == 1'b0) begin 
        ce <= 1'b0;
    end 
    else begin 
        ce <= 1'b1;
    end
end 

endmodule 
