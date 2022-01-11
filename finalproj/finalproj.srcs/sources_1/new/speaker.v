module speaker(output reg speaker, input [2:0] tone, input clk, input SE);
    // initiate counter load
    reg [17:0] ctr;
    reg [17:0] loadvalue;
    // down counter with the counter loads
    always@(posedge clk) begin
        ctr <= ctr - 1;
        if(ctr == 0) begin
            case(tone) 
            3'b000: loadvalue<=227272;
            3'b001: loadvalue<=202478; 
            3'b010: loadvalue<=180384;
            3'b011: loadvalue<=170262;
            3'b100: loadvalue<=151686; 
            3'b101: loadvalue<=135136; 
            3'b110: loadvalue<=120392; 
            3'b111: loadvalue<=113636; 
            default: loadvalue<=227272; 
            endcase
            ctr<=loadvalue; 
        end
    end
    
    
    always @* begin
        if(ctr >= loadvalue / 2) begin 
            speaker = 0; 
        end 
        else begin
            speaker = SE;
        end
    end
    
        
endmodule