LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE work.CPU_package.all;

ENTITY ALU IS
	PORT(
	Op			:	IN 	std_logic_vector(2 DOWNTO 0);
	A			:	IN 	data_word:="0000";
	B			:	IN 	data_word:="0000";
	En			:	IN 	std_logic;
	clk		: 	IN		std_logic:='0';
	y			:	OUT	data_word;
	n_flag	:	OUT	std_logic;
	z_flag	:	OUT	std_logic;
	o_flag	:	OUT	std_logic
	);
END ENTITY ALU;

ARCHITECTURE rtl OF ALU IS 

SIGNAL answer	: std_logic_vector(data_size DOWNTO 0);

	
	BEGIN
		y			<= answer(data_size-1 DOWNTO 0);
		n_flag	<= answer(data_size-1);
		o_flag	<= answer(data_size);
		y		 	<= answer (data_size-1 DOWNTO 0);
		z_flag	<=	'1' when answer = "00000" else
						'0';
		
		PROCESS(clk, En)
	   BEGIN	
			
			IF(En = '1') THEN
				IF (rising_edge(clk)) THEN
					CASE Op IS
						WHEN "000" => answer <= add_overflow(A, B);
						WHEN "001" => answer <= sub_overflow(A, B);
						WHEN "010" => answer <= '0' & A and '0' & B;
						WHEN "011" => answer <= '0' & A or '0' & B;
						WHEN "100" => answer <= '0' & A xor '0' & B;
						WHEN "101" => answer <= '0' & not A;
						WHEN "110" => answer <= '0' & A;
						WHEN OTHERS => answer <=(OTHERS => 'Z');
					END CASE;
				END IF;			
			END IF;
		END PROCESS;
END ARCHITECTURE rtl;
	
	
	
			--answer 	<= add_overflow(A, B) when Op ="000" and En = '1' else
				--			sub_overflow(A, B) when Op ="001" else
					--		'0' & A and '0' & B when Op ="010" else
						--	'0' & A or '0' & B when Op ="011" else
							--'0' & A xor '0' & B when Op ="100" else
							--'0' & not A when Op ="101" else
							--'0' & A when Op ="110" else
							--"00000";
							
			
		
			--o_flag	<=	'0' when answer(data_size DOWNTO 0) = '1' or '0' else
				
							
			
	
