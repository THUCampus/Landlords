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
	parsePack PROTO, _pack: PTR GAME_PACKAGE
	handleMessage PROTO

    ;=============
    ; Struct
    ;=============
	;在此处添加结构体定义
	GAME_PACKAGE struct
		state BYTE ?
		player BYTE ?
		ifSuccess BYTE ?
		askLord BYTE ?
		
	GAME_PACKAGE ends

; #########################################################################
	


    .data
	wsaData WSADATA <>
    _sockAddr sockaddr_in <>   ;sockInfo need to connect
	ipBuf BYTE "%s", 0
    ipString BYTE 16 DUP(0)
	;ipInputFormt BYTE "Input server ip:", 0ah, 0dh, 0;"%s", 0

	_msg BYTE "%s", 0ah, 0dh, 0 ;for test, print some info

	.const
	wsaVersion EQU 101h
	TCP_PORT EQU 9999
	WM_SOCKET EQU WM_USER+100
	szErrIP BYTE "ip address wrong", 0ah, 0dh, 0
	;szErrConnect EQU "Port 9999 cannot be connected. Please check if it opens"
	;szWaitPack BYTE "wait pack from player %d", 0ah, 0dh, 0
	szRecvPack BYTE "receive pack : %x, player: %x", 0ah, 0dh, 0
	szErrPlayer BYTE "player wrong",  0ah, 0dh, 0

	;pack cmd
	S2C_READY EQU 00h           
	S2C_LORDTURN EQU 01h           
	C2S_ASKLORD EQU 82h          
	S2C_REPLYLORD EQU 02h        
	C2S_ISLORD EQU 83h       
	S2C_ISLORD EQU 03h 
	S2C_PLAYTURN EQU 04h
	C2S_PLAYCARD EQU 85h
	S2C_PLAYCARD EQU 05h
	S2C_SUCCESS EQU 06h



	.data?
	_sock DWORD ?
	hwnd DWORD ?
	hWinMain DWORD ?

    player BYTE ?
		

; #########################################################################