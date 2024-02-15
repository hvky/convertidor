format PE GUI 4.0
entry inicio

include 'c:/fasm/include/win32ax.inc'


; ********************     CONSTANTES     ********************
main			= 1
id_input		= 1001
id_btn_in_bi	= 1003
id_btn_in_oc	= 1004
id_btn_in_de	= 1005
id_btn_in_he	= 1006
id_bnt_out_bi	= 1008
id_btn_out_oc	= 1009
id_btn_out_de	= 1010
id_btn_out_he	= 1011
id_bnt_convert	= 1012
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

	mov eax,1
	jmp finish

jCOMMAND:
	mov eax,[wParam]

	xor eax,eax
	jmp finish

jCLOSE:
	invoke EndDialog,[hWnd],0
	mov eax,1

finish:
	ret
endp


; ********************     VARIABLES     ********************
section '.data' data readable writeable

Ist  dd 0
pWnd dd 0


; ********************     RECURSOS     ********************
section '.idata' import data readable writeable
	library kernel32,'KERNEL32.DLL',\
			user32,'USER32.DLL',\
			gdi32,'GDI32.DLL'

	include 'c:/fasm/include/api\kernel32.inc'
	include 'c:/fasm/include/api\user32.inc'
	include 'c:/fasm/include/api\gdi32.inc'

section '.rsrc' resource from 'convertidor.res' data readable
