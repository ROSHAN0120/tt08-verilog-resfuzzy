module fuzzy(
    input  clk,rst_n,ef,
    input wire [7:0] rain,     // 8-bit input for rainfall (0 to 100)
    input wire [7:0] soil, // 8-bit input for soil moisture (0 to 100)
    output reg [7:0] risk           // 8-bit output risk (0 to 255)
);

    // Membership functions for rainfall
    reg [7:0] rain_low;
    reg [7:0] rain_medium;
    reg [7:0] rain_high;

    // Membership functions for soil moisture
    reg [7:0] soil_moisture_low;
    reg [7:0] soil_moisture_medium;
    reg [7:0] soil_moisture_high;

    // Fuzzy rules
    reg [7:0] rule1_firing_strength;
    reg [7:0] rule2_firing_strength;
    reg [7:0] rule3_firing_strength;

    // Defuzzification components
    reg [15:0] numerator;
    reg [7:0] denominator;
    reg [15:0]save; 

    // Fuzzification: Triangular membership functions
    function [7:0] triangular_membership;
        input [7:0] value;
        input [7:0] a;
        input [7:0] b;
        input [7:0] c;
        begin
            if (value <= a)
                triangular_membership = 0;
            else if (value <= b)
                triangular_membership = (value - a) * 255 / (b - a);  // Fixed-point scaling for simplicity
            else if (value <= c)
                triangular_membership = (c - value) * 255 / (c - b);
            else
                triangular_membership = 0;
        end
    endfunction

    // Rainfall fuzzy sets
    always @(ef) begin
        if (!rst_n)begin
             risk <= 0;       
        end
        else begin
             rain_low <= triangular_membership(rain, 0, 20, 40);
             rain_medium <= triangular_membership(rain, 30, 50, 70);
             rain_high <= triangular_membership(rain, 60, 80, 100);
        
            // Soil moisture fuzzy sets
             soil_moisture_low <= triangular_membership(soil, 0, 20, 40);
             soil_moisture_medium <= triangular_membership(soil, 30, 50, 70);
             soil_moisture_high <= triangular_membership(soil, 60, 80, 100);
        
            // Fuzzy rules:
            // Rule 1: IF rainfall is high AND soil moisture is high THEN risk is high
             rule1_firing_strength <= rain_high & soil_moisture_high;
        
            // Rule 2: IF rainfall is medium AND soil moisture is medium THEN risk is medium
             rule2_firing_strength <= rain_medium & soil_moisture_medium;
        
            // Rule 3: IF rainfall is low AND soil moisture is low THEN risk is low
             rule3_firing_strength <= rain_low & soil_moisture_low;
        
            // Defuzzification (Weighted Average)
             numerator <= rule1_firing_strength * 255 + rule2_firing_strength * 170 + rule3_firing_strength * 85;
             denominator <= rule1_firing_strength + rule2_firing_strength + rule3_firing_strength;

        end
    // Calculate risk (avoid division by zero)
//    always @(*)
    
        if (denominator != 0)begin
            save = numerator / denominator;
            risk = save[7:0];
        end
        else
            risk = 0; // Default value if no rules fire
    end

endmodule
