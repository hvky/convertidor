format PE GUI 4.0
entry inicio

include 'c:/fasm/include/win32ax.inc'


; ********************     CONSTANTES     ********************
ventana_1	= 1
salir_btn	= 1000


; ********************     CODIGO     ********************
section '.code' code readable executable

inicio:
	invoke GetModuleHandle,0
	mov [Ist],eax
	invoke DialogBoxParam,eax,ventana_1,0,DlgProc,0
fin:
	invoke ExitProcess,0


proc DlgProc,hWnd,uMsg,wParam,lParam
	push edi esi ebx

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
	cmp	eax,salir_btn
	je	salir
	xor eax,eax
	jmp finish

salir:
	invoke SendMessage,[hWnd],WM_CLOSE,0,0
	mov eax,1
	jmp finish

jCLOSE:
	invoke EndDialog,[hWnd],0
	mov eax,1

finish:
	pop ebx esi edi
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
