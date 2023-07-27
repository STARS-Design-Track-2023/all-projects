`timescale 1ns/1ps
module tb_integrated_designs ();

 //tb signals
    parameter CLK_PERIOD = 100;
    reg tb_clk, tb_nrst;
    wire [3:0] tb_design_select;
    wire [33:0] tb_gpio_in, tb_gpio_oeb, tb_gpio_out;


   // Task for standard DUT reset procedure
    task reset_dut;
    begin
        // Activate the reset
        tb_nrst = 1'b0;

        // Maintain the reset for more than one cycle
        @(posedge tb_clk);
        @(posedge tb_clk);

        // Wait until safely away from the rising edge of the clock before releasing
        @(negedge tb_clk);
        tb_nrst = 1'b1;

        // Leave out of reset for a couple cycles before allowing other stimulus
        @(negedge tb_clk);
        @(negedge tb_clk);
    end
    endtask

    //Task for setting inactive values
    task inactive;
    begin
        @(negedge tb_clk);
        tb_nrst = 1;
        tb_design_select = 0;
        tb_gpio_in = 'b0;
    end 
    endtask

    // ************************************************************************
    // Task: Triple-SSS
    // ************************************************************************
    task WAIT (
        input integer cycles
    );
    	integer i;
        begin
            for (i = 0; i < cycles; i = i + 1) begin
                @(posedge tb_clk);
            end
        end
    endtask

    task FEED_INPUTS (
        input [16:0] gpio
    );
        begin
            @(negedge tb_clk);
            tb_gpio_in[16:0] = gpio;
        end
    endtask

    task ASSERT_OUTPUTS (
        input pwm
    );
        begin
            TEST_NUMBER = TEST_NUMBER + 1;
            @(negedge tb_clk);
            if (tb_pwm != pwm) begin
                $error("Test %d Failed", TEST_NUMBER);
                $error("Expected: %b", pwm);
                $error("Actual: %b", tb_pwm);
                TESTS_FAILED = TESTS_FAILED + 1;
            end else begin
                $info("Test %d Passed", TEST_NUMBER);
                TESTS_PASSED = TESTS_PASSED + 1;
            end
        end
    endtask
    //***********************************************************************


   // 10 MHz Clock
    always begin
        // Start with clock low to avoid false rising edge events at t=0
        tb_clk = 1'b0;
        // Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
        #(CLK_PERIOD/2.0);
        tb_clk = 1'b1;
        // Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
        #(CLK_PERIOD/2.0);
    end


    
    /* --------- SDF annotation to simulate time for the verilog model -------- */
    `ifdef ENABLE_SDF
    initial begin
        $sdf_annotate("mapped/synth.sdf", DUT,,);
    end
    `endif
    /* ------ Please do not modify this code should be there in every tb ------ */
    initial begin
        $dumpfile ("dump.vcd");
        $dumpvars;
    end

    /* --- Port Map (One for gl sim and the other for RTL sim) --- */
    `ifdef USE_POWER_PINS
    integrated_designs DUT
    (
        .VPWR(1),
        .VGND(0),
        .clk(tb_clk),
        .n_rst(tb_nrst),
        .design_select(tb_design_select),
        .gpio_in(tb_gpio_in),
        .gpio_out(tb_gpio_out),
        .gpio_oeb(tb_gpio_oeb)
    );
    `else
    integrated_designs DUT
    (
        .clk(tb_clk),
        .n_rst(tb_nrst),
        .design_select(tb_design_select),
        .gpio_in(tb_gpio_in),
        .gpio_out(tb_gpio_out),
        .gpio_oeb(tb_gpio_oeb)
    );
    `endif
    /* -------------------------- END ---------------------------- */

    initial begin
        //intialize inputs
        inactive;
        reset_dut;

        if(design_select == 1) begin
            repeat(10) @(posedge tb_clk);
            @(negedge tb_clk);
            tb_pb0 = 1;
            @(negedge tb_clk);
            @(negedge tb_clk);
            @(negedge tb_clk);
            @(negedge tb_clk);
            tb_pb0 = 0;
            repeat(700000000)@(posedge tb_clk);

        end 

        else if(design_select == ) begin
            ASSERT_OUTPUTS(1'b0);
            // END TEST 1

            FEED_INPUTS(17'b0);
            WAIT(10);
            FEED_INPUTS(17'b00010000000000000);
            WAIT(10);
            FEED_INPUTS(17'b0);
            WAIT(10);
            FEED_INPUTS(17'b00000000000000001);
            WAIT(10);
            FEED_INPUTS(17'b0);
            WAIT(10);

        
        end  

        $finish;
    end 
    
endmodule
