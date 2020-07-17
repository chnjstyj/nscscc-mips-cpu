module pre_mem(
    input [5:0] opcode,
    output reg [1:0] mem_sel      //0:sc,1:byte,2:half word,3:word
);

always @(*) begin
    case (opcode)
        6'h28: mem_sel <= 2'b01;       //sb
        6'h38: mem_sel <= 2'b00;       //sc
        6'h29: mem_sel <= 2'b10;       //sh
        6'h2b: mem_sel <= 2'b11;       //sw
        6'h24: mem_sel <= 2'b01;       //lbu
        6'h25: mem_sel <= 2'b10;       //lhu
        6'h23: mem_sel <= 2'b11;       //lw
        6'h20: mem_sel <= 2'b01;       //lb
        default:mem_sel <= 2'b11;
    endcase
end

endmodule