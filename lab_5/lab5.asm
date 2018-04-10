code segment
	assume cs:code, ds:data, ss:stk
start_m:
	PSP dw 0
	KEEP_CS dw 0
	KEEP_IP dw 0
	LOAD_COUNT dw 0
	CALL_MY_INT_MESS1 db 'Laboratornaya rabota #5', 10, 13, '$'
	CALL_MY_INT_MESS2 db 'Made by Vaigachev Andrei', 10, 13, '$'
	CALL_MY_INT_MESS3 db 'Group 6382', 10, 13, '$'
	CALL_MY_INT_MESS4 db '<--------------------->', 10, 13, '$'

	DEFAULT_INT_ADDRESS dd 0
push_main macro
	push ax
	push bx
	push cx
	push dx
endm

pop_main macro
	pop dx
	pop cx
	pop bx
	pop ax
endm

calc_cx proc
	push dx
	push bp
	dec bp
	xor cx,cx
	dec cx
loop_calc_cx_m:
	inc cx
	inc bp
	mov dl,es:[bp]
	cmp dl,'$'
	jnz loop_calc_cx_m
	pop bp
	pop dx
	ret
calc_cx endp

GetCurs	proc near
	push ax
	push bx
	push cx
	mov ah,03h
	mov bh,0
	mov bl, 7
	int 10h
	pop cx
	pop bx
	pop ax
	ret
GetCurs	endp

print_int macro	Seg_var, var
	push_main
	push bp
	push es
	mov ax, seg Seg_var
	mov es, ax
	lea bp, ES:var
	
	call calc_cx
	
	mov ax, 1301h
	mov bx, 0007h
	call GetCurs

	int 10h

	pop es
	pop bp
	pop_main
endm

print_my_int_mess proc near
	push_main
	;push si
	;push ds
	cmp cs:LOAD_COUNT, 4
	jnz next_print_my_int_mess_m
	mov cs:LOAD_COUNT, 0
	
next_print_my_int_mess_m:
	cmp cs:LOAD_COUNT, 0
	jz m1_print_my_int_mess_m
	cmp cs:LOAD_COUNT, 1
	jz m2_print_my_int_mess_m
	cmp cs:LOAD_COUNT, 2
	jz m3_print_my_int_mess_m
	jmp m4_print_my_int_mess_m
	
m1_print_my_int_mess_m:
	print_int code, CALL_MY_INT_MESS1
	jmp end_print_my_int_mess_m
m2_print_my_int_mess_m:
	print_int code, CALL_MY_INT_MESS2
	jmp end_print_my_int_mess_m
m3_print_my_int_mess_m:
	print_int code, CALL_MY_INT_MESS3
	jmp end_print_my_int_mess_m
m4_print_my_int_mess_m:
	print_int code, CALL_MY_INT_MESS4
	jmp end_print_my_int_mess_m
	
end_print_my_int_mess_m:
	inc cs:LOAD_COUNT
	pop_main
	ret
print_my_int_mess endp

my_int proc far
	jmp body_my_int_m
	INT_SET_FLAG dw 1111h
body_my_int_m:
	push_main
	push si
	push ds
	push es
	xor ax,ax
	in al, 60h
	push ax
	push es
	mov ax, 40h
	mov es, ax
	mov ax, es:[17h]
	and ax, 0100000001000000b ; num lock
	pop es
	pop ax
	jz default_int_my_int_m
	
	cmp al, 10h ;'q'=10h
	jl default_int_my_int_m
	cmp al, 19h ; 'p' =19h
	jg middle_key_my_int_m
	jmp my_my_int_m
middle_key_my_int_m:
	cmp al, 1Eh ; 'a' = 1Eh
	jl default_int_my_int_m
	cmp al, 26h ; 'l'=26h
	jg low_key_my_int_m
	jmp my_my_int_m
low_key_my_int_m:
	cmp al, 2Ch ; 'z'=2Ch
	jl default_int_my_int_m
	cmp al, 32h ;'m' =32h
	jg default_int_my_int_m	
	jmp my_my_int_m
default_int_my_int_m:
	pop es
	pop ds
	pop si
	pop_main
	jmp DEFAULT_INT_ADDRESS
	;default int
	
my_my_int_m:
	push ax
	
	in al, 61H
	mov ah, al
	or al, 80h
	out 61h, al
	xchg ah, al
	out 61h, al
	mov al, 20h
	out 20h, al
	
	pop ax
	push ax
	call print_my_int_mess
	pop ax
	
	pop es
	pop ds
	pop si
	pop_main
	mov al, 20h
	out 20h, al
	iret
my_int endp
end_resident_m:

_print  proc  near
          mov   ah,09h
          int   21h 
          ret
_print  endp

print macro strParam
	push dx
	push ax
	xor ax, ax
	xor dx, dx
	lea dx, strParam
	call _print
	pop ax
	pop dx
endm

TETR_TO_HEX PROC near
	and AL,0Fh 
	cmp AL,09 
	jbe NEXT 
	add AL,07 
NEXT: 
	add AL,30h 
	ret 
TETR_TO_HEX ENDP 
;------------------------------- 

BYTE_TO_HEX PROC near 
;Byte in AL converted to two HEX symbols in AX
	push CX 
	mov AH,AL 
	call TETR_TO_HEX 
	xchg AL,AH 
	mov CL,4 
	shr AL,CL 
	call TETR_TO_HEX ; in AL high order digit
	pop CX ;in AH low
	ret 
BYTE_TO_HEX ENDP 
;------------------------------- 

WRD_TO_HEX PROC near 
;convert to HEx 16 bits num
; ax -num, di - last symbol address
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
;--------------------------------------------------

BYTE_TO_DEC PROC near 
; convert to dec, SI - low order digit
	push CX 
	push DX 
	xor DX,DX 
	mov CX,10 
loop_bd: 
	div CX 
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
end_l: 
	pop DX 
	pop CX 
	ret 
BYTE_TO_DEC ENDP 
;------------------------------- 

printByte	macro byteReg
		push_main
		xor ah, ah
		mov al, byteReg
		call BYTE_TO_HEX
		mov bx, ax
		mov dl, ah
		mov ah, 02
		int 21h
		mov ax, bx
		mov dl, al
		mov ah, 02
		int 21h
		pop_main
endm

old_int_save proc near
	push_main
	push es
	push di
	mov ax, 3509h
	int 21h
	mov cs:KEEP_IP, bx
	mov cs:KEEP_CS, es
	mov word ptr DEFAULT_INT_ADDRESS+2, es
	mov word ptr DEFAULT_INT_ADDRESS, bx
	lea di, OLD_INT_ADDR
	add di, 23
	mov ax, es
	call WRD_TO_HEX
	add di, 8
	mov ax, bx
	call WRD_TO_HEX
	print OLD_INT_ADDR
	print NEXT_LINE
	pop di
	pop es
	pop_main
	ret
old_int_save endp
	
set_new_int proc near
	push_main
	push ds
	mov dx, offset my_int
	mov ax, seg my_int
	push ax
	push dx
	
	lea di, NEW_INT_ADDR
	add di, 23
	call WRD_TO_HEX
	add di, 8
	mov ax, dx
	call WRD_TO_HEX
	print NEW_INT_ADDR
	
	print NEXT_LINE
	print PRESS_ANY_KEY
	print NEXT_LINE
	print MY_INT_INST
	print NEXT_LINE
	xor al, al
	mov ah, 1
	int 21h
	pop dx
	pop ax
	mov ds, ax
	mov ax, 2509h
	int 21h
	pop ds
	pop_main
	ret
set_new_int endp
	
load_my_int proc near	
	mov dx, seg code	
	add dx, (end_resident_m-start_m)
	mov cl, 4
	shr dx, cl ;div 16
	inc dx
	xor ax, ax
	mov ah, 31h
	int 21h
	ret
load_my_int endp
	
delete_my_int proc near
	cli
	push_main
	push ds
	push es
	push di
	
	mov ax, 3509h
	int 21h
	mov ax, es:[2]
	mov cs:KEEP_CS, ax
	mov ax, es:[4]
	mov cs:KEEP_IP, ax
	
	mov ax, cs:KEEP_CS
	mov dx, cs:KEEP_IP
	lea di, DELETE_OLD_INT
	add di, 60
	mov ax, cs:KEEP_CS
	call WRD_TO_HEX
	add di, 8
	mov ax, cs:KEEP_IP
	call WRD_TO_HEX
	print NEXT_LINE
	print DELETE_OLD_INT
	
	mov ax, es:[0]
	mov cx, ax
	mov es, ax
	mov ax, es:[2Ch]
	mov es, ax
	xor ax, ax
	mov ah, 49h
	int 21h
	mov es, cx
	xor ax, ax
	mov ah, 49h
	int 21h
	mov dx, cs:KEEP_IP
	mov ax, cs:KEEP_CS
	mov ds, ax
	mov ax, 2509h	
	int 21h
	
	pop di
	pop es
	pop ds
	pop_main
	sti
	ret
delete_my_int endp

main proc near

	push ds
	mov ax, seg data
	mov ds, ax
	pop cs:PSP
	
	mov es, cs:PSP
	mov al, es:[80h]
	cmp al, 4
	jnz tail_is_empty_main_m

	mov ax, es:[82h]
	cmp al, '/'
	jnz tail_is_empty_main_m
	cmp ah, 'u'
	jnz tail_is_empty_main_m
	mov ah, es:[84h]
	cmp ah, 'n'
	jnz tail_is_empty_main_m
	mov DEL_USER_INT_FLAG, 1
	jmp next_main_m
tail_is_empty_main_m:
	
next_main_m:
	mov ax, 3509h
	int 21h
	mov ax, es:[bx+3]
	cmp ax, 1111h
	jz int_already_inst_main_m
	
	cmp DEL_USER_INT_FLAG, 1
	jz not_inst_my_int_main_m
	
	call old_int_save
	call set_new_int
	call load_my_int
	
	print TEST_PRINT
	print NEXT_LINE
	jmp end_main_m
int_already_inst_main_m:
	cmp DEL_USER_INT_FLAG, 1
	jz delete_my_int_main_m
	print MY_INT_ALREADY_INSTALL
	jmp end_main_m
delete_my_int_main_m:
	call delete_my_int
	jmp end_main_m
not_inst_my_int_main_m:
	print INT_NOT_INST
	jmp end_main_m
end_main_m:
	xor al, al
	mov ah, 4Ch
	int 21h
	ret
main endp

code ends

data segment
	DEL_USER_INT_FLAG db 0
	NEXT_LINE db	10, 13, '$'
	SPACE db ' $'
	DEFAULT_INT	db 'default interrupt installed', 10, 13, '$'
	MY_INT_INST	db 'user interrupt installed!', 10, 13, '$'
	MY_INT_ALREADY_INSTALL	db 'user interrupt already installed', 10, 13, '$'
	OLD_INT_ADDR db 'address of old int:     :       ', 10, 13, '$'
	NEW_INT_ADDR db 'address of new int:     :       ', 10, 13, '$'
	PRESS_ANY_KEY db 'press any key', 10, 13, '$'
	DELETE_OLD_INT db 'user interrupt was deleted. Restore default int. Addres:     :     ', 10, 13, '$'
	INT_NOT_INST db 'user int not installed ', 10, 13, '$'
	TEST_PRINT db '!!!!!!!!!!!', 10, 13, '$'
	
data ends

stk segment stack
	dw 128 dup (?)
stk ends


end main
