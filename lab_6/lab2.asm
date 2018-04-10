TESTPC	SEGMENT 
        ASSUME  CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING 
        org 100H	
				
START:  JMP BEGIN	

NO_ACCESS_M	db	'Address of inaccessible memory:      ',0dh,0ah,'$'
SEG_ADDRESS_LINE		db	'Segment address:   ',0dh,0ah,'$'
COM_TEXT	db	'Tail of command line:          ',0dh,0ah,'$'
SREDA_CONTENTS_LINE	db	'Enviroment contents:',0dh,0ah,'$'
DIRECT_LINE	db	'Directory of modul:',0dh,0ah,'$'
NEW_LINE	db	' ',0dh,0ah,'$'
NEW_SYMB DB 'Enter new symbol: ','$'
BUFF DB 1, 3 DUP (?)

TETR_TO_HEX PROC near

	and AL,0Fh
	cmp AL,09
	jbe NEXT
	add AL,07
NEXT:	add AL,30h
	ret
TETR_TO_HEX ENDP

BYTE_TO_HEX PROC near
;байт AL переводится в два символа шестн. числа в AX
	push CX
	mov AH,AL
	call TETR_TO_HEX
	xchg AL,AH
	mov CL,4
	shr AL,CL
	call TETR_TO_HEX  ;в AL - старшая, в AH - младшая
	pop CX
	ret
BYTE_TO_HEX ENDP

WRD_TO_HEX PROC near
;перевод в 16 с/с 16-ти разрядного числа
;в AX - число, DI - адрес последнего символа
	push BX
	mov BH,AH
	call BYTE_TO_HEX
	mov [DI],AH
	dec DI
	mov [DI],AL
	dec DI
	mov AL,BH
	call BYTE_TO_HEX
	mov [DI],AH
	dec DI
	mov [DI],AL
	pop BX
	ret
WRD_TO_HEX ENDP

BYTE_TO_DEC PROC near
;перевод в 10с/с, SI - адрес поля младшей цифры
	push CX
	push DX
	xor AH,AH
	xor DX,DX
	mov CX,10
loop_bd: div CX
	or DL,30h
	mov [SI],DL
	dec SI
	xor DX,DX
	cmp AX,10
	jae loop_bd
	cmp AL,00h
	je end_l
	or AL,30h
	mov [SI],AL
end_l:	pop DX
	pop CX
	ret
BYTE_TO_DEC ENDP

NO_ACCESS_MEMORY 	PROC NEAR
		push ax
		push di
		mov ax, ds:[2h]
		mov di, offset NO_ACCESS_M
		add di, 34
		call WRD_TO_HEX
		pop di
		pop ax
		ret
NO_ACCESS_MEMORY 	ENDP

SEG_ADDRESS 		PROC NEAR
		push ax
		push di

		mov ax, ds:[2Ch]
		mov di, offset SEG_ADDRESS_LINE
		add di, 19
		call WRD_TO_HEX

		pop di
		pop ax
		ret
SEG_ADDRESS 		ENDP

TAIL_COM_LINE 		PROC NEAR

		push ax
		push cx
		push dx	
		push si
		push di
	
		xor cx, cx
		mov ch, ds:[80h] 
		mov si, 81h
		mov di, offset COM_TEXT
		add di, 21
	copy_Line:
		cmp ch, 0h
		je fin

		mov al, ds:[si]
		mov [di], al   
		inc di 
		inc si 
		dec ch
		jmp copy_line 
	fin:
		mov al, 0h
		mov [di], al
	
		pop di
		pop si
		pop dx
		pop cx
		pop ax
		ret
TAIL_COM_LINE 		ENDP

SREDA_CONTENTS 		PROC NEAR
		push ax
		push dx
		push ds	
		push es
		


 		mov ah, 2h
		mov es, ds:[2Ch]
		xor si,si
	copy:
		mov dl, es:[si]
		int 21h
		cmp dl, 0h
		je final
		inc si
		jmp copy

	final:
		mov dx, offset NEW_LINE
		call  PRINT
		inc si
		mov dl, es:[si]
		cmp dl, 0h
		jne copy

		mov dx, offset NEW_LINE
		call PRINT
	
		mov dx, offset DIRECT_LINE
		call PRINT
	
		add si, 3h
		mov ah, 02h
		mov es, ds:[2Ch]
	write_dir:
		mov dl, es:[si]
		cmp dl, 0h
		je end_dir
		int 21h
		inc si
		jmp write_dir
	end_dir:
		nop
 	
		pop es
		pop ds
		pop dx
		pop ax
		ret
SREDA_CONTENTS 		ENDP


PRINT		PROC near
		push ax
		mov 	ah,09h
		int		21h
		pop ax
		ret
PRINT		ENDP



; КОД
BEGIN:
		call NO_ACCESS_MEMORY			
		mov dx, offset NO_ACCESS_M
		call PRINT
		mov dx, offset NEW_LINE
		call PRINT

                call SEG_ADDRESS			
		mov dx, offset SEG_ADDRESS_LINE
		call PRINT
		mov dx, offset NEW_LINE
		call PRINT

		call TAIL_COM_LINE
		mov dx, offset COM_TEXT
		call PRINT
		mov dx, offset NEW_LINE
		call PRINT
		mov dx, offset SREDA_CONTENTS_LINE
		call PRINT
		
		call SREDA_CONTENTS				
	;;;
		mov dx, offset NEW_LINE
		call PRINT
		mov dx, offset NEW_SYMB
		call PRINT
		
	    xor ax,ax
		;mov  ds,   ax 
        mov  bp,   offset BUFF
        mov  al,   2
        mov  [bp], al
        mov  dx,   bp
        mov  ah,   10
        int  21h
		mov  si, offset BUFF
		mov  al,  [si+02]
        mov  ah,   4ch
        int  21h	
	;;;
; выход в DOS
	xor al, al
	mov ah, 4ch
	int 21h
	
TESTPC 	ENDS
		END START	; конец модуля

