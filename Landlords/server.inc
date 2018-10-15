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
    sendPack PROTO, _hSock:DWORD,  _packAddr:PTR GAME_PACKAGE
	recvPack PROTO, _player:BYTE, _hSock:DWORD, _cmd:BYTE, _Pack: PTR GAME_PACKAGE
	ExitProcess PROTO, dwExitCode:DWORD


	;=============
    ; struct
    ;=============
	;在此处添结构体定义
	GAME_PACKAGE struct
		state BYTE ?
		player BYTE ?
		ifSuccess BYTE ?
		askLord BYTE ?
	GAME_PACKAGE ends

; #########################################################################


    .data
	wsaData WSADATA <>
	hListenSockAddr sockaddr_in <>
    minSock BYTE 1
    maxSock BYTE 4
    gameSock BYTE 0
	winner BYTE 5
    _sockNum DB "%c", 0
    szConnect BYTE "player %d connected, socket : %d", 0dh, 0ah, 0
    szInitSockNum BYTE "Input the player numbers(%d - %d players are allowed):", 0dh, 0ah, 0
	szErrRecv BYTE "receive packet error, from player %d", 0ah, 0dh, 0
	szErrSend BYTE "send packet error, to player %d", 0ah, 0dh, 0
	szWaitPack BYTE "wait pack from player %d", 0ah, 0dh, 0
	szRecvPack BYTE "receive pack , state : %x, from player %d", 0ah, 0dh, 0
	szSuccess byte "player %d success", 0ah, 0dh, 0
	szPackInfo BYTE "%s", 0ah, 0dh, 0
	szErrRequest BYTE "request error, from player %d", 0ah, 0dh, 0
	_msg DB "%x", 0ah, 0dh, 0 ; for test, print some info
	
	.const
	wsaVersion EQU 101h
	TCP_PORT EQU 9999
	szErrBind BYTE "port 9999 cannot be bind, please check this port if it has been employed", 0
	packLenth EQU 200

	;pack cmd
	S2C_READY EQU 00h            ;server to client
	S2C_LORDTURN EQU 01h            ;server to client
	C2S_ASKLORD EQU 82h          ;client to server : ask landlord
	S2C_REPLYLORD EQU 02h        ;server to client : reply landlord
	C2S_ISLORD EQU 83h        ;server to client : reply landlord
	S2C_ISLORD EQU 03h ;server to client : landlord or not
	S2C_PLAYTURN EQU 04h
	C2S_PLAYCARD EQU 85h
	S2C_PLAYCARD EQU 05h
	S2C_SUCCESS EQU 06h

	
	.data?
	hListenSock DWORD ?
	hWinMain DWORD ?
	connectedSockList DWORD 4 DUP(?)
	landLord BYTE ?
	
		
; #########################################################################