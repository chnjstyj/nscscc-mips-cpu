module opcode_control(
    input [5:0] opcode,
    output RegDst,
    output Branch,
    output MemRead,
    output MemtoReg,
    output [3:0] ALUOp,
    output MemWrite,
    output ALUSrc,
    output RegWrite,
    output Jump                    //低电平有效
);

reg [11:0] control_sig;

assign {Jump,RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp} 
    = control_sig;

always @(*) begin
   case (opcode)
       6'b000000: control_sig <= 12'b110010000010;       //R-type
       6'b100011: control_sig <= 12'b101111000000;       //lw
       6'b101011: control_sig <= 12'b111100100000;       //sw
       6'b000100: control_sig <= 12'b100000010001;       //beq
       6'b000010: control_sig <= 12'b000000000000;       //jmp
       6'b001101: control_sig <= 12'b101010000011;       //ori
       6'b101000: control_sig <= 12'b111100100000;       //sb
       6'b101001: control_sig <= 12'b111100100000;       //sh 
       default: control_sig <= 12'b100000000000;
   endcase 
end

endmodule