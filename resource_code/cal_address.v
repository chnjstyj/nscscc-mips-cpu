module cal_address(
    input [31:0] next_instaddress,
    input [31:0] imme,             //来自于id.v 的imme_num
    output [31:0] jc_instaddress   //有条件跳转指令地址，连接到pc中
);

assign jc_instaddress = next_instaddress + {7'b0000000,imme[25:0],2'b00};

endmodule 