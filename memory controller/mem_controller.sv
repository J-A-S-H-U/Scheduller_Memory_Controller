module mem_controller;
typedef struct packed {reg[3:0] core; int req_time; reg[1:0] operation; bit [33:0] address;} my_struct; 
my_struct my_queue[$:15];
my_struct temporary1;
my_struct temporary2;

//typedef struct {int operation; bit [33:0] address;} temp_struct; 
//temp_struct temporary;


string file_input;
string line;
string out;
	
integer file;
integer file_out;
integer parse;

int core;
int time_a;
int oop;
bit [33:0] addr;

logic [1:0] byte_select;
logic [3:0] column_low;
logic [5:0] column_high;
logic [9:0] column;
logic [1:0] bank;
logic [2:0] bank_group;
logic channel;
logic [15:0]row;

parameter trc = 115;
parameter tras = 76;
parameter trrd_l = 12;
parameter trrd_s = 8;
parameter trp = 39;
//parameter trfc = 295;
parameter cwl = 38;
parameter tcas = 40;
parameter trcd = 39;
parameter twr = 30;
parameter trtp = 18;
parameter tccd_l = 12;
parameter tccd_s = 8;
parameter tccd_l_wr = 48;
parameter tccd_s_wr = 8;
parameter tburst = 8;
parameter tccd_l_rtw = 16;
parameter tccd_s_rtw = 16;
parameter tccd_l_wtr = 16;
parameter tccd_s_wtr = 16;

bit flag_act0=0;
bit flag_act1=0;
bit flag_rd0=0;
bit flag_rd1=0;
bit flag_wr0=0;
bit flag_wr1=0;


longint clock_count=0;
bit clock=0;
always #208 clock=~clock;
always_ff@(posedge clock)
	begin
		clock_count=clock_count+1;
	end

longint temptime1;
longint temptime2;
		
		
task pop_task();
	begin
		if(clock_count >= my_queue[0].req_time)
			begin
				temporary1=my_queue.pop_front();

				byte_select=temporary1.address[1:0];
				column_low=temporary1.address[5:2];
				column_high=temporary1.address[17:12];

				bank=temporary1.address[11:10];
				bank_group=temporary1.address[9:7];
				row=temporary1.address[33:18];
				flag_act0=1;
				$display("pop task initiated %b",flag_act0);
				temptime1= my_queue[0].req_time;
				`ifdef DEBUG_CODE
					$display("DEBUG MODE ENABLED");
					$display("*************");
					$display("Request at CPU clock %d output at CPU clock %d Request for byte %d bank %d bank group %d and row %h column %h", clock_count, clock_count, byte_select,bank,bank_group,row, {column_high,column_low});
				`endif
	
			end
	end
endtask




task task_act1();
	begin
		if(clock_count == temptime1+4)
			begin
				$display("%d ACT0 %d %d %h", clock_count, bank_group, bank, row);
				//flag_act1=0;
				temptime2=clock_count;
			    if (temporary1.operation ==  0 || temporary1.operation == 2)
					begin
						flag_rd0=1;
					end
				else
					begin
						flag_wr0=1;
					end
			end
	end
endtask

always_ff@(posedge clock)
	begin
		pop_task();
		
		if (flag_act0==1)
			begin
				$display("entering task_act0 %b", flag_act0);
				task_act0();
				flag_act0=0;
				$display("%b", flag_act0);
			end
			
		if (flag_act1==1)
			begin
				$display("entering rask_act1 %b", flag_act1);
				task_act1();
				flag_act1=0;
			end
	
	end
	

task task_act0();
	begin
		if(clock_count == temptime1+2)
			begin
				$display("%d ACT0 %d %d %h", clock_count, bank_group, bank, row);
				flag_act1=1;
				//flag_act0=0;
			end
	end
endtask
	


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
				
            out = "default_output_file.txt";
			
			if ($value$plusargs("NAME_OF_THE_OUTPUT_FILE=%s", out) == 0)
				begin
					$display("User has not specified any output file. Executing default file: %s", out);
				end 
			else 
				begin
					$display("Opening user-specified file: %s", out);
				end
 // Open the file for reading
			file = $fopen(file_input, "r");
			file_out=$fopen(out,"w");
			if (file == 0 && file_out)
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
						
						

	
	



#0294967295 $finish;

end

endmodule