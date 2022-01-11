module top(output [2:0] simon_led0, simon_led1, simon_led2, simon_led3,output [7:0] seg_n,
           output [3:0] an_n, output lcd_regsel, lcd_enable, speaker,
           inout [7:0] lcd_data, input clk, input [3:0] simon_buttons_n, input[1:0] sw
           );

//game variables 
reg[7:0] current_state, next_state;
reg [7:0] player_score;
wire [3:0] F, E, D, C, B, A; 
binary_to_bcd b1(.A(player_score), .ONES(B), .TENS(A));
binary_to_bcd b2(.A(current_state), .ONES(D), .TENS(C)); 
reg [7:0] count; 
reg count_reset; 
reg count_enable; 
reg [2:0] colortone; 
reg [1:0] stored_button; 
reg check; 

//PRNG 
wire [1:0] random; 
reg rerun_en; 
reg randomize_en; 
reg step; 
PRNG(.random(random), .step(step), .rerun(rerun_en), .randomize(randomize_en), .clk(clk), .reset(reset));
binary_to_bcd b3(.A({7'b0000000, step}), .ONES(F), .TENS(E)); 
seg_ctrl(.seg_n(seg_n), .an_n(an_n),
                .D(E),.C(F),.B(C),.A(D), .clk(clk)); 
localparam MAX = 75000000;
reg [27:0] timer_random; 
reg timer_en; 
reg timer_reset; 

// ctrl
wire reset = sw[0]; 



//states
localparam INIT = 1, WELCOME = 2, WAIT_FOR_RELEASE = 3, SIMON_PLAY = 4, SIMON_REST = 5, SIMON_CHECKS = 6, PLAYER_PREP = 7,
PLAYER_PLAY = 8, PLAYER_CHECK = 9, PLAYER_NEXT = 10, PLAYER_FAIL = 11, PLAYER_SUCCESS = 12;

always@(posedge clk) begin 
    if(reset) begin 
        current_state <= INIT; 
    end else begin
        current_state <= next_state; 
    end 
end 


// lcd
reg [8*16-1:0] topline, bottomline;
reg [28:0] timer;
reg lcd_string_print;
wire lcd_string_available;

// simon buttons and debounces
wire simonTLpressed, simonTLheld; 
wire simonTRpressed, simonTRheld; 
wire simonBLpressed, simonBLheld; 
wire simonBRpressed, simonBRheld;
 
debouncer d1 (.pressed(simonTLpressed), .held(simonTLheld), .clk(clk), .btn(~simon_buttons_n[0]), .reset(reset)); 
debouncer d2 (.pressed(simonTRpressed), .held(simonTRheld), .clk(clk), .btn(~simon_buttons_n[1]), .reset(reset)); 
debouncer d3 (.pressed(simonBLpressed), .held(simonBLheld), .clk(clk), .btn(~simon_buttons_n[2]), .reset(reset)); 
debouncer d4 (.pressed(simonBRpressed), .held(simonBRheld), .clk(clk), .btn(~simon_buttons_n[3]), .reset(reset)); 

lcd_string (.lcd_regsel(lcd_regsel), .lcd_enable(lcd_enable), .lcd_data(lcd_data), .available(lcd_string_available), .print(lcd_string_print), .topline(topline), .bottomline(bottomline), .reset(reset), .clk(clk));

// Speaker and color on simon buttons

reg [2:0] tone;
reg SE;
speaker(.speaker(speaker), .tone(tone), .clk(clk), .SE(SE)); 

reg [1:0] color; 
reg color_en;
led_ctrl(.led0(simon_led1), .led1(simon_led0), .led2(simon_led2), .led3(simon_led3), .color(color), .en(color_en), .clk(clk)); 


always @(posedge clk) begin 
   if(reset) begin
    timer_random <= 0; 
   end else begin
   if(timer_reset) begin
    timer_random <= 0;
   end
   else begin
     if(timer_en) begin
        timer_random <= timer_random + 1; 
      end
    end
    end
end

always@(posedge clk) begin 
    if(reset) begin 
        count <= 0; 
    end else begin 
        if (count_reset) begin
            count <= 0; 
        end 
        if(count_enable) begin
            count <= count + 1; 
        end
     end 
 end 

always @* begin 
    if(random == 2'b00) begin
           colortone = 3'b000;
        end else if(random == 2'b01) begin
             colortone = 3'b001;
        end else if(random == 2'b10) begin 
              colortone = 3'b010;
         end else if(random == 2'b11) begin 
             colortone = 3'b011;
         end
end

always @* begin 
    next_state = current_state; 
    topline = 0; 
    bottomline = 0; 
    randomize_en = 0; 
    color_en = 0; 
    SE = 0; 
    color = 0; 
    tone = 0; 
    player_score = 0; 
    lcd_string_print = 0; 
    count_enable = 0; 
    colortone = 0; 
    count_reset = 0; 
    timer_en = 0; 
    timer_reset = 0; 
    check = 0; 
    rerun_en = 0;
    case(current_state) 
    INIT: begin 
        next_state = WELCOME; 
    end
    WELCOME: begin 
        lcd_string_print = 0;
        if (lcd_string_available) begin
            topline    = {" WELCOME, USER! "};
            bottomline = {" GREEN TO PLAY! "};
            lcd_string_print = 1;
        end
        if(simonTLpressed) begin
            randomize_en = 1;
            next_state = WAIT_FOR_RELEASE;
        end
    end
    WAIT_FOR_RELEASE: begin
          next_state = SIMON_PLAY; 
    end
    SIMON_PLAY: begin 
        lcd_string_print = 0;
        if (lcd_string_available) begin
            topline    = {" PLAYING SIMON! "};
            bottomline    = {"SCORE:        ", {4'b0011, A}, {4'b0011, B}};
            lcd_string_print = 1;
        end 
        
        timer_en = 1;   
        timer_reset = 0; 
        if(timer_random == MAX) begin 
          timer_reset = 1; 
          timer_en = 0; 
          count_enable = 1; 
          next_state = SIMON_REST; 
        end
        step = 0; 
         SE = 1;
         color_en = 1;
         color = colortone[1:0];
         tone = colortone;      
        
        
      end
    SIMON_REST: begin
        SE = 0; 
        timer_en = 1; 
        
        if(timer_random == 25000000) begin 
            if(count < player_score + 1) begin //debug change this later
                step = 1;  
                next_state = SIMON_PLAY; 
            end else if(count == player_score + 1) begin 
                next_state = SIMON_CHECKS;  
            end
        end
    end
    SIMON_CHECKS: begin 
        next_state = PLAYER_PREP; 
    end    
    PLAYER_PREP: begin 
        lcd_string_print = 0;
        if (lcd_string_available) begin
            topline    = {"      PLAY      "};
            bottomline    = {"SCORE:        ", {4'b0011, A}, {4'b0011, B}};
            lcd_string_print = 1;
        end
        next_state = PLAYER_PLAY; 
        rerun_en = 1; 
    end
    PLAYER_PLAY: begin 
        if(simonTRheld) begin 
            SE = 1; 
            color_en = 1; 
            color = 2'b00; 
            tone = 3'b000; 
            stored_button = 0; 
            if(stored_button == random) begin
                check = 1; 
            end
        end else if(simonTLheld) begin 
            SE = 1; 
            color_en = 1; 
            color = 2'b01; 
            tone = 3'b001; 
            stored_button = 1;
            if(stored_button == random) begin
                check = 1;
            end 
        end else if (simonBLheld) begin 
            SE = 1; 
            color_en = 1; 
            color = 2'b10; 
            tone = 3'b010; 
            stored_button = 2; 
            if(stored_button == random) begin
                check = 1;
            end
        end else if (simonBRheld) begin 
            SE = 1; 
            color_en = 1; 
            color = 2'b11;
            tone = 3'b011; 
            stored_button = 3; 
            if(stored_button == random) begin
                check = 1;
            end
        end
        if((check == 1) && !(simonTLheld && simonTRheld && simonBRheld && simonBLheld)) begin
            next_state = PLAYER_CHECK; 
        end
    end
    PLAYER_CHECK: begin 
            if(stored_button == random) begin 
                player_score = player_score + 1; 
            end
            lcd_string_print = 0;
            if (lcd_string_available) begin
                topline    = {"      PLAY      "};
                bottomline    = {"SCORE:        ", {4'b0011, A}, {4'b0011, B}};
                lcd_string_print = 1;
            end 
        end
    endcase 
 end
endmodule