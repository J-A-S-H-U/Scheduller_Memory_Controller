module checkpoint2;
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

logic tempbank;
logic tempbankgroup;

reg flag_act0;
reg flag_act1;

reg flag_command0;
reg flag_command1;

reg flag_read;
reg flag_write;

reg flag_pre;

reg flag_pop=1;
reg flag_loop;


longint clock_count=0;
bit clock=0;
always #208 clock=~clock;
always_ff@(posedge clock)
	begin
		clock_count=clock_count+1;
	end

integer temptime1;
integer temptime2;
integer temptime3;
integer temptime4;
		
		
task pop_task();
	begin
		if (flag_pop==1)
			begin
				if(clock_count >= my_queue[0].req_time+2)
					begin
						if(clock_count==temptime4+trp)
						begin
							temporary1=my_queue.pop_front();
							$display( "%d	%d		ACT0 		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], temporary1.address[33:18]); 

				//byte_select=temporary1.address[1:0];
				//column_low=temporary1.address[5:2];
				//column_high=temporary1.address[17:12];

				//bank=temporary1.address[11:10];    
				//bank_group=temporary1.address[9:7];
				//row=temporary1.address[33:18];
							flag_pop=0;
							flag_act1=1;
						
							temptime1= clock_count;
						end
	
					end
			end
		else if (flag_loop==1)
			begin
				if(tempbankgroup == temporary1.address[9:7])
					begin
						if(clock_count>=temptime1+trp && clock_count>=temptime4+trrd_l)
							begin
								temporary1=my_queue.pop_front();
								$display( "%d	%d		ACT0 		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], temporary1.address[33:18]); 
								flag_loop=0;
								flag_act1=1;
								temptime1= clock_count;
							end
					end
			end
				
	end
endtask




task task_act1();
	begin
		if(flag_act1 == 1)
			begin
				if(clock_count == temptime1+2)
					begin
						$display("%d	%d		ACT1 		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], temporary1.address[33:18]);
						temptime2=clock_count;
						flag_act1 = 0;
						flag_command0=1;
					end
			end
	end
endtask

task command0();
	begin
		if(flag_command0==1)
			begin
				if (temporary1.operation==0||temporary1.operation==2)
					begin
						if (clock_count==temptime2+trcd)
							begin
								$display("%d	%d		RD0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
								flag_command1=1;
								flag_command0=0;
								flag_read=1;
								temptime3=clock_count;
							end
					end
				else
					begin
						if (clock_count==temptime2+trcd)
							begin
								$display("%d	%d		WR0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
								flag_command1=1;
								flag_command0=0;
								flag_write=1;
								temptime3=clock_count;
							end
					end
			end
	end
endtask


task command1();
	begin
		if(flag_command1==1)
			begin
				if (flag_read==1)
					begin
						if (clock_count==temptime3+2)
							begin
								$display("%d	%d		RD1		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
								flag_pre=1;
								flag_command1=0;
							end
					end
				else if (flag_write==1)
					begin
						if (clock_count==temptime3+2)
							begin
								$display("%d	%d		WR1		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
								flag_pre=1;
								flag_command1=0;
							end
					end
			end
	end
endtask
		
task precharge();
	begin
		if(flag_pre==1)
			begin
				if (clock_count==temptime1+tras)
					begin
						$display ("%d	%d		PRE		%d		", clock_count, temporary1.core, temporary1.address[9:7]);
						$display("**********************************************");
						
						flag_pre=0;
						flag_loop=1;
						tempbank=temporary1.address[11:10];
						tempbankgroup=temporary1.address[9:7];
						temptime4=clock_count;
					end
			end
	end
endtask

always_ff@(posedge clock)
	begin
		pop_task();
		task_act1();
		command0();
		command1();
		precharge();
	
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