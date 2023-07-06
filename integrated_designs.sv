module intergrated_designs (
    input logic clk, n_rst,

    input logic[3:0] design_select, 
    /* 
    if design select == 0, no design is selected.
    If design_select == 1, design_1 is selected 
    If design_select == 2, design_2 is selected
    ...
    Up to design_12  
    */

    input logic [33:0] gpio_in, 
    
    output logic [33:0] gpio_oeb,
    output logic [33:0] gpio_out
);

logic[33:0] designs_gpio_out[1:12]; // start counting from 1 b/c of the design_select behavior
logic[33:0] designs_gpio_oeb[1:12]; 

logic[12:1] designs_cs; // active low chip select input for the designs.

/* 
    gpio_in signal multiplexing:

    Just pass all 34 gpio_in signals to each of the individual designs.
    
    Nothing will happen when the design is not selected, since all its FFs will its reset signal asserted.

*/


/* 
    gpio_out & gpio_oeb signal multiplexing:

    If design_1 is selected, pass its gpio_out & gpio_oeb outputs. 
    If design_2 is selected, pass its gpio_out & gpio_oeb outputs. 
    ....
    Up to design_12. 


    * NOTE: 

      ALL THE GPIO PINS WILL BE CONFIGURED TO BE INOUT, SO MAKE SURE TO ASSIGN GPIO_OEB VALUES_CORRECTLY. 
      
      IF THERE ARE ANY GPIO PINS THAT ARE NOT USED, YOU CAN SET THEM AS INPUTS BY SETTING "gpio_oeb = 1'b1" SINCE
      THEY ARE ACTIVE LOW. 
      
      FOR THE CORRESPONDING "gpio_out" PORT, YOU CAN JUST SET IT TO 1'b0. 

    *

*/

assign gpio_out = designs_gpio_out[design_select]; 
assign gpio_oeb = designs_gpio_oeb[design_select]; 



/* chip select logic */

always_comb begin
    designs_cs = {12{1'b1}}; // default is off 

    design_cs[design_select] == 1'b0; // turn on the selected design
end




/* For instantiating the designs, use design_1, design_2, ..., design_12 as the instance name */

GuitarVillains_Wrapper design_1
    (
        .clk(clk),
        .n_rst(n_rst),
        .ncs(design_cs[1]), 

        .gpio_in(gpio_in),
        .gpio_out(designs_gpio_out[1]), 
        .gpio_oeb(designs_gpio_oeb[1])
    );

SaSS_wrapper design_2
(
     .clk(clk),
        .n_rst(n_rst),
        .ncs(design_cs[2]), 

        .gpio_in(gpio_in),
        .gpio_out(designs_gpio_out[2]), 
        .gpio_oeb(designs_gpio_oeb[2])
);



endmodule