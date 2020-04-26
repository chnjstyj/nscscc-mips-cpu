module opcode_control(
    input [5:0] opcode,
    output RegDst,
    output Branch,
    output MemRead,
    output MemtoReg,
    output [1:0] ALUOp,
    output MemWrite,
    output ALUSrc,
    output RegWrite
);

reg [8:0] control_sig;

assign {RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp} 
    = control_sig;

always @(*) begin
   case (opcode)
       6'b000000: control_sig <= 9'b100100010;       //R-type
       6'b100011: control_sig <= 9'b011110000;       //lw
       6'b101011: control_sig <= 9'b111001000;       //sw
       6'b000100: control_sig <= 9'b000000101;       //beq
       default: control_sig <= 9'b000000000;
   endcase 
end