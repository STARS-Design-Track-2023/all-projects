module SaSS_wrapper (

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


    sass_synth DESIGN (
        .clk(clk),
        .n_rst(ff2),
        .cs(ncs),

        .piano_keys(gpio_in[14:0]),
        .seq_power(gpio_in[15]),
        .tempo_select(gpio_in[16]),
        .seq_play(gpio_in[17]),

        .mode_out(gpio_out[19:18]),
        .beat_led(gpio_out[27:20]),
        .seq_led_on(gpio_out[28]),

        .pwm_o(gpio_out[29])
    );


    // correctly assign gpio_oeb outputs
    assign gpio_oeb = {{4{1'b1}}, {12{1'b0}}, {18{1'b1}} }; 


    // assign 0s to unused gpio_output pins
    assign {gpio_out[33:30], gpio_out[17:0]} = {22{1'b0}}; 

endmodule