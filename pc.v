module pc(
    input clk,
    input rst,
    input Branch,                  //??????
    input ALU_zerotag,             //ALU?????
    input [31:0] imme,
    output [31:0] reg inst_address,
    output reg ce           
);

wire ifbranch;
wire [31:0] next_inst_address ;


assign Ebranch = Branch & ALU_zerotag;
assign next_inst_address = inst_address + 4'b0100;         //????+4????

always @(posedge clk) begin 
    if(ce == 1'b0) begin 
        inst_address <= 32'h00000000;
    end 
    else if(!Ebranch) begin                  //???
        inst_address <= next_inst_address;
    end 
    else begin                              //??
        inst_address <= next_inst_address + {7'b0000000,imme[25:0],2'b00};           //??????26?????
    end
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
