module checkpoint2;
typedef struct {integer core, integer req_time, integer operation, bit [33:0] address} my_struct; 
my_struct my_queue[$:15];

typedef struct {int operation, bit [33:0] address} temp_struct; 


string file_input;
string line;
	
integer file;
integer parse;

int core;
int time_a;
int oop;
bit [33:0] addr;

logic [1:0] byte_select;
logic [3:0] cloumn_l;
logic [5:0] column_h;
logic [9:0] column;
logic [1:0] bank;
logic [2:0] bank_group;
logic channel;
logic [15:0]row;

longint dimm_clock_count=0;
bit dimm_clock=0;
always #52 dimm_clock=~dimm_clock;

always_ff@(posedge dimm_clock)begin
	dimm_clock_count=dimm_clock_count+1;
	end

longint cpu_clock_count=0;
bit cpu_clock=0;
always #104 cpu_clock=~cpu_clock;

always_ff@(posedge dimm_clock)begin
	cpu_clock_count=cpu_clock_count+1;
	end



  initial begin

file_input = "default_trace_file.txt";

  
    if ($value$plusargs("NAME_OF_THE_FILE=%s", file_input) == 0) begin
      $display("User has not specified any file. Executing default file: %s", file_input);
    end else begin
      $display("Opening user-specified file: %s", file_input);
    end

 // Open the file for reading
    file = $fopen(file_input, "r");
    if (file == 0) begin
      $display("Error: Could not open the file: %s", file_input);
      $finish;
    end
  
  

`ifdef DEBUG_CODE
begin
	$display("DEBUG MODE is enabled");

    file = $fopen(file_input, "r");
    if (file == 0) begin
      $display("Error: Could not open the file: %s", file_input);
      $finish;
    end

while (!$feof(file))
        begin

        parse = $fscanf(file, " %d %d %h %h \n", time_a,core,oop,addr);

    $display("Time=%0d   Core=%0d  Operation=%0h  Address=%0h",time_a,core,oop,addr);
	my_queue.push_back(parse);

        end
while(1)begin
	if(cpu_clock_count==my_queue.req_time)begin
	temp_struct.address=my_queue.pop_front(address);
	temp_struct.operation=my_queue.pop_front(operation);
	byte_select=temp_struct.address[1:0];
	cloumn_l=temp_struct.address[5:2];
	column_h=temp_struct.address[17:12];
	column={column_h,column_l};
	bank=temp_struct.address[11:10];
	bank_group=temp_struct.address[9:10];
	row=temp_struct.address[33:18];
	$display("%b", byte_select);
	end
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

endmodule
