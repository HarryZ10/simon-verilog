`define DELAY 50000

module seg_ctrl(output [7:0] seg_n, output reg [3:0] an_n,
                input[3:0] D,C,B,A, input clk);

reg [3:0] hex;
reg [1:0] count;
reg [15:0] delay;

seven_seg s1 (seg_n, hex);

always @ ( posedge clk) begin
  delay <= delay + 1;
  if (delay == `DELAY) begin
    delay <= 0;
    count <= count + 1;
    an_n <= 4'hf;
    an_n[count] <= 0;
    case (count) 
      0: hex <= A; 
      1: hex <= B; 
      2: hex <= C; 
      3: hex <= D;
    endcase
  end
end
endmodule 