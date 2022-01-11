module PRNG (output [1:0] random, prev1, prev2, prev3, prev4, input step, rerun, randomize, clk,reset);

  LFSR u1 (.random(random[0]), .prev1(prev1[0]), .prev2(prev2[0]), .prev3(prev3[0]), .prev4(prev4[0]), .step(step), .rerun(rerun), .randomize(randomize), .clk(clk), .reset(reset));

  LFSR #(.FILL(16'h0001)) u2 (.random(random[1]), .prev1(prev1[1]), .prev2(prev2[1]), .prev3(prev3[1]), .prev4(prev4[1]), .step(step), .rerun(rerun), .randomize(randomize), .clk(clk), .reset(reset));

endmodule
