LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;
USE work.CPU_package.all;
USE work.all;

ENTITY MicroprocessorElektrum IS
	PORT( 
	 stop 	: IN std_logic:='0'; -- stops statemachine
	 clk 		: IN std_logic;
	 reset 	: IN std_logic:='0'; -- active high
	 s_adr_out	: OUT	address_bus;
	 s_data_out: OUT address_bus;
	 pc_out		: OUT  std_logic_vector(6 DOWNTO 0):=(OTHERS=> '0');
	 rwm_out : OUT  std_logic_vector(6 DOWNTO 0):=(OTHERS=> '0'));
END MicroprocessorElektrum;



ARCHITECTURE Structural OF MicroprocessorElektrum IS
	-- CONTROLLER SIGNALS
	SIGNAL adr_sig		: address_bus; 	-- unsigned
	SIGNAL RWM_data_sig: data_bus; 	-- unsigned
	SIGNAL ROM_data_sig: program_word; 	-- unsigned
	SIGNAL rw_RWM_sig	: std_logic; 		-- read on high
	SIGNAL RWM_en_sig	: std_logic; 		-- active low
	SIGNAL ROM_en_sig	: std_logic;		-- active low
	SIGNAL clk_sig		: std_logic;
	SIGNAL resetSig	: std_logic; 		-- active high
	SIGNAL rw_reg	 	: std_logic; 		-- read on high
	SIGNAL sel_op_1	: std_logic_vector(1 downto 0);
	SIGNAL sel_op_0 	: std_logic_vector(1 downto 0);
	SIGNAL sel_in 		: std_logic_vector(1 downto 0);
	SIGNAL sel_mux 	: std_logic_vector(1 downto 0);
	SIGNAL alu_op 		: std_logic_vector(2 downto 0);
	SIGNAL alu_en 		: std_logic; 		-- active high
	SIGNAL z_flag 		: std_logic; 		-- active high
	SIGNAL n_flag 		: std_logic; 		-- active high
	SIGNAL o_flag 		: std_logic; 		-- active high
	SIGNAL out_en 		: std_logic; 		-- active high
	SIGNAL data_imm 	: data_word; 		-- signed
	
	--SEVEN SEGMENT DISPLAY SIGNALS
	SIGNAL pc_seg		: unsigned(3 DOWNTO 0);
	SIGNAL rwm_13_seg : std_logic_vector(3 DOWNTO 0);
	SIGNAL rwm_14_seg : std_logic_vector(3 DOWNTO 0);
	
	--REGISTER SIGNALS
	SIGNAL data_out_0, data_out_1 : data_word;
	SIGNAL data_in		: data_word;
	
	--BUFFER SIGNALS
	SIGNAL data_out	: data_bus;
	
	--ALU SIGNALS
	SIGNAL y				: data_word;
	
	COMPONENT Controller IS
	 PORT( adr 			: OUT address_bus; 	-- unsigned
			 data 		: IN 	program_word; 	-- unsigned
			 rw_RWM		: OUT std_logic; 		-- read on high
			 RWM_en 		: OUT std_logic; 		-- active low
			 ROM_en 		: OUT std_logic;		-- active low
			 clk 			: IN 	std_logic;
			 reset 		: IN 	std_logic; 		-- active high
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
			 stop			: IN	std_logic;
			 pc_out	   : OUT  unsigned(3 DOWNTO 0)
			 );
	
	
	END COMPONENT Controller;
	
	
	COMPONENT ALU IS
		PORT(
			Op			:	IN 	std_logic_vector(2 DOWNTO 0);
			A			:	IN 	data_word:="0000";
			B			:	IN 	data_word:="0000";
			En			:	IN 	std_logic;
			clk		: 	IN		std_logic:='0';
			y			:	OUT	data_word;
			n_flag	:	OUT	std_logic;
			z_flag	:	OUT	std_logic;
			o_flag	:	OUT	std_logic);
	END COMPONENT ALU;
	
	COMPONENT Multiplexer IS
		PORT(	Sel			: IN	std_logic_vector(1 DOWNTO 0);
				Data_in_2	: IN	data_word;
				Data_in_1	: IN 	data_bus;
				Data_in_0	: IN	data_word;
				Data_out		: OUT	data_word);	
	END COMPONENT Multiplexer;
	
	COMPONENT RegisterFile IS
		PORT(	clk				:	IN 	std_logic;
				data_in			:	IN 	data_word;
				data_out_1		:	OUT	data_word;
				data_out_0		:	OUT	data_word;
				sel_in			:	IN	std_logic_vector(1 DOWNTO 0);
				sel_out_1		:	IN	std_logic_vector(1 DOWNTO 0);
				sel_out_0		:	IN	std_logic_vector(1 DOWNTO 0);
				rw_reg			:	IN	std_logic);
	END COMPONENT RegisterFile;
	
	COMPONENT DataBuffer IS
		PORT(	out_en		: IN	std_logic;
				data_in		: IN	data_word;
				data_out		: OUT	data_bus);
	END COMPONENT DataBuffer;
	
	COMPONENT ROM IS
		PORT( adr		: IN 	address_bus;
				data     : OUT	instruction_bus:=(OTHERS => 'Z');
				ce			: IN	std_logic);
	END COMPONENT;
		
	COMPONENT RW_MEMORY IS
		PORT(	adr		: IN 		address_bus;
				data		: INOUT	data_bus;
				clk		: IN 		std_logic;
				ce			: IN		std_logic;
				rw			: IN 		std_logic;
				rwm_13	: OUT		std_logic_vector;
				rwm_14 	: OUT		std_logic_vector
		);
	END COMPONENT;
	
	COMPONENT clock_div IS
		PORT(	clk_in		:	IN 	std_logic;
				clk_out		:	OUT	std_logic
				);
	END COMPONENT;
		
	
	BEGIN
		s_data_out	<=	RWM_data_sig;
		s_adr_out	<=	adr_sig;
		
		U1: 
		Controller PORT MAP(
			 adr 			=> adr_sig,
			 data 		=> ROM_data_sig,
			 rw_RWM		=> rw_RWM_sig,
			 RWM_en 		=> RWM_en_sig,
			 ROM_en 		=> ROM_en_sig,
			 clk 			=> clk_sig,
			 reset 		=> reset,
			 rw_reg	 	=> rw_reg,
			 sel_op_1	=> sel_op_1,
			 sel_op_0 	=> sel_op_0,
			 sel_in 		=> sel_in,
			 sel_mux 	=> sel_mux,
			 alu_op 		=> alu_op,
			 alu_en 		=> alu_en,
			 z_flag 		=> z_flag,
			 n_flag 		=> n_flag,
			 o_flag 		=> o_flag,
			 out_en 		=> out_en,
			 data_imm 	=> data_imm,
			 stop			=> stop,
			 pc_out 		=> pc_seg
			 );
		
		U2:
		Multiplexer PORT MAP(
			Sel			=> std_logic_vector(Sel_mux), --CONTROLLER
			Data_in_2	=> data_imm,						--CONTROLLER					
			Data_in_1	=> RWM_data_sig,						--BUFFER
			Data_in_0	=> y,									--ALU
			Data_out		=> data_in
			);
			
		U3:
		RegisterFile PORT MAP(
			Data_in		=> data_in,
			sel_in		=> std_logic_vector(sel_in),
			sel_out_1  	=> std_logic_vector(sel_op_1),
			sel_out_0	=>	std_logic_vector(sel_op_0),
			rw_reg		=>	rw_reg,
			clk			=> clk_sig,
			data_out_1	=>	data_out_1,
			data_out_0	=>	data_out_0);
			
		U4:
		ALU PORT MAP(
			Op				=> std_logic_vector(alu_op),		--CONTROLLER
			A				=>	data_out_1,	--REGISTERFILE
			B				=>	data_out_0, --REGISTERFILE
			en				=> alu_en,		--CONTROLLER
			clk			=>	clk_sig,			--CLOCK
			y				=> y,				--MUX
			z_flag		=> z_flag,		--CONTROLLER
			n_flag		=>	n_flag,		--CONTROLLER
			o_flag		=>	o_flag);		--CONTROLLER
			
		U5:
		DataBuffer PORT MAP(
			out_en		=>	out_en,     --REGISTER & ALU
			data_in		=>	data_out_1,	--REGISTER & ALU
			data_out		=> RWM_data_sig);  --MUX
			
		U6:
		ROM PORT MAP(
				adr			=> adr_sig,
				data     	=>	ROM_data_sig,
				ce				=>	ROM_en_sig
				);
		
		U7:
		RW_MEMORY PORT MAP(
			adr			=>	adr_sig,
			data			=> RWM_data_sig,
			clk			=>	clk_sig,
			ce				=>	RWM_en_sig,
			rw				=> rw_RWM_sig,
			rwm_13	 	=> rwm_13_seg,	
			rwm_14		=>	rwm_14_seg
			);
			
		U8:
		clock_div PORT MAP(
			clk_in	=>	clk,
			clk_out	=>	clk_sig
		);
	
	PROCESS(pc_seg, RWM_data_sig)
	BEGIN
		pc_out	<=	seven_segment_decoder(unsigned(pc_seg));
		rwm_out	<=	seven_segment_decoder(unsigned(RWM_data_sig));
		
	END PROCESS;
		
		
				
			
			
END ARCHITECTURE Structural;