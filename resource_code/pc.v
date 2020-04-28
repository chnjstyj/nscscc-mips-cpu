module pc(
    input clk,
    input rst,
    input Branch,                  //有条件跳转信号
    input ALU_zerotag,             //ALU零标志位
    input Jump,                    //无条件跳转信号 低电平有效
    input [31:0] imme,             //来自于id.v 的imme_num
    input [31:0] cur_inst,         //正在执行的指令
    output [31:0] reg inst_address,
    output reg ce           
);

wire ifbranch;
wire [31:0] next_inst_address ;


assign Ebranch = Branch & ALU_zerotag;
assign next_inst_address = inst_address + 4'b0100;         //现指令地址+4

always @(posedge clk) begin 
    if(ce == 1'b0) begin 
        inst_address <= 32'h00000000;
    end 
    else if(!Ebranch&Jump) begin                  //不执行有条件跳转与无条件跳转
        inst_address <= next_inst_address;
    end 
    else if(Ebranch&Jump) begin                              //执行有条件跳转
        inst_address <= next_inst_address + {7'b0000000,imme[25:0],2'b00};           //??????26?????
    end
    else if (!Jump) begin 
        inst_address <= {next_inst_address[31:28],cur_inst[25:0],2'b00};
end 

always @(posedge clk) begin 
    if(rst == 1'b1) begin 
        ce <= 1'b0;
    end 
    else begin 
        ce <= 1'b1;
    end
end 

endmodule 
