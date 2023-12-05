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

parameter trc = 115*2;
parameter tras = 76*2;
parameter trrd_l = 12*2;
parameter trrd_s = 8*2;
parameter trp = 39*2;
//parameter trfc = 295;
parameter cwl = 38*2;
parameter tcas = 40*2;
parameter trcd = 39*2;
parameter twr = 30*2;
parameter trtp = 18*2;
parameter tccd_l = 12*2;
parameter tccd_s = 8*2;
parameter tccd_l_wr = 48*2;
parameter tccd_s_wr = 8*2;
parameter tburst = 8*2;
parameter tccd_l_rtw = 16*2;
parameter tccd_s_rtw = 16*2;
parameter tccd_l_wtr = 16*2;
parameter tccd_s_wtr = 16*2;

logic[1:0] tempbank;
logic[2:0] tempbankgroup;




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
		
		
task task_act0();
	begin
		if (flag_pop==1)
			begin
				if(clock_count >= my_queue[0].req_time+2)
					begin
							temporary1=my_queue.pop_front();
							$fdisplay( file_out,"%d		%d		ACT0 		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], temporary1.address[33:18]); 
							`ifdef DEBUG
							begin
								$display("Issuing ACT0 at %d	for bank group %d		bank %d		row %h",clock_count,temporary1.address[9:7], temporary1.address[11:10], temporary1.address[33:18]);
								$display("				");
							end
							`endif
							flag_pop=0;
							flag_act1=1;
						
							temptime1= clock_count;
	
					end
			end
		else if (flag_loop==1)
			begin
				if(tempbankgroup == my_queue[0].address[9:7])
					begin
						if(clock_count>=temptime5+trp && clock_count>=temptime2+trrd_l)
							begin
								if (clock_count>=my_queue[0].req_time+2)
								begin
								temporary1=my_queue.pop_front();
								//$display("%t %d", $time, my_queue.size());
								$fdisplay(file_out, "%d		%d		ACT0 		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], temporary1.address[33:18]); 
								flag_loop=0;
								//$display("next bank = %d", temporary1.address[9:7]);
								flag_loop_act1=1;
								temptime1= clock_count;
								`ifdef DEBUG
									begin
										$display("Request from same bank group, waiting for Trp and Trrd_l, Issuing ACT0 at %d	for bank group %d		bank %d		row %h",clock_count,temporary1.address[9:7], temporary1.address[11:10], temporary1.address[33:18]);
										$display("				");
									end
								`endif
								end
							end
					end
				else if (tempbankgroup != my_queue[0].address[9:7])
					begin
						if (clock_count>=my_queue[0].req_time && clock_count>=temptime5+2)
								begin
								temporary1=my_queue.pop_front();
								//$display("next bank = %d", temporary1.address[9:7]);
								//$display("%t %d", $time, my_queue.size());
								$fdisplay( file_out,"%d		%d		ACT0 		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], temporary1.address[33:18]); 
								flag_loop=0;
								flag_loop_act1=1;
								temptime1= clock_count;
								`ifdef DEBUG
									begin
										$display("Request from different bank group, Without waiting for Trp and Trrd_s gets masked, Issuing ACT0 at %d	for bank group %d		bank %d		row %h",clock_count,temporary1.address[9:7], temporary1.address[11:10], temporary1.address[33:18]);
										$display("				");
									end
								`endif
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
						`ifdef DEBUG
							begin
								$display("Issuing ACT1 at time %d	for bank group %d		bank %d		row %h",clock_count,temporary1.address[9:7], temporary1.address[11:10], temporary1.address[33:18]);
								$display("				");
							end
						`endif
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
						`ifdef DEBUG
							begin
								$display("Issuing ACT1 at time %d	for bank group %d		bank %d		row %h",clock_count,temporary1.address[9:7], temporary1.address[11:10], temporary1.address[33:18]);
								$display("				");
							end
						`endif
						
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
						if (clock_count>=temptime2+trcd)
							begin
								$fdisplay(file_out,"%d		%d		RD0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
								flag_command1=1;
								flag_command0=0;
								flag_read=1;
								flag_write = 0;
								temptime3=clock_count;
								`ifdef DEBUG
									begin
										$display("Wait for Trcd and issue RD0 at time %d	for bank group %d		bank %d		row %h",clock_count,temporary1.address[9:7], temporary1.address[11:10], temporary1.address[33:18]);
										$display("				");
									end
								`endif
							end
					end
				else
					begin
						if (clock_count>=temptime2+trcd)
							begin
								$fdisplay(file_out,"%d		%d		WR0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
								flag_command1=1;
								flag_command0=0;
								flag_write=1;
								temptime3=clock_count;
								flag_read = 0;
								`ifdef DEBUG
									begin
										$display("Wait for Trcd and issue WR0 at time %d	for bank group %d		bank %d		row %h",clock_count,temporary1.address[9:7], temporary1.address[11:10], temporary1.address[33:18]);
										$display("				");
									end
								`endif
							end
					end
			end
		else if (flag_loop_command0==1)
			begin
				if (tempbankgroup != temporary1.address[9:7])        //diff bg
					begin
						if (flag_previous_read==1 && (temporary1.operation==0||temporary1.operation==2))  //rd to rd
							begin
								if(clock_count>=temptime3+tccd_s && clock_count>=temptime2+trcd) //wait for tccd_s and trcd
									begin
										$fdisplay(file_out,"%d		%d		RD0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
										flag_loop_command0=0;
										flag_command1=1;
										flag_read=1;
										temptime3=clock_count;
										`ifdef DEBUG
											begin
												$display("Diff BG and RD to RD, wait for Tccd_s and Trcd and issue RD0 at time %d	for bank group %d		bank %d		column %h",clock_count,temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
												$display("				");
											end
										`endif
									end
							end
						else if (flag_previous_read==1 && temporary1.operation==1) //rd to wr
							begin
								if(clock_count>=temptime3+tccd_s_rtw && clock_count>=temptime2+trcd) //wait for tccd_s_rtw and trcd
									begin
										$fdisplay(file_out,"%d		%d		WR0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
										temptime3=clock_count;
										flag_loop_command0=0;
										flag_previous_read=0;
										flag_command1=1;
										flag_write=1;
										`ifdef DEBUG
											begin
												$display("Diff BG and RD to WR, wait for Tccd_s_rtw and Trcd and issue WR0 at time %d	for bank group %d		bank %d		column %h",clock_count,temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
												$display("				");
											end
										`endif
									end
							end
						else if (flag_previous_write==1 && (temporary1.operation==0||temporary1.operation==2)) //wr to rd
							begin
								if(clock_count>=temptime3+tccd_s_wtr && clock_count>=temptime2+trcd) //wait for tccd_s_wtr and trcd
									begin
										$fdisplay(file_out,"%d		%d		RD0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
										temptime3=clock_count;
										flag_loop_command0=0;
										flag_previous_write=0;
										flag_command1=1;
										flag_read=1;
										`ifdef DEBUG
											begin
												$display("Diff BG and WR to RD, wait for Tccd_s_wtr and Trcd and issue RD0 at time %d	for bank group %d		bank %d		column %h",clock_count,temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
												$display("				");
											end
										`endif
									end
							end
						else if (flag_previous_write==1 && temporary1.operation==1) //wr ro wr
							begin
								if(clock_count>=temptime3+tccd_s_wr && clock_count>=temptime2+trcd) //wait for tccd_s_wr and trcd
									begin
										$fdisplay(file_out,"%d		%d		WR0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
										temptime3=clock_count;
										flag_loop_command0=0;
										flag_previous_write=0;
										flag_command1=1;
										`ifdef DEBUG
											begin
												$display("Diff BG and WR to WR, wait for Tccd_s_wr and Trcd and issue WR0 at time %d	for bank group %d		bank %d		column %h",clock_count,temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
												$display("				");
											end
										`endif
									end
							end
					end	
				else if (tempbankgroup == temporary1.address[9:7]) //same bg
					begin
						begin
						if (flag_previous_read==1 && (temporary1.operation==0||temporary1.operation==2))  //rd to rd
							begin
								if(clock_count>=temptime3+tccd_l && clock_count>=temptime2+trcd) //wait for tccd_l and trcd
									begin
										$fdisplay(file_out,"%d		%d		RD0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
										flag_loop_command0=0;
										flag_command1=1;
										flag_read=1;
										temptime3=clock_count;
										`ifdef DEBUG
											begin
												$display("Same BG and RD to RD, wait for Tccd_l and Trcd and issue RD0 at time %d	for bank group %d		bank %d		column %h",clock_count,temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
												$display("				");
											end
										`endif
									end
							end
						else if (flag_previous_read==1 && temporary1.operation==1) //rd to wr
							begin
								if(clock_count>=temptime3+tccd_l_rtw && clock_count>=temptime2+trcd) //wait for tccd_l_rtw and trcd
									begin
										$fdisplay(file_out,"%d		%d		WR0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
										temptime3=clock_count;
										flag_loop_command0=0;
										flag_previous_read=0;
										flag_command1=1;
										flag_write=1;
										`ifdef DEBUG
											begin
												$display("Same BG and RD to WR, wait for Tccd_l_rtw and Trcd and issue WR0 at time %d	for bank group %d		bank %d		column %h",clock_count,temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
												$display("				");
											end
										`endif
									end
							end
						else if (flag_previous_write==1 && (temporary1.operation==0||temporary1.operation==2)) //wr to rd
							begin
								if(clock_count>=temptime3+tccd_l_wtr && clock_count>=temptime2+trcd) //wait for tccd_l_wtr and trcd
									begin
										$fdisplay(file_out,"%d		%d		RD0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
										temptime3=clock_count;
										flag_loop_command0=0;
										flag_previous_write=0;
										flag_command1=1;
										flag_read=1;
										`ifdef DEBUG
											begin
												$display("Same BG and WR to RD, wait for Tccd_l_wtr and Trcd and issue RD0 at time %d	for bank group %d		bank %d		column %h",clock_count,temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
												$display("				");
											end
										`endif
									end
							end
						else if (flag_previous_write==1 && temporary1.operation==1) //wr to wr
							begin
								if(clock_count>=temptime3+tccd_l_wr && clock_count>=temptime2+trcd) //wait for tccd_l_wr and trcd
									begin
										$fdisplay(file_out,"%d		%d		WR0		%d		%d		%h", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
										temptime3=clock_count;
										flag_loop_command0=0;
										flag_previous_write=0;
										flag_command1=1;
										`ifdef DEBUG
											begin
												$display("Same BG and WR to WR, wait for Tccd_l_wr and Trcd and issue RD0 at time %d	for bank group %d		bank %d		column %h",clock_count,temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
												$display("				");
											end
										`endif
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
								`ifdef DEBUG
									begin
										$display("Issuing RD1 at time %d	for bank group %d		bank %d		column %h",clock_count,temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
										$display("				");
									end
								`endif
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
								`ifdef DEBUG
									begin
										$display("Issuing WR1 at time %d	for bank group %d		bank %d		column %h",clock_count,temporary1.address[9:7], temporary1.address[11:10], {temporary1.address[17:12], temporary1.address[5:2]});
										$display("				");
									end
								`endif
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
						if (clock_count>=temptime2+tras)
							begin
								$fdisplay (file_out,"%d		%d		PRE		%d		%d", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10]);
								`ifdef DEBUG
									begin
										$display("Witing for Tras and Issuing PRE at time %d	for bank group %d		bank %d",clock_count,temporary1.address[9:7], temporary1.address[11:10]);
										$display("**********************************************");
									end
								`endif
			
						
								flag_pre=0;
								flag_loop=1;
								flag_read=0;
								tempbank=temporary1.address[11:10];
								tempbankgroup=temporary1.address[9:7];
								//$display("%d", tempbankgroup);
								temptime5=clock_count;
								if (my_queue.size() == 0)
									begin
										temp_clock_count=clock_count;
									end
							end
					end
				else if (flag_write==1)
					begin
						if (clock_count>=temptime4+tburst+twr+cwl && clock_count>=temptime2+tras)
							begin
								$fdisplay (file_out,"%d		%d		PRE		%d		%d", clock_count, temporary1.core, temporary1.address[9:7], temporary1.address[11:10]);
								//$display("**********************************************");
						
								flag_pre=0;
								flag_loop=1;
								flag_read=0;
								tempbank=temporary1.address[11:10];
								tempbankgroup=temporary1.address[9:7];
								//$display("%d", tempbankgroup);
								temptime5=clock_count;
								`ifdef DEBUG
									begin
										$display("Witing for Tburst, Twr, Tcl and Issuing PRE at time %d	for bank group %d		bank %d ",clock_count,temporary1.address[9:7], temporary1.address[11:10]);
										$display("**********************************************");
									end
								`endif
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
		task_act0();
		task_act1();
		command0();
		command1();
		precharge();
	
	end
	


initial 
  begin
			file_input = "trace.txt";
			
			if ($value$plusargs("NAME_OF_THE_FILE=%s", file_input) == 0)
				begin
					$display("User has not specified any file. Executing default file: %s", file_input);
				end 
			else 
				begin
					$display("Opening user-specified file: %s", file_input);
				end
				
            out = "dram.txt";
			
			if ($value$plusargs("NAME_OF_THE_OUTPUT_FILE=%s", out) == 0)
				begin
					$display("User has not specified any output file. Executing default file: %s", out);
				end 
			else 
				begin
					$display("Opening user-specified file: %s", out);
				end
				
			`ifdef DEBUG
				begin
					$display("DEBUG MODE ENABLED");
				end
			`endif
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
							if(my_queue.size() == 0 && clock_count>=temp_clock_count+trp)
									begin
										$finish;
									end
						end
						
						

	
	





end

endmodule