myds		SEGMENT PARA 'veri'
n			DW 10
myds		ENDS

myss		SEGMENT PARA STACK 'yigin'
			DW 350 DUP(?)
myss		ENDS

mycs		SEGMENT PARA 'kod'
			ASSUME CS:mycs, DS:myds, SS:myss
			
MAIN		PROC FAR

			PUSH DS			
			XOR AX, AX
			PUSH AX
			MOV AX, myds		
			MOV DS, AX	 		;bu kisim hep yaptigimiz
				
			PUSH n
			CALL FAR PTR DNUM
			POP DX
			CALL NEAR PTR PRINTINT
				
			RETF
MAIN 		ENDP

PRINTINT 	PROC NEAR
			ADD DL, 48
			MOV AH, 02H 
			INT 21H
				
			RET
PRINTINT	ENDP
			
DNUM		PROC FAR


			PUSH BP					;degerini korumak icin
			MOV BP, SP				;base pointer ile erismek icin 
			PUSH AX
			MOV AX, [BP+6]			;stackte sirayla DS, AX, n, CS ve OFFSET oldugundan ve word tipinde oldugundan BP her bir kademede +2 ilerliyor 
			
			CMP AX, 0				; n = 0 ise 						|		BP		| SP -> BP
			JE L2					;									|---------------|	
			CMP AX, 1				; n = 1 ise							|	  offset	| [BP+2]
			JE L1					;									|---------------|	
			CMP AX, 2				; n = 2 ise							|	   CS		| [BP+4]
			JE L1					;									|---------------|
									;									|	   n		| [BP+6]
			PUSH BX					;									|---------------|	
			PUSH DX  				;									|	   AX		|
			PUSH CX					;									|---------------|
			PUSH DI					;									|	   DS		|
									;									|---------------|				
			MOV BX, AX
			DEC BX					; BX <-  n-1		
			PUSH BX
			CALL DNUM				;  D(n-1)
			POP DI
			MOV BX, AX
			SUB BX, 2				; BX <-  n-2
			PUSH BX
			CALL DNUM				; D(n-2)
			POP CX	
			MOV BX, AX
			DEC BX					; BX <-  n-1
			SUB BX, CX				; BX <- n-1-D(n-2) 
			PUSH BX
			CALL DNUM				; D(D(n-1))
			POP DX	
			PUSH DI
			CALL DNUM				; D(n-1-D(n-2))
			POP BX
			ADD BX, DX				; BX <- D(D(n-1))+D(n-1-D(n-2))
			MOV [BP+6], BX		    
				
			POP DI
			POP CX				
			POP DX		
			POP BX		
			
			JMP SON
			
L2:			MOV WORD PTR [BP+6], 0
			JMP SON

L1:  		MOV WORD PTR [BP+6], 1
 	
SON:		POP AX
			POP BP
			RETF
DNUM		ENDP
mycs		ENDS
			END MAIN