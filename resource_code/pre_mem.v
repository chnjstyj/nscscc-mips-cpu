module pre_mem(
    input [5:0] opcode,
    output reg [1:0] mem_sel      //0:sc,1:sb,2:sh,3:sb
);

always @(*) begin
    case (opcode)
        6'h28: mem_sel <= 2'b01;       //sb
        6'h38: mem_sel <= 2'b00;       //sc
        6'h29: mem_sel <= 2'b10;       //sh
        6'h2b: mem_sel <= 2'b11;       //sw
        default:mem_sel <= 2'b11;
    endcase
end

endmodule