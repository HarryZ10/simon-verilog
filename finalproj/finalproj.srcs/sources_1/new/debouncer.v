module debouncer(
    output pressed, held, input clk, btn, reset
    );
    
    localparam sample_time = 1999998;
    reg [20:0] timer;
    
    reg btn_samp, btn_deb, btn_deb_d;
   
    // Timer
    always @(posedge clk) begin
        if (reset) begin
            timer <= sample_time;
        end
        else begin
            timer <= timer - 1;
            if (timer == 0) begin
                timer <= sample_time;
            end
        end
     end
     
     // Button debounced
     always @(posedge clk) begin
        btn_deb_d <= btn_deb;
        
        if (timer == 0) begin
            btn_samp <= btn;
            if (btn == btn_samp) begin
                btn_deb <= btn;
            end
        end
     end
     
     // Assigns which value is button held, pressed. and released
     assign held = btn_deb;
     assign pressed = btn_deb & ~btn_deb_d;
     assign released = ~btn_deb & btn_deb_d;
      
endmodule
