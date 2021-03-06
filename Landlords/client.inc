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
	include gdi32.inc
	include msimg32.inc

	include game.inc


	;=================
	; libraries
	;================= 
	includelib wsock32.lib
    includelib msvcrt.lib
	includelib masm32.lib
	includelib kernel32.lib
	includelib user32.lib
	includelib gdi32.lib
	includelib msimg32.lib
	

; #########################################################################

	;=================
    ; Local prototypes
    ;=================
	;在此处添加函数
    initClient PROTO,_sock_addr:PTR DWORD,ip_addr:PTR BYTE

	handleNewEvent PROTO, _pack: PTR GamePack
	gameOver PROTO hwnd:HWND

	initScene PROTO  hWnd:DWORD
	drawMyCards PROTO  hwnd:DWORD,_pack: PTR GamePack,playerNo_addr:PTR BYTE
	updateScene PROTO hwnd:DWORD,_pack: PTR GamePack,operate_addr:PTR BYTE,playerNo_addr:PTR BYTE
	click PROTO hWnd:DWORD, lParam:DWORD,stage:DWORD,_pack: PTR GamePack,operate_addr:PTR BYTE,playerNo_addr:PTR BYTE
	disMyCard PROTO _pack: PTR GamePack,playerNo_addr:PTR BYTE
	DisPlayer1Card PROTO _pack: PTR GamePack,playerNo_addr:PTR BYTE
	DisPlayer2Card PROTO _pack: PTR GamePack,playerNo_addr:PTR BYTE
	DrawPlayerCard PROTO _pack: PTR GamePack,playerNo_addr:PTR BYTE
	ShowBtn PROTO number:DWORD,_pack: PTR GamePack,operate_addr:PTR BYTE
	drawLandLordCards PROTO _pack: PTR GamePack
	drawRole PROTO _pack: PTR GamePack,playerNo_addr:PTR BYTE
	;=============

; #########################################################################
	
    .data
	my_game GamePack  <>
	wsaData WSADATA <>
    _sockAddr sockaddr_in <>

    ipString BYTE 20 DUP(0)
	_printS DB "%s", 0dh, 0ah, 0
	operate BYTE 0;0的时候不能操作，1的时候可以操作且进行中，2的时候操作结束

	;窗口句柄
	hWinMain dd ?
	hEdit dd ?
	
	;内存DC
	hdcScene dd ?;场景DC，其余DC先绘制到场景DC，再绘制到真正的DC，防止二次闪烁
	hdcBkg dd ?;背景
	hdcMyCards dd ?;画玩家手牌
	hdcCards dd ?;54张牌的正面
	hdcCardBack dd ?;牌背面
	hdcNoDiscard dd ?;“不出”字样
	hdcBtn dd ?;按钮
	hdcDiscardBtn dd ?
	hdcPassBtn dd ?
	hdcNoCallBtn dd ?
	hdcCallBtn dd ?
	hdcLDCard dd ?

	;位图DC
	hbmScene dd ?;
	hbmBkg dd ?;
	hbmMyCards dd ?;
	hbmCards dd ?;
	hbmCardBack  dd ?;
	hbmNoDiscard dd ?;
	hbmBtn dd ?;
	hbmDiscardBtn dd ?
	hbmPassBtn dd ?
	hbmNoCallBtn dd ?
	hbmCallBtn dd ?
	hbmLDCard dd ?

	;字体画刷等
	hbrush dd ?;背景画刷
	fontStyle db "Arial",0
	szFmt db '%d',0

	;位图、控件名称
	background BYTE 'background',0
	discard BYTE 'discard',0
	pass BYTE 'pass',0
	cards BYTE 'cards',0
	cardback BYTE 'cardback',0
	nodiscard BYTE 'nodiscard',0
	no BYTE 'no',0
	score1 BYTE 'score1',0
	wndClassname BYTE 'Landlords',0
	Captionname BYTE 'LandLords',0

	;需要维护的数据
	OrdOfMycards DWORD 54 dup(?);存放我的牌在MyCards中的下标，即牌面；不用维护
	cardNum DWORD 0;手牌张数
	startPos DWORD ?;手牌堆的起始位置，不用维护
	endPos DWORD ?;手牌堆的结束位置，不用维护

	peasantWinStr BYTE 'Peasants win!',0
	landLordWinStr BYTE 'Land lord win!',0
	overMsg BYTE 'game over',0
	landlordChar BYTE 'landlord',0
	peasantChar BYTE 'peasant',0
	editName BYTE 'edit',0
	editCaption BYTE 'Please enter ip address',0

	.const
	wsaVersion EQU 101h
	TCP_PORT EQU 9999
	WM_SOCKET equ WM_USER + 100
	WND_WIDTH EQU 860
	WND_HEIGHT EQU 540
	TOTAL_NUM EQU 54

	szErrIPStr BYTE "ip address wrong", 0ah, 0dh, 0
	

	.data?
	_sock DWORD ?
    playerNo BYTE ?

; #########################################################################

