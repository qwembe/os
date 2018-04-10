.model small
.data
WITH_CODE db 0dh, 0ah, 0dh, 0ah, "Process has been ended successfully with code: ", '$'
NO_FILE db "There is no file", 0dh, 0ah, '$'
CTRL_C db "Process has been ended with Ctrl+c key combination", 0dh, 0ah, '$'
PSP dw 0
FILENAME db 100 dup(0)
STRING_END db "$"
PARAMETRES dw 10 dup(0)
TAKE_SS dw 0
TAKE_SP dw 0
.stack 100h
.code
TETR_TO_HEX   PROC  near
	and      AL,0Fh
	cmp      AL,09
	jbe      NEXT
	add      AL,07
	NEXT:      add      AL,30h
	ret
TETR_TO_HEX   ENDP
BYTE_TO_HEX   PROC  near
; байт в AL переводится в два символа шестн. числа в AX
	push     CX
	mov      AH,AL
	call     TETR_TO_HEX
	xchg     AL,AH
	mov      CL,4
	shr      AL,CL
	call     TETR_TO_HEX ;в AL старшая цифра
	pop      CX          ;в AH младшая
	ret
BYTE_TO_HEX  ENDP
MAIN PROC
	mov ax, @data
	mov ds, ax
	push es
	mov es, es:[2Ch]
	xor si, si
	lea di, FILENAME
c1: 
	cmp byte ptr es:[si], 0
	je c2
	inc si
	jmp c3
c2: 
	inc si
c3: 
	cmp word ptr es:[si], 0
	jne c1
	add si, 4
c4:
	cmp byte ptr es:[si], 0
	je c5
	mov dl, es:[si]
	mov [di], dl
	inc si
	inc di
	jmp c4
c5: 
	sub di, 5
	mov dl, '2'
	mov [di], dl
	add di, 2
	mov dl, 'c'
	mov [di], dl
	inc di
	mov dl, 'o'
	mov [di], dl
	inc di
	mov dl, 'm'
	mov [di], dl
	inc di
	mov dl, 0h
	mov [di], dl
	inc di
	mov dl, STRING_END
	mov [di], dl
	pop es
	lea bx, program_end
	mov ax, es
	sub bx, ax
	mov cl, 4
	shr bx, cl
	mov ah, 4Ah
	int 21h
	jc exit
noterr:
	push ds
	pop es
	lea dx, FILENAME
	lea bx, PARAMETRES
	mov TAKE_SS, ss
	mov TAKE_SP, sp
	mov ax, 4b00h
	int 21h
	mov ss, TAKE_SS
	mov sp, TAKE_SP
	jc nld
	jmp ld
nld: 
	lea dx, NO_FILE
	mov ah, 9
	int 21h
	lea dx, FILENAME
	mov ah, 9
	int 21h
	jmp exit
ld:
	mov ah, 4Dh
	int 21h
	cmp ah, 1
	je ctrlc
	lea bx, WITH_CODE
	mov [bx], ax
	lea dx, WITH_CODE
	push ax
	mov ah, 9
	int 21h
	pop ax
	call BYTE_TO_HEX
	push ax
	mov dl, ' '
	mov ah, 2h
	int 21h
	pop ax
	push ax
	mov dl, al
	mov ah, 2h
	int 21h
	pop ax
	mov dl, ah
	mov ah, 2h
	int 21h
	jmp exit
ctrlc: 
	lea dx, CTRL_C
	mov ah, 9
	int 21h
exit:
	mov ah, 4Ch
	int 21h
MAIN ENDP
program_end:
end main