format PE GUI 4.0
entry inicio

include 'c:/fasm/include/win32ax.inc'


; ********************     MACROS     ********************
macro deshabilitar id {
	invoke GetDlgItem,[hWnd],id
	invoke EnableWindow,eax,FALSE
}

macro habilitar id {
	invoke GetDlgItem,[hWnd],id
	invoke EnableWindow,eax,TRUE
}

macro radioCheck id,etq {
	invoke IsDlgButtonChecked,[hWnd],id
	cmp eax,BST_CHECKED
	je etq
}

macro listCheck id,etq {
	invoke IsDlgButtonChecked,[hWnd],id
	cmp eax,BST_CHECKED
	jne etq
}

macro convert base {
	local ciclo_base,ciclo,ciclo_sig,ciclo_fin
	push eax ebx ecx edx

	mov eax,base
	mov ebx,base
	call tamBuffer
	cmp ecx,0
	je ciclo_fin

	dec ecx
	ciclo_base:
		mul ebx
		loop ciclo_base

	xor ecx,ecx
	lea esi,[buffer]
	ciclo:
		cmp byte [esi],0
		je ciclo_fin

		mov edx,0
		div ebx
		xor edx,edx
		mov dl,[esi]
		sub dl,30h
		cmp dl,9
		jbe ciclo_sig
		sub dl,7

		ciclo_sig:
			push eax
			mul edx
			add ecx,eax
			pop eax

		inc si
		jmp ciclo

	ciclo_fin:
		mov [number],ecx
		pop edx ecx ebx eax
}

macro convert2K var,i,x {
	local ciclo,ciclo_sig,ciclo_fin
	push ebx ecx edx

	mov bl,0
	mov cl,20h
	sub cl,i
	add cl,x
	lea esi,[var]

	ciclo:
		cmp bl,20h
		jae ciclo_fin

		mov edx,[number]
		push ecx
		mov cl,bl
		shl edx,cl
		pop ecx
		shr edx,cl

		cmp dl,0Ah
		jb ciclo_sig
		add dl,7

		ciclo_sig:
			add dl,30h
			mov [esi],dl

		add bl,i
		inc esi
		jmp ciclo

	ciclo_fin:
		pop edx ecx ebx
}


; ********************     CONSTANTES     ********************
main			= 1
id_input		= 1001
id_btn_in_bi	= 1003
id_btn_in_oc	= 1004
id_btn_in_de	= 1005
id_btn_in_he	= 1006
id_btn_out_bi	= 1008
id_btn_out_oc	= 1009
id_btn_out_de	= 1010
id_btn_out_he	= 1011
id_btn_convert	= 1012
id_out_bi		= 1019
id_out_oc		= 1020
id_out_de		= 1021
id_out_he		= 1022


; ********************     CODIGO     ********************
section '.code' code readable executable

inicio:
	invoke GetModuleHandle,0
	mov [Ist],eax
	invoke DialogBoxParam,eax,main,0,DlgProc,0
fin:
	invoke ExitProcess,0


proc DlgProc uses edi esi ebx,hWnd,uMsg,wParam,lParam
	mov eax,[uMsg]
	cmp	eax,WM_COMMAND
	je	jCOMMAND
	cmp	eax,WM_INITDIALOG
	je	jINITDIALOG
	cmp	eax,WM_CLOSE
	je	jCLOSE
	xor eax,eax
	jmp finish

jINITDIALOG:
	mov eax,[hWnd]
	mov [pWnd],eax

	deshabilitar id_btn_convert

	mov eax,1
	jmp finish

jCOMMAND:
	mov eax,[wParam]

	cmp eax,id_btn_convert
	je convertir

	cmp eax,id_btn_in_bi
	jae habilitar_convertir
	habilitar_convertir:
		cmp eax,id_btn_in_he
		ja jCOMMAND_finish
		habilitar id_btn_convert

jCOMMAND_finish:
	xor eax,eax
	jmp finish

convertir:
	invoke GetDlgItemText,[hWnd],id_input,buffer,33

	radioCheck id_btn_in_bi,in_bi
	radioCheck id_btn_in_oc,in_oc
	radioCheck id_btn_in_de,in_de

	convert 10h
	jmp convertir_sig
	in_bi:
		convert 02h
		jmp convertir_sig
	in_oc:
		convert 08h
		jmp convertir_sig
	in_de:
		convert 0Ah

convertir_sig:
	call desmarcar
	listCheck id_btn_out_bi,out_bi_sig

	out_bi:
		convert2K binario,1,0
		invoke SetDlgItemText,[pWnd],id_out_bi,binario
	out_bi_sig:
		listCheck id_btn_out_oc,out_oc_sig

	out_oc:
		convert2K octal,3,1
		invoke SetDlgItemText,[pWnd],id_out_oc,octal
	out_oc_sig:
		listCheck id_btn_out_de,out_de_sig

	out_de:
		invoke wsprintf,decimal,'%d',[number]
		invoke SetDlgItemText,[pWnd],id_out_de,decimal
	out_de_sig:
		listCheck id_btn_out_he,out_he_sig

	out_he:
		convert2K hexadecimal,4,0
		invoke SetDlgItemText,[pWnd],id_out_he,hexadecimal
	out_he_sig:
		jmp jCOMMAND_finish

jCLOSE:
	invoke EndDialog,[hWnd],0
	mov eax,1

finish:
	ret
endp


; ********************     PROCEDIMIENTOS     ********************
proc desmarcar
	invoke SetDlgItemText,[pWnd],id_out_bi,0
	invoke SetDlgItemText,[pWnd],id_out_oc,0
	invoke SetDlgItemText,[pWnd],id_out_de,0
	invoke SetDlgItemText,[pWnd],id_out_he,0
ret
endp

proc tamBuffer uses esi
	lea esi,[buffer]
	xor ecx,ecx

ciclo:
	cmp byte [esi],0
	je ciclo_fin

	inc si
	inc ecx
	jmp ciclo

ciclo_fin:
	ret
endp


; ********************     VARIABLES     ********************
section '.data' data readable writeable

Ist  		dd 0
pWnd 		dd 0
number 		dd 0

buffer 		db 256 dup(?)
binario		db 33 dup(?)
octal		db 12 dup(?)
decimal		db 11 dup(?)
hexadecimal	db 9 dup(?)


; ********************     RECURSOS     ********************
section '.idata' import data readable writeable
	library kernel32,'KERNEL32.DLL',\
			user32,'USER32.DLL',\
			gdi32,'GDI32.DLL'

	include 'c:/fasm/include/api\kernel32.inc'
	include 'c:/fasm/include/api\user32.inc'
	include 'c:/fasm/include/api\gdi32.inc'

section '.rsrc' resource from 'convertidor.res' data readable
