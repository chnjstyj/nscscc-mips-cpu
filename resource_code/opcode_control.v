module opcode_control(
    input [5:0] opcode,
    output RegDst,
    output Branch,
    output MemRead,
    output MemtoReg,
    output [1:0] ALUOp,
    output MemWrite,
    output ALUSrc,
    output RegWrite，
    output Jump                    //低电平有效
);

reg [8:0] control_sig;

assign {Jump,RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp} 
    = control_sig;

always @(*) begin
   case (opcode)
       6'b000000: control_sig <= 10'b1100100010;       //R-type
       6'b100011: control_sig <= 10'b1011110000;       //lw
       6'b101011: control_sig <= 10'b1111001000;       //sw
       6'b000100: control_sig <= 10'b1000000101;       //beq
       6'b000010: control_sig <= 10'b0000000000;       //jmp
       default: control_sig <= 10'b1000000000;
   endcase 
end