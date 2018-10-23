LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;
USE work.CPU_package.all;

ENTITY Controller IS
	 PORT( adr 			: OUT address_bus; 	-- unsigned
			 data 		: IN 	program_word; 	-- unsigned
			 rw_RWM		: OUT std_logic; 		-- read on high
			 RWM_en 		: OUT std_logic; 		-- active low
			 ROM_en 		: OUT std_logic;		-- active low
			 clk 			: IN 	std_logic;
			 reset 		: IN 	std_logic:='0'; 		-- active high
			 rw_reg	 	: OUT std_logic; 		-- read on high
			 sel_op_1	: OUT std_logic_vector(1 downto 0);
			 sel_op_0 	: OUT std_logic_vector(1 downto 0);
			 sel_in 		: OUT std_logic_vector(1 downto 0);
			 sel_mux 	: OUT std_logic_vector(1 downto 0);
			 alu_op 		: OUT std_logic_vector(2 downto 0);
			 alu_en 		: OUT std_logic; 		-- active high
			 z_flag 		: IN 	std_logic; 		-- active high
			 n_flag 		: IN 	std_logic; 		-- active high
			 o_flag 		: IN 	std_logic; 		-- active high
			 out_en 		: OUT std_logic; 		-- active high
			 data_imm 	: OUT data_word; 	-- signed
			 stop			: IN	std_logic:='0';
			 pc_out 		: OUT  unsigned(3 DOWNTO 0)
			 );
 END ENTITY Controller;
 
 
 
ARCHITECTURE rtl OF Controller IS
--CONTROLLER STATES AND SIGNALS
	TYPE state_type IS(
		Controller_Reset,
		Fetch_Instruction,
		Load_Instruction,
		Decode_Instruction,
		Write_Result,
		Load_Data,
		Store_Data,
		Load_Immediate);
	SIGNAL current_state	: state_type:=Controller_Reset;
	SIGNAL next_state		: state_type;
	SIGNAL pc				: unsigned(3 DOWNTO 0);
	SIGNAL instr			: instruction_bus;
	--SIGNAL instrID			: std_logic_vector(3 DOWNTO 0);
	
	--ALIAS
	ALIAS operation	: std_logic_vector(3 DOWNTO 0) IS instr(9 DOWNTO 6);
	ALIAS alu_operation : std_logic_vector(2 DOWNTO 0) IS instr(8 DOWNTO 6);
	ALIAS r1				: std_logic_vector(1 DOWNTO 0) IS instr(5 DOWNTO 4);
	ALIAS r2				: std_logic_vector(1 DOWNTO 0) IS instr(3 DOWNTO 2);
	ALIAS r3				: std_logic_vector(1 DOWNTO 0) IS instr(1 DOWNTO 0);
	ALIAS mem			: std_logic_vector(3 DOWNTO 0) IS instr(3 DOWNTO 0);
	ALIAS immediate	: std_logic_vector(3 DOWNTO 0) IS instr(3 DOWNTO 0);
	
	BEGIN
	
	
	
	next_state_and_output : PROCESS(clk, current_state, data)
		BEGIN	
			
			alu_op	<=	operation(2 DOWNTO 0); -- always input opcode to alu, use enable/disable alu!
			pc_out	<= pc;
			
			IF(rising_edge(clk)) THEN
			rw_REG	<=	c_REG_READ;
			RWM_en	<=	c_RWM_OFF;
			ROM_en	<=	c_ROM_OFF;
			alu_en	<=	c_ALU_OFF;
			out_en	<=	c_BUFF_OFF;
			
			
			CASE current_state IS
				WHEN Controller_Reset	=> pc 			<= (OTHERS=>'0');
													next_state 	<= Fetch_Instruction;
													
				WHEN Fetch_Instruction	=> ROM_en		<=	c_ROM_ON;
													adr			<=	std_logic_vector(pc);
													next_state	<=	Load_Instruction;
										
				WHEN Load_Instruction	=> instr 		<= data;
													next_state	<=	Decode_Instruction;
				
				WHEN Decode_Instruction	=> CASE operation IS
														WHEN OpLdi	=>		sel_mux		<=	c_MUX_DATA_IMM;	--select imm
																				data_imm		<= immediate;			--input r2&r3 to imm
																				sel_in		<= r1; 					--write to r1
																				next_state	<=	Load_Immediate;
															
														WHEN OpStr	=>		rw_reg		<= c_REG_READ;		--set register to readmode
																				sel_op_1		<= r1;				--select chosen register
																				out_en		<= c_BUFF_ON;		--enable buffer
																				adr			<= mem;				--RWM adress r2&r3
																				rw_RWM		<= c_RWM_WRITE;	--RWM in writemode
																				RWM_en		<=	c_RWM_ON;
																				ROM_en		<= c_ROM_OFF;
																				next_state	<=	Store_Data;
														
														WHEN OpLdr	=>		sel_mux		<=	c_MUX_RWM;		--load registerfile with output from rwm
																				rw_RWM 		<= c_RWM_READ;		--ram in readmode
																				RWM_en		<= c_RWM_ON;
																				adr			<= mem;				--output r2&r3
																				sel_in		<= r1; 				--write to r1
																				rw_reg		<=	c_REG_WRITE;	--registerfile in writemode
																				next_state	<=	Load_Data;
														
														WHEN OpBrz	=>		IF(z_flag = '1') THEN
																					pc	<=	unsigned(mem);
																				ELSE
																					pc	<= (pc +1);
																				END IF;
																				next_state	<= Fetch_Instruction;
																				
														WHEN OpBrn	=>		IF(n_flag = '1') THEN
																					pc	<=	unsigned(mem);
																				ELSE
																					pc	<= (pc +1);
																				END IF;
																				next_state	<= Fetch_Instruction;
														
														WHEN OpBro	=>		IF(o_flag = '1') THEN
																					pc	<=	unsigned(mem);
																				ELSE
																					pc	<= (pc +1);
																				END IF;
																				next_state	<= Fetch_Instruction;
														
														WHEN OpBra	=>		pc	<=	unsigned(mem);
																				next_state	<=	Fetch_Instruction;
															
														WHEN OpAdd | OpSub | OpAnd | OpOr | OpXor | OpNot | OpMov =>
																				sel_op_1 <= r1;
																				sel_op_0	<=	r2;
																				sel_in	<=	r3;
																				rw_reg		<=	c_REG_READ;
																				sel_mux		<=	c_MUX_ALU;
																				alu_en		<=	c_ALU_ON;																				
																				next_state	<= Write_Result;
																				
														WHEN OpNop	=>		pc				<= (pc+1);
																				next_state	<=	Fetch_Instruction;
															
														WHEN OTHERS =>		next_state	<=	Controller_Reset;
													
													END CASE;
													
				WHEN Write_Result			=> rw_reg		<= c_REG_WRITE;
													pc				<=	(pc+1);
													next_state	<= Fetch_Instruction;
													
				WHEN Load_Data				=> pc				<= (pc+1);										
													next_state 	<= Fetch_Instruction;
				
				WHEN Store_Data			=> pc				<= (pc+1);
													next_state 	<= Fetch_Instruction;
				
				WHEN Load_Immediate		=> rw_reg		<=	c_REG_WRITE;	--registerfile in writemode
													pc				<= (pc+1);
													next_state 	<= Fetch_Instruction;
													
				WHEN OTHERS					=> next_state <= Controller_Reset;
			END CASE;
			END IF;
		END PROCESS;
		
	state_reg : PROCESS (next_state, reset, stop)
		BEGIN
			IF (stop = '0') THEN
				IF (reset = '1') THEN
					current_state <= Controller_Reset;
				ELSE
					current_state <= next_state;
				END IF;
			END IF;
		END PROCESS;
	
END ARCHITECTURE;	