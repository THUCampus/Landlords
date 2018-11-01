.386
.MODEL  Flat, StdCall
option casemap: none
; #########################################################################

	;=================
	; include files
	;=================
	include windows.inc
	include wsock32.inc
    include msvcrt.inc
	include masm32.inc
	include kernel32.inc
	
	include game.inc


	;=================
	; libraries
	;================= 
	includelib wsock32.lib
    includelib msvcrt.lib
	includelib masm32.lib
	includelib kernel32.lib
	
; #########################################################################

	;=================
    ; Local prototypes
    ;=================
	;在此处添加函数
    initServer PROTO
    listenSocket PROTO
    sendPack PROTO, _hSock:DWORD,  _packAddr:PTR GamePack
	recvPack PROTO, _hSock:DWORD,  _Pack: PTR GamePack
	ExitProcess PROTO, dwExitCode:DWORD


; #########################################################################


    .data
	my_game GamePack  <>
	wsaData WSADATA <>
	hListenSockAddr sockaddr_in <>

    minSock BYTE 1
    maxSock BYTE 4
    gameSock BYTE 0

    _printC DB "%c", 0

	.const
	wsaVersion EQU 101h
	TCP_PORT EQU 9999

	szErrBindStr BYTE "port 9999 cannot be bind, please check this port if it has been employed", 0
    szConnectStr BYTE "player %d connected, socket : %d", 0dh, 0ah, 0
    szInitSockNumStr BYTE "Input the player numbers(%d - %d players are allowed):", 0dh, 0ah, 0
		
	.data?
	hListenSock DWORD ?
	hWinMain DWORD ?
	connectedSockList DWORD 4 DUP(?)
	
		
; #########################################################################