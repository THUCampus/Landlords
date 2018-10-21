.386
.MODEL Flat, Stdcall
option casemap: none
; #########################################################################

	;=================
	; include files
	;=================
	;在此处添加引用文件
	include windows.inc
	include wsock32.inc
    include msvcrt.inc
	include masm32.inc
	include kernel32.inc
	include user32.inc

	include game.inc


	;=================
	; libraries
	;================= 
	includelib wsock32.lib
    includelib msvcrt.lib
	includelib masm32.lib
	includelib kernel32.lib
	includelib user32.lib
	

; #########################################################################

	;=================
    ; Local prototypes
    ;=================
	;在此处添加函数
    initClient PROTO
    ExitProcess PROTO, dwExitCode:DWORD
	parsePack PROTO, _pack: PTR GamePack
	handleMessage PROTO


; #########################################################################
	
    .data
	my_game GamePack  <>
	wsaData WSADATA <>
    _sockAddr sockaddr_in <>   ;sockInfo need to connect

	_printS BYTE "%s", 0
	_printS2 BYTE "%s", 0ah, 0dh, 0 ;for test, print some info
	_printD DB "%d ",0
    _printC DB "%c", 0
    ipString BYTE 16 DUP(0)
	chooseLandlord BYTE 0

	.const
	wsaVersion EQU 101h
	TCP_PORT EQU 9999

	szErrIPStr BYTE "ip address wrong", 0ah, 0dh, 0
	ipInputStr BYTE "Input server ip:",0ah, 0dh, 0
	landlordChooseStr BYTE "Would you like to be landlord?(1:Yes 0:No)",0ah, 0dh, 0
	cardsHaveStr BYTE "The cards you have now:",0ah,0dh,0
	cardsChooseStr BYTE 0ah,0dh,"Please pick cards out('+num':add card/'-num':delete num/'#':end/'p':pass):",0ah,0dh,0
	notYourTurnStr BYTE "Not your turn!",  0ah, 0dh, 0
	landLordWinStr BYTE "Game Over!Land lord win!",0ah,0dh,0
	peasantWinStr BYTE "Game Over!Peasants win!",0ah,0dh,0
	

	.data?
	_sock DWORD ?
	hwnd DWORD ?
	hWinMain DWORD ?

    playerNo BYTE ?
		

; #########################################################################