module TMNT_wrapper (
    input logic clk, nrst,
    
    // Wrapper
    input logic ncs, // Chip Select (Active Low)
    input logic [33:0] gpio_in, // Breakout Board Pins
    output logic [33:0] gpio_out, // Breakout Board Pins
    output logic [33:0] gpio_oeb // Active Low Output Enable
);

    // Reset Synchronizer

    logic ff1, ff2;
    assign gated_reset = ~ncs & nrst;

    always_ff @(posedge clk, negedge gated_reset) begin
        if(~gated_reset) begin
            ff1 <= 1'b0; 
            ff2 <= 1'b0; 
        end
        else begin
            ff1 <= 1'b1; 
            ff2 <= ff1; 
        end

    end

    top_asic DUT
    (
        .clk(clk),
        .nrst(ff2),
        .sigout(gpio_out[15]),
        .mode_out(gpio_out[17:16]),
        .pb(gpio_in[14:0])
    );

    always_comb begin 
        gpio_out[14:0] = 'b0;
        gpio_out[18:33] = 'b0;
        gpio_oeb = {{34{1'b1}}};
        gpio_oeb[17:15] = 'b0;
    end
    
endmodule