module regs(
    input clk,
    input rst,
    input [4:0] rreg_a,
    input [4:0] rreg_b,
    input [4:0] wreg,
    input [31:0] wdata,        //写入寄存器的数据
    input RegWrite,            //寄存器写控制信号
    input [31:0] inst_address,       //jal 指令用
    input store_pc,                  //jal指令用信号
    output reg [31:0] rdata_a,
    output reg [31:0] rdata_b
);
reg [31:0] regs[0:31];

initial regs[0] = 32'h00000000;     //寄存器值初始化为0


//写操作，在时钟边沿完成写操作
always @(posedge clk) begin 
    if(rst != 1'b0) begin 
        if(RegWrite == 1'b1&& wreg != 5'b00000 ) begin     //不能对寄存器0写值
            regs[wreg] <= wdata;
        end
    end 
    else begin
        regs[wreg] <= regs[wreg];
    end
end


//读操作无需在时钟边沿
//读寄存器1

always @(*) begin 
    if(rst == 1'b0) begin 
        rdata_a <= 32'h00000000;
    end 
    else if(rreg_a == wreg && RegWrite) begin       //数据直通
        rdata_a <= wdata;
    end
    else begin
        rdata_a <= regs[rreg_a];
    end
end
//读寄存器2

always @(*) begin 
    if(rst == 1'b0) begin 
        rdata_b <= 32'h00000000;
    end 
    else if(rreg_b == wreg && RegWrite) begin 
        rdata_b <= wdata;
    end
    else begin 
        rdata_b <= regs[rreg_b];
    end
end

always @(posedge clk) begin 
    if (store_pc) begin
        regs[31] <= inst_address + 3'd8;            //pc+8
    end
    else begin 
        regs[31] <= regs[31];
    end 
end


endmodule
