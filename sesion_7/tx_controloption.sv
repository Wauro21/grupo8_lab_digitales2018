module tx_control(
    input logic clk, reset,tx_busy,
    input logic trigger,
    input logic [15:0] raw_data,
    output logic tx_start,
    output logic [7:0] tx_data,
    //temporal
    output logic [2:0] id
    );
    
    //Declaracion estados modulo
    enum logic [2:0] {IDLE,Wait_register,Send_0, Wait1, Send_1, Wait2} state, next_state;
    assign  id  =   state;
    
    //Logica interna
    logic [15:0] temp_data, next_data; //Registro del resultado
    logic next_start;
    always_comb begin
        //defaults
        next_state  =   state;
        next_start = 1'b0;
        next_data   =   temp_data; //revisar
        tx_next     =   tx_data;
        
        case(state)
            IDLE:   begin
                if (trigger) begin
                    next_state  =   Wait_register;
                    end
                end
            Wait_register:  begin        
                next_data   =   raw_data;
                next_state  =   Send_0;
                end        
            Send_0: begin
                next_start    =   1'b1;
                tx_next     =   temp_data[7:0];
                if (tx_start == 1'b1) begin
                     next_state = Wait1;   
                end
                end
            Wait: begin
                if (~tx_busy) begin
                    next_state = Send_1; 
                end
            end
            Send_1: begin
                
                next_start    =   1'b1;
                tx_next     =   temp[15:8];
                if (tx_start == 1'b1) begin
                     next_state = Wait2;   
                end
                end
            endcase
            Wait2: begin
                if (~tx_busy) begin
                   next_state = IDLE; 
                end
            end
    end
    
    always_ff @(posedge clk) begin
        if(reset) begin
            state       <=  IDLE;
            end
        else begin
        temp_data   <=  next_data;  
        state           <=  next_state;  
        tx_data         <=  tx_next;
        tx_start <= next_start;
        end
    end
            
endmodule
