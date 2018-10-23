LIBRARY ieee;
USE	ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

PACKAGE CPU_package IS
	FUNCTION add_overflow(a, b : std_logic_vector) RETURN std_logic_vector;
	FUNCTION sub_overflow(a, b : std_logic_vector) RETURN std_logic_vector;
	FUNCTION seven_segment_decoder(number : unsigned) RETURN std_logic_vector;
 	
	--PACKAGE CONSTANT DECLARATION
	CONSTANT address_size, 
				data_size, 
				operation_size		: integer:=4;
	CONSTANT instruction_size	: integer:=10;	
	
	--PACKAGE SUBTYPE DECLARATION. USES CONSTANTS TO DEFINE UPPER SIZE OF VECTOR
	SUBTYPE data_word 		IS std_logic_vector(data_size-1 DOWNTO 0);
	SUBTYPE address_bus 		IS std_logic_vector(address_size-1 DOWNTO 0);
	SUBTYPE data_bus			IS	std_logic_vector(data_size-1 DOWNTO 0);
	SUBTYPE instruction_bus	IS	std_logic_vector(instruction_size-1 DOWNTO 0);
	SUBTYPE program_word		IS	std_logic_vector(instruction_size-1 DOWNTO 0);
	SUBTYPE command_word		IS	std_logic_vector(operation_size-1 DOWNTO 0);	
	
	--ASSEMBLY CODE
	SUBTYPE opcode is std_logic_vector(3 DOWNTO 0);
	SUBTYPE regs is std_logic_vector(1 DOWNTO 0);
		
	CONSTANT OpAdd : opcode:="0000";
	CONSTANT OpSub : opcode:="0001";
	CONSTANT OpAnd : opcode:="0010";
	CONSTANT OpOr 	: opcode:="0011";
	CONSTANT OpXor : opcode:="0100";
	CONSTANT OpNot : opcode:="0101";
	CONSTANT OpMov : opcode:="0110";
	
	CONSTANT	OpLdr	: opcode:="1000";
	CONSTANT	OpStr	: opcode:="1001";
	CONSTANT	OpLdi	: opcode:="1010";
	CONSTANT	OpNop	: opcode:="1011";
	CONSTANT	OpBrz	: opcode:="1100";
	CONSTANT	OpBrn	: opcode:="1101";
	CONSTANT	OpBro	: opcode:="1110";
	CONSTANT	OpBra	: opcode:="1111";	
	
	CONSTANT R0		: regs:="00";
	CONSTANT R1		: regs:="01";
	CONSTANT R2		: regs:="10";
	CONSTANT R3		: regs:="11";
	
	CONSTANT c_ALU_ON		: std_logic:='1';
	CONSTANT c_ALU_OFF	: std_logic:='0';
	
	CONSTANT c_RWM_ON		: std_logic:='0';
	CONSTANT c_RWM_OFF	: std_logic:='1'; 
	
	CONSTANT c_RWM_READ 	: std_logic:='1';
	CONSTANT c_RWM_WRITE : std_logic:='0';
	
	CONSTANT c_REG_READ 	: std_logic:='1';
	CONSTANT c_REG_WRITE : std_logic:='0';
	
	CONSTANT c_ROM_ON		: std_logic:='0';
	CONSTANT c_ROM_OFF 	: std_logic:='1';
	
	CONSTANT c_BUFF_ON	: std_logic:='1';
	CONSTANT c_BUFF_OFF 	: std_logic:='0';
	
	CONSTANT c_MUX_DATA_IMM : std_logic_vector(1 DOWNTO 0):="10";
	CONSTANT c_MUX_RWM 		: std_logic_vector(1 DOWNTO 0):="01";
	CONSTANT c_MUX_ALU 		: std_logic_vector(1 DOWNTO 0):="00";
		
END PACKAGE CPU_package;
	
PACKAGE BODY CPU_package IS

--PACKAGE FUNCTIONS:
--ADD_OVERFLOW ADDS TWO N BIT VECTORS AND RETURNS A N+1 BIT VECTOR
	FUNCTION add_overflow(a, b: std_logic_vector) RETURN std_logic_vector IS		
		VARIABLE result	: std_logic_vector(a'LENGTH DOWNTO 0);
		VARIABLE temp 		: std_logic_vector(a'LENGTH-1 DOWNTO 0);
		VARIABLE overflow : std_logic;
		
		BEGIN
			temp := std_logic_vector(signed(a) + signed(b));
			overflow := '0';
			if a(a'LENGTH-1) = b(b'LENGTH - 1) and a(a'LENGTH-1) /= temp(a'LENGTH -1) then	
			
				overflow := '1';		
				
			END IF;
			result := overflow & temp;
		RETURN result;		
	END FUNCTION add_overflow;

--SUB_OVERFLOW SUBTRACTS TWO N BIT VECTORS AxND RETURNS A N+1 BIT VECTOR
	FUNCTION sub_overflow(a,b : std_logic_vector) RETURN std_logic_vector IS	
		VARIABLE result	: std_logic_vector(a'LENGTH DOWNTO 0);
		VARIABLE temp 		: std_logic_vector(a'LENGTH-1 DOWNTO 0);
		VARIABLE overflow : std_logic;
		
		BEGIN
			
			temp := std_logic_vector(signed(a) - signed(b));
			overflow := ((b(b'LENGTH-1) and temp(temp'LENGTH-1)) xor (a(a'LENGTH-1)));
				
			
			
			result := overflow & temp;
		RETURN result;		
	END FUNCTION sub_overflow;
	
	FUNCTION seven_segment_decoder(number: unsigned) RETURN std_logic_vector IS
		VARIABLE display : std_logic_vector(6 DOWNTO 0);
		BEGIN
		CASE to_integer(number) IS
				WHEN 0 => display 	:= "1000000"; --0 
				WHEN 1 => display 	:= "1111001"; --1
				WHEN 2	=>	display 	:=	"0100100"; --2
				WHEN 3 => display 	:=	"0110000"; --3
				WHEN 4 => display 	:=	"0011001"; --4
				WHEN 5 =>	display 	:=	"0010010"; --5
				WHEN 6 => display 	:= "0000010"; -- "6" 
				WHEN 7 => display 	:= "1111000"; -- "7" 
				WHEN 8 => display 	:= "0000000"; -- "8"     
				WHEN 9 => display 	:= "0010000"; -- "9" 
				WHEN 10 => display 	:= "0100000"; -- a
				WHEN 11 => display 	:= "0000011"; -- b
				WHEN 12 => display 	:= "1000110"; -- C
				WHEN 13 => display 	:= "0100001"; -- d
				WHEN 14 => display 	:= "0000110"; -- E
				WHEN 15 => display 	:= "0001110"; -- F
				WHEN OTHERS => display  := (OTHERS => 'Z');
			END CASE;
		
		RETURN display;	
	END FUNCTION;
	
	
	
	
	
END PACKAGE BODY CPU_package;