module checkpoint1;
string file_input;
string line;
														
integer file;
integer parse;
										
int core;
int time_a;
int oop;
bit [35:0] addr;


  initial begin

file_input = "default_trace_file.txt";

    
    if ($value$plusargs("NAME_OF_THE_FILE=%s", file_input) == 0) begin
      $display("User has not specified any file. Executing default file: %s", file_input);
    end else begin
      $display("Opening user-specified file: %s", file_input);
    end


    file = $fopen(file_input, "r");
    if (file == 0) begin
      $display("Error: Could not open the file: %s", file_input);
      $finish;
    end
  
  

`ifdef DEBUG_CODE
begin
	$display("DEBUG MODE is enabled");
 // Open the file for reading
    file = $fopen(file_input, "r");
    if (file == 0) begin
      $display("Error: Could not open the file: %s", file_input);
      $finish;
    end

while (!$feof(file))
        begin

        parse = $fscanf(file, " %d %d %h %h \n", time_a,core,oop,addr);

    $display("Time=%0d   Core=%0d  Operation=%0h  Address=%0h",time_a,core,oop,addr);

        end 
end
`else
$display("DEBUG MODE is NOT enabled.");
`endif

    if (file) begin
      $fclose(file);
      $display("File closed.");
    end

    $finish;
  end
endmodule
