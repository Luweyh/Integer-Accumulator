TITLE Integer_Accumulator     (Project_3.asm)

; Author: Luwey Hon
; Last Modified: 5/3/2020
; OSU email address: honl@oregonstate.edu
; Course number/section: CS 271 C400
; Project Number:   3              Due Date: 5/03/2020
; Description: This program starts with a heading that displays the title and 
;	then says hello to the user. It will instruct the user to enter a number
;	in [-88, -55] or [-40, -1]. It will continue asking for a number until
;	a positve number is inserted. It will validate the range and present
;	an error message if it is out of range. The program will test if the 
;	number is positive by determining the sign flag. The program will
;	then give the user's valid number amount, maximum number, minimum number,
;	sum of their valid number, and rounded avg. It will then conclude with
;	a farewell address.

INCLUDE Irvine32.inc

; Range boundaries defined as constant
; Note: high means in [-40, -1] and low means in [-88,-55]
HIGH_LOWER_LIMIT = -40
LOW_UPPER_LIMIT = -55
LOW_LOWER_LIMIT = -88

.data
; heading variables
	prog_title		BYTE	"         Integer Accumulator",0
	author_name		BYTE	"    By: Luwey Hon",0
	ec_lines		BYTE	"**EC: Display the line number. Increment only when valid input.",0
																				
; variables that store values to find data
	user_name		BYTE	33 DUP(0)	; will hold user's name
	user_num		SDWORD	?			; number user entered
	max_num			SDWORD	-90			; will store max num for user input
	min_num			SDWORD	1			; will store min num for user input
	  ; NOTE: I initialize the min and max number to an out of range number 
	  ; since this gaurantees a change of min and max after a VALID input.
											
	total_sum		SDWORD	0			; all the numbers total value. Initialize at 0
	valid_nums		SDWORD	0			; how many valid numbers the user have
	avg_rounded		SDWORD	?			; the average of all their numbers rounded
	line_number		DWORD	0			
	sign_test		DWORD	0			; will use to test sign flag
	remainder		DWORD	?
	
	double_total_sum	SDWORD	?
	double_valid_nums	SDWORD	?
	negative_valid_nums	SDWORD	?


; variables for displaying strings
	name_prompt			BYTE	"What is your name? ",0
	hello				BYTE	"Hello, ",0
	instructions_1		BYTE	"Please enter numbers in [-88, -55] or [-40, -1].",0
	instructions_2		BYTE	"Enter a non-negative number when you are finished to see results.",0
	enter_number		BYTE	"Enter number: ",0
	invalid_num			BYTE	"Invalid number!", 0
	print_enter			BYTE	"You entered ",0
	print_valid			BYTE	" valid numbers",0
	max_valid			BYTE	"Maximum valid number is: ",0
	min_valid			BYTE	"Minimum valid number is: ",0
	total_valid			BYTE	"The sum of your valid numbers is: ",0
	rounded_avg			BYTE	"The rounded average is: ",0
	no_numbers_msg		BYTE	"No numbers entered",0
	farewell			BYTE	"This concludes Luwey's program. Farewell, ",0
	line_symbol			BYTE	") ",0      ; will be next to line number


.code
main PROC

; display heading
	mov		edx, OFFSET prog_title
	call	WriteString
	mov		edx, OFFSET author_name
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec_lines
	call	WriteString
	call	CrLf
	call	CrLf

; getting user's name
	mov		edx, OFFSET name_prompt
	call	WriteString
	mov		edx, OFFSET user_name
	mov		ecx, 32
	call	ReadString						; stores user name to a variable

; saying hello to user
	mov		edx, OFFSET hello
	call	WriteString
	mov		edx, OFFSET user_name
	call	WriteString
	call	CrLf
	call	CrLf

; display instructions
	mov		edx, OFFSET instructions_1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET instructions_2
	call	WriteString
	call	CrLf
	call	CrLf


; getting the numbers and validation
	get_nums_again:						; to re loop and get numbers again
	
; displays the line numbers
	mov		eax, line_number
	call	WriteDec						
	mov		edx, OFFSET line_symbol
	call	WriteString
	
; asks for user's number and then stores it
	mov		edx, OFFSET	enter_number
	call	WriteString						
	call	ReadInt
	mov		user_num, eax					
	

	; validating correct range
		mov		eax, user_num
		cmp		eax, sign_test					; compare with 0 to test sign flag
		jns		non_negative_num				; when no sign flag, this means its a non negative number
												; so this exits the loop
	
		cmp		eax, HIGH_LOWER_LIMIT			; compare - 40
		jl		check_range						; if less than -40 
		cmp		eax, sign_test					; compare to set up for sign flag
		js		valid_range						; user's input raises sign flag and is in [-40, -1]
		
		
	;checking any number less than -40
		check_range:		
			cmp		eax, LOW_UPPER_LIMIT	; compare -55
			jg		invalid_range			; if -55 < num < -40, then invalid range
	
			cmp		eax, LOW_LOWER_LIMIT	; compare -88
			jl		invalid_range			; if num < -88, then invalid range
			mov		eax, user_num			
			cmp		eax, sign_test			; compare user's number with 0 to test sign flag			
			js		valid_range				; user's input raises sign flag and is in [-88, -55]


	;values in (-55 - 40) non-inclusive
		invalid_range:
			mov		eax, lightRed + (black * 16)	
			call	SetTextColor				; make the error message light red :)
			mov		edx, OFFSET invalid_num
			call	WriteString					; inform user their number is invalid
			mov		eax, white + (black * 16)
			call	SetTextColor				; turn it back to black and white 
			call	CrLf
			call	CrLf
			mov		eax, user_num				
			cmp		eax, sign_test				; compare user's num with 0
			js		get_nums_again				; re loops to get number again.
												; User's input raises sign flag
												; and is not in valid range.
	
	; values in [-40,-1] or [-88, -55]
		valid_range:
			call	check_min					; check for minimum number
			call	check_max					; check for maximum number
			mov		eax, user_num
			add		total_sum, eax				; to find the total sum
			inc		valid_nums					; increase valid number amount
			inc		line_number					; increase the line number
			call	CrLf
			mov		eax, user_num				
			cmp		eax, sign_test				; compare user's num with 0
			js		get_nums_again				; re loops to get number again.
												; User's input raises sign flag 
												; and is in valid range


; exiting since they insert a non negative number
non_negative_num:

; if user have no valid numbers, then just jump to say good bye
	cmp		valid_nums, 0		; Comparing how many valid number they have to 0.
	je		no_numbers			; This happens when user inputs a positive 
								; number before any valid input.

	jmp		has_valid_nums			; user have at least one valid number

	
; tells user they inserted no number
	no_numbers:
		mov		edx, OFFSET no_numbers_msg
		call	WriteString
		call	CrLf
		call	CrLf
		jmp		goodbye
	
	has_valid_nums:


; rounding with no FPU
; Notes: I am first multiplying the numerator and denominater
; by 2 so I deal with whole numbers. The remainder to meet
; half way will now be twice as large for easy comparisions.

; multiplying the total sum by 2
	mov		eax, total_sum
	mov		ebx, 2
	imul	ebx
	mov		double_total_sum, eax

; multiplying the valid numbers by 2
	mov		eax, valid_nums
	mov		ebx, 2
	imul	ebx
	mov		double_valid_nums, eax


; turning the total valid numbers to negative so I can compare later
	mov		eax, valid_nums
	cdq
	mov		ebx, -1
	idiv	ebx
	mov		negative_valid_nums, eax		

; finds the non rounded average with using double the numbers. It's the same value,
; but the remainder is twice as big and is ALWAYS a whole number.
	mov		eax, double_total_sum
	cdq
	mov		ebx, double_valid_nums
	idiv	ebx
	mov		avg_rounded, eax		; note this isn't rounded yet, but just storing the value

; comparing the remainder of the doubles
; Note: negative_valid_nums holds the half way point of the double numbers.
	cmp		edx, negative_valid_nums
	jl		round_down			; if less than the valid_nums

	jmp		no_round

; rounds down. Note it's down since we are dealing with negatives
	round_down:
		dec avg_rounded

no_round:
		

; displaying user result
	
	; display how many valid number
		call	CrLf
		mov		edx, OFFSET print_enter
		call	WriteString
		mov		eax, valid_nums
		call	WriteDec
		mov		edx, OFFSET print_valid
		call	WriteString
		call	CrLf
	
	; displaying the max
		mov		edx, OFFSET max_valid
		call	WriteString
		mov		eax, max_num
		call	WriteInt
		call	CrLf

	;displaying the min
		mov		edx, OFFSET min_valid
		call	WriteString
		mov		eax, min_num
		call	WriteInt
		call	CrLf

	; displaying total sum of valid numbers
		mov		edx, OFFSET	total_valid
		call	WriteString
		mov		eax, total_sum
		call	WriteInt
		call	CrLf
	
	; displaying the rounded average
		mov		edx, OFFSET rounded_avg
		call	WriteString
		mov		eax, avg_rounded
		call	Writeint
		call	CrLf
		call	CrLf
		

goodbye:
; saying goodbye / farewell
	mov		edx, OFFSET farewell
	call	WriteString
	mov		edx, OFFSET user_name
	call	WriteString
	call	CrLf

	exit	; exit to operating system
main ENDP

; Procedure to check the minimum number
; recieves: user's number and current minimum number
; returns: new minimum number or keeps current minimum number
; preconditions: must be a validated number
; registers changed: eax
check_min PROC
	mov		eax, user_num
	cmp		eax, min_num				
	jl		new_min							; if the current user's num < the current min number
	jmp		no_new_min						; no new min has been found

	; the min number gets updated and replaced by current user num
	new_min:
		mov		min_num, eax				
	
	; no new min number has been found
	no_new_min:
	
	ret

check_min ENDP


; Procedure to check for maximum number
; recieves: user's number and current maximum number
; returns new maximum number or keeps current maximum number
; precondition: must be a validaed number
; registers changed:  eax
check_max PROC
	mov		eax, user_num
	cmp		eax, max_num			
	jg		new_max						; if current user's num > current max
	jmp		no_new_max					; no new max has been found

	; max number gets updated and replaced by current user num
	new_max:
		mov		max_num, eax

	; no new max has been found
	no_new_max:
	
	ret
check_max ENDP

END main
