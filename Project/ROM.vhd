LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.CPU_package.all;

ENTITY ROM IS
	PORT( adr		: IN 	address_bus;
			data     : OUT	instruction_bus;
			ce			: IN	std_logic
			
	);
END ENTITY;

ARCHITECTURE RTL OF ROM IS
SIGNAL rom_address : integer;
TYPE rom_table IS ARRAY (0 TO 15) OF instruction_bus;
CONSTANT rom: rom_table:= rom_table' ( 0	 =>	"1010110011",		-- LDI R3, 3
													1	 =>	"1001111110",		-- STR R3, 14
													2	 =>	"1010010001",		-- LDI R1, 1
													3	 =>	"1000001110",		-- LDR R0, 14
													4	 => 	"0110000010",		--	MOV R0, R2
													5	 =>	"0000011010",     -- ADD R1+R2=R2
													6	 =>	"0001000100",		-- SUB R0-R1=R0
													7	 =>	"1100001100",		-- BRZ 12
													8	 =>	"1011000000",		-- NOP
													9	 =>	"1111000101",		-- BRA, 5
													12	 =>	"1001101111",		-- STR R2, 15
													13	 => 	"1111001101",		-- BRA 13
													others =>"1011000000"		-- NOP						
												);

BEGIN
rom_address <= to_integer(unsigned(adr));
	

data <= rom(rom_address) WHEN ce = '0' ELSE
			(OTHERS => 'Z');

 

END ARCHITECTURE;