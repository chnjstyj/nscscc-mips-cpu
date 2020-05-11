module opcode_control(
    input [5:0] opcode,
    output RegDst,
    output Branch,
    output MemRead,
    output MemtoReg,
    output [2:0] ALUOp,
    output MemWrite,
    output ALUSrc,
    output RegWrite,
    output Jump                    //低电平有效
);

reg [10:0] control_sig;

assign {Jump,RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp} 
    = control_sig;

always @(*) begin
   case (opcode)
       6'b000000: control_sig <= 11'b11001000010;       //R-type
       6'b100011: control_sig <= 11'b10111100000;       //lw
       6'b101011: control_sig <= 11'b11110010000;       //sw
       6'b000100: control_sig <= 11'b10000001001;       //beq
       6'b000010: control_sig <= 11'b00000000000;       //jmp
       6'b001101: control_sig <= 11'b10101000011;       //ori
       default: control_sig <= 11'b10000000000;
   endcase 
end

endmodule