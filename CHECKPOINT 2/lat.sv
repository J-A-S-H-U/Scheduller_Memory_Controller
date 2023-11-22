module checkpoint2;
typedef struct packed {reg[3:0] core; int req_time; reg[1:0] operation; bit [33:0] address;} my_struct; 
my_struct my_queue[$:15];
my_struct temporary1;
my_struct temporary2;

typedef struct {int operation; bit [33:0] address;} temp_struct; 
temp_struct temporary;


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

longint cpu_clock_count=0;
bit cpu_clock=0;
always #104 cpu_clock=~cpu_clock;

always_ff@(posedge cpu_clock)begin
	cpu_clock_count=cpu_clock_count+1;
	end


function void dram_function();
if(cpu_clock_count == my_queue[0].req_time)begin
	temporary1=my_queue.pop_front();

	byte_select=temporary1.address[1:0];
	cloumn_l=temporary1.address[5:2];
	column_h=temporary1.address[17:12];

	bank=temporary1.address[11:10];
	bank_group=temporary1.address[9:7];
	row=temporary1.address[33:18];
	$display("*************");
	$display("At CPU clock %d DIMM clock %d Request for byte %d bank %d bank group %d and row %d",cpu_clock_count, cpu_clock_count+2, byte_select,bank,bank_group,row);
	end
endfunction
always_ff@(posedge dimm_clock)begin
	dimm_clock_count=dimm_clock_count+1;
	dram_function();
	end





  initial 
  begin
			file_input = "default_trace_file.txt";
			
			if ($value$plusargs("NAME_OF_THE_FILE=%s", file_input) == 0)
				begin
					$display("User has not specified any file. Executing default file: %s", file_input);
				end 
			else 
				begin
					$display("Opening user-specified file: %s", file_input);
				end

 // Open the file for reading
			file = $fopen(file_input, "r");
			if (file == 0)
				begin
					$display("Error: Could not open the file: %s", file_input);
					$finish;
				end
  
  

			`ifdef DEBUG_CODE
				begin
					$display("DEBUG MODE is enabled");
					file = $fopen(file_input, "r");
					if (file == 0) 
						begin
							$display("Error: Could not open the file: %s", file_input);
							$finish;
						end

					while (!$feof(file))
						begin

							parse = $fscanf(file, " %d %d %h %h \n", time_a,core,oop,addr);
							//$display("Time=%0d   Core=%0d  Operation=%0h  Address=%0h",time_a,core,oop,addr);
							temporary2.core=core;
							temporary2.req_time=time_a;
							temporary2.operation=oop;
							temporary2.address=addr;
							my_queue.push_back(temporary2);
							wait (my_queue.size()<16);

						end
		
	
				end
			`else
				begin
					$display("DEBUG MODE is NOT enabled.");
				end
			`endif

			if (file) 
				begin
					$fclose(file);
					$display("File closed.");
				end
				#0294967295 $finish;

end


endmodule