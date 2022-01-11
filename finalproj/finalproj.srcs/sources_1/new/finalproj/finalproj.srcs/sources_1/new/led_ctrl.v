module led_ctrl(output reg[2:0] led0, led1, led2, led3, input [1:0] color, input en, clk); 
    localparam  RED=3'b001, GREEN=3'b010, BLUE=3'b100, YELLOW=3'b011, BLACK=3'b000;
    reg [18:0] timer; 
    always @* begin 
    if(timer < 25000) begin 
        led0 = RED; 
        led1 = GREEN; 
        led2 = BLUE; 
        led3 = YELLOW; 
    end else begin 
        led0 = BLACK; 
        led1 = BLACK; 
        led2 = BLACK; 
        led3 = BLACK; 
    end
    
    if(en) begin 
        case(color) 
            0: led0 = RED; 
            1: led1 = GREEN; 
            2: led2 = BLUE;
            3: led3 = YELLOW; 
        endcase     
    end
 end
 
    always@(posedge clk) begin 
        timer <= timer + 1; 
        if(timer > 500000 - 1) begin 
            timer <= 0; 
        end
    end
endmodule 