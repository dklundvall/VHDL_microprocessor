LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY clock_div IS
	PORT(	clk_in		:	IN 	std_logic;
			clk_out		:	OUT	std_logic
			);
END ENTITY;

ARCHITECTURE behavioural OF clock_div IS
	
	SIGNAL temp		:	std_logic:='0';
	SIGNAL counter	:	integer range 0 TO 5000000:= 0;
	
	BEGIN
	PROCESS(clk_in) BEGIN
		IF (rising_edge(clk_in)) THEN
			IF(counter = 5000000) THEN
				temp 		<= not(temp);
				counter 	<= 0;
			ELSE
				counter <= counter + 1;
			END IF;
		END IF;
	END PROCESS;
	
	clk_out	<= temp;				

END ARCHITECTURE;
