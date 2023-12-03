module memory_controller;
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

logic[1:0] tempbank;
logic[2:0] tempbankgroup;

int Tras, Trc, Trp, Trrd_l, Trrd_s;

reg flag_act0;
reg flag_act1;

reg flag_command0;
reg flag_command1;

reg flag_read;
reg flag_write;

reg flag_pre;

reg flag_pop=1;

reg flag_previous_read;
reg flag_previous_write;

reg flag_loop;
reg flag_loop_act1;
reg flag_loop_command0;

integer temptime1;
integer temptime2;
integer temptime3;
integer temptime4;
integer temptime5;


longint clock_count=0;
longint temp_clock_count;
bit clock=0;
always #1 clock=~clock;
always@(clock)
	begin
		clock_count=clock_count+1;
	end
		
		
task pop_task();
	begin
		if (flag_pop==1)
			begin
				if(clock_count >= my_queue[0].req_time+2)
					begin
							temporary1=my_queue.pop_front();
							$fdisplay( file_out,"%d		%d		ACT0 		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], temporary1.address[33:18]); 

							flag_pop=0;
							flag_act1=1;
						
							temptime1= clock_count;
	
					end
			end
		else if (flag_loop==1)
			begin
				if(tempbankgroup == temporary1.address[9:7])
					begin
						if(clock_count>=temptime5+trp && clock_count>=temptime2+trrd_l)
							begin
								if (clock_count>=my_queue[0].req_time+2)
								begin
								temporary1=my_queue.pop_front();
								//$display("%t %d", $time, my_queue.size());
								$fdisplay(file_out, "%d		%d		ACT0 		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], temporary1.address[33:18]); 
								flag_loop=0;
								flag_loop_act1=1;
								temptime1= clock_count;
								end
							end
					end
				else if (tempbankgroup != temporary1.address[9:7])
					begin
						if (clock_count>=temptime5+trp && clock_count>=temptime2+trrd_s)
							begin
								if (clock_count>=my_queue[0].req_time+2)
								begin
								temporary1=my_queue.pop_front();
								//$display("%t %d", $time, my_queue.size());
								$fdisplay( file_out,"%d		%d		ACT0 		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], temporary1.address[33:18]); 
								flag_loop=0;
								flag_loop_act1=1;
								temptime1= clock_count;
								end
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
						//$display("operation = %d", temporary1.operation);
						$fdisplay(file_out,"%d		%d		ACT1 		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], temporary1.address[33:18]);
						temptime2=clock_count;
						flag_act1 = 0;
						flag_command0=1;
						/*Tras=clock_count;
						Trc=clock_count;
						Trrd_l=clock_count;
						Trrd_s=clock_count;*/
					end
			end
		else if (flag_loop_act1==1)
			begin
				if(clock_count == temptime1+2)
					begin
						//$display("operation = %d", temporary1.operation);
						$fdisplay(file_out,"%d		%d		ACT1 		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], temporary1.address[33:18]);
						temptime2=clock_count;
						flag_loop_act1 = 0;
						flag_loop_command0=1;
						
						/*Tras=clock_count;
						Trc=clock_count;
						Trrd_l=clock_count;
						Trrd_s=clock_count;*/
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
								$fdisplay(file_out,"%d		%d		RD0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
								flag_command1=1;
								flag_command0=0;
								flag_read=1;
								flag_write = 0;
								temptime3=clock_count;
							end
					end
				else
					begin
						if (clock_count==temptime2+trcd)
							begin
								$fdisplay(file_out,"%d		%d		WR0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
								flag_command1=1;
								flag_command0=0;
								flag_write=1;
								temptime3=clock_count;
								flag_read = 0;
							end
					end
			end
		else if (flag_loop_command0==1)
			begin
				if (tempbankgroup != temporary1.address[9:7])        //diff bg
					begin
						if (flag_previous_read==1 && (temporary1.operation==0||temporary1.operation==2))  //rd to rd
							begin
								if(clock_count>temptime3+tccd_s && clock_count>temptime2+trcd) //wait for tccd_s and trcd
									begin
										$fdisplay(file_out,"%d		%d		RD0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
										flag_loop_command0=0;
										flag_command1=1;
										flag_read=1;
										temptime3=clock_count;
									end
							end
						else if (flag_previous_read==1 && temporary1.operation==1) //rd to wr
							begin
								if(clock_count>temptime3+tccd_s_rtw && clock_count>temptime2+trcd) //wait for tccd_s_rtw and trcd
									begin
										$fdisplay(file_out,"%d		%d		WR0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
										temptime3=clock_count;
										flag_loop_command0=0;
										flag_previous_read=0;
										flag_command1=1;
										flag_write=1;
									end
							end
						else if (flag_previous_write==1 && (temporary1.operation==0||temporary1.operation==2)) //wr to rd
							begin
								if(clock_count>temptime3+tccd_s_wtr && clock_count>temptime2+trcd) //wait for tccd_s_wtr and trcd
									begin
										$fdisplay(file_out,"%d		%d		RD0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
										temptime3=clock_count;
										flag_loop_command0=0;
										flag_previous_write=0;
										flag_command1=1;
										flag_read=1;
									end
							end
						else if (flag_previous_write==1 && temporary1.operation==1) //wr ro wr
							begin
								if(clock_count>temptime3+tccd_s_wr && clock_count>temptime2+trcd) //wait for tccd_s_wr and trcd
									begin
										$fdisplay(file_out,"%d		%d		WR0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
										temptime3=clock_count;
										flag_loop_command0=0;
										flag_previous_write=0;
										flag_command1=1;
									end
							end
					end	
				else if (tempbankgroup == temporary1.address[9:7]) //same bg
					begin
						begin
						if (flag_previous_read==1 && (temporary1.operation==0||temporary1.operation==2))  //rd to rd
							begin
								if(clock_count>temptime3+tccd_l && clock_count>temptime2+trcd) //wait for tccd_l and trcd
									begin
										$fdisplay(file_out,"%d		%d		WR0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
										flag_loop_command0=0;
										flag_command1=1;
										flag_read=1;
										temptime3=clock_count;
									end
							end
						else if (flag_previous_read==1 && temporary1.operation==1) //rd to wr
							begin
								if(clock_count>temptime3+tccd_l_rtw && clock_count>temptime2+trcd) //wait for tccd_l_rtw and trcd
									begin
										$display("%d	%d		WR0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
										temptime3=clock_count;
										flag_loop_command0=0;
										flag_previous_read=0;
										flag_command1=1;
										flag_write=1;
									end
							end
						else if (flag_previous_write==1 && (temporary1.operation==0||temporary1.operation==2)) //wr to rd
							begin
								if(clock_count>temptime3+tccd_l_wtr && clock_count>temptime2+trcd) //wait for tccd_l_wtr and trcd
									begin
										$fdisplay(file_out,"%d		%d		WR0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
										temptime3=clock_count;
										flag_loop_command0=0;
										flag_previous_write=0;
										flag_command1=1;
										flag_read=1;
									end
							end
						else if (flag_previous_write==1 && temporary1.operation==1) //wr ro wr
							begin
								if(clock_count>temptime3+tccd_l_wr && clock_count>temptime2+trcd) //wait for tccd_l_wr and trcd
									begin
										$fdisplay(file_out,"%d		%d		WR0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
										temptime3=clock_count;
										flag_loop_command0=0;
										flag_previous_write=0;
										flag_command1=1;
									end
							end
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
						//$display("READ");
						if (clock_count==temptime3+2)
							begin
								$fdisplay(file_out,"%d		%d		RD1		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
								flag_pre=1;
								flag_command1=0;
								temptime4=clock_count;
								flag_previous_read=1;
								/*Tccd_l=clock_count;
								Tccd_s=clocl_count;
								Tccd_l_wr=clock_count;
								tccd_s_wr=clocl_count;
								tccd_l_rtw=clock_count;
								tccd_s_rtw=clocl_count;
								tccd_l_wtr=clock_count;
								tccd_s_wtr=clocl_count;*/
							end
					end
				else if (flag_write==1)
					begin
						//$display("WRITE");
						if (clock_count==temptime3+2)
							begin
								$fdisplay(file_out,"%d		%d		WR1		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
								flag_pre=1;
								flag_command1=0;
								flag_previous_write=1;
								temptime4=clock_count;
							end
					end
			end
	end
endtask
		
task precharge();
	begin
		if(flag_pre==1)
			begin
				if (flag_read ==1)
					begin
						if (clock_count>temptime2+tras)
							begin
								$fdisplay (file_out,"%d		%d		PRE		%d		", clock_count, temporary1.core, temporary1.address[9:7]);
								//$display("**********************************************");
						
								flag_pre=0;
								flag_loop=1;
								flag_read=0;
								tempbank=temporary1.address[11:10];
								tempbankgroup=temporary1.address[9:7];
								temptime5=clock_count;
								if (my_queue.size() == 0)
									begin
										temp_clock_count=clock_count;
									end
							end
					end
				else if (flag_write==1)
					begin
						if (clock_count>temptime4+tburst+twr+cwl && clock_count>temptime2+tras)
							begin
								$fdisplay (file_out,"%d		%d		PRE		%d		%d", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10]);
								//$display("**********************************************");
						
								flag_pre=0;
								flag_loop=1;
								flag_read=0;
								tempbank=temporary1.address[11:10];
								tempbankgroup=temporary1.address[9:7];
								temptime5=clock_count;
								if (my_queue.size() == 0)
									begin
										temp_clock_count=clock_count;
									end
							end
					end
			end
	end
endtask

always@(clock)
	begin
		pop_task();
		task_act1();
		command0();
		command1();
		precharge();
	
	end
	


initial 
  begin
			file_input = "trace0cp1.txt";
			
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
						
						
						forever
						begin
						@(posedge clock)
							if(my_queue.size() == 0)
							begin
								if (clock_count==temp_clock_count)
									begin
										$finish;
									end
							end
						end
						
						

	
	





end

endmodule