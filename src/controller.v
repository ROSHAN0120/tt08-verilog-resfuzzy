
module controller(
    input  clk,rst_n,
    input wire [7:0] rain_fall,     // 8-bit input for rainfall (0 to 100)
    input wire [7:0] soil_moisture, // 8-bit input for soil moisture (0 to 100)
    input ss,
    output ef,
    output [7:0]risk
    );
    
    reg [7:0]r1;
    reg [7:0]r2;
    reg [3:0]count;
    reg efr;
    wire [7:0]rain_w;
    wire [7:0]soil_w;
    
    
    always @(posedge clk) begin    
        if(!rst_n)begin
            r1<=0;
            r2<=0;
            count =4'b0000;
        end
        else begin
            
            case(ss)
                1'b0:begin
                     r1 <= rain_fall ;  
                     count = count+4'b0001;
                     $display("%0t\t%d\t%d", $time,r1,count);
                     end
                1'b1:begin
                     r2 <= soil_moisture;
                     count = count+4'b0001;
                      $display("%0t\t%d\t%d", $time,r2,count);
                     end
            endcase
            
            if(count == 4'b0010)begin
                if (r1 !=0 && r2!=0)begin
                    efr<=1;        
                end
                  count =0; 
            end else begin
                efr<=0;  
                count = count;          
            end
        end      
    end
   assign ef = efr;
   assign rain_w = r1;
   assign soil_w = r2;
      
   fuzzy fuzzy(
    .clk(clk),
    .rst_n(rst_n),
    .ef(ef),
    .rain(rain_w),
    .soil(soil_w),
    .risk(risk)           // 8-bit output risk (0 to 255)
    );
    
    
    
endmodule
