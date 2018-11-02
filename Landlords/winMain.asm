; #########################################################################
; 
;
; #########################################################################


.386
.model flat, stdcall
option casemap:none

INCLUDE winMain.inc

.code

;-----------------------------------------------------
handleNewEvent PROC,
	_pack: PTR GamePack
; 函数功能 : 解析数据包
; 返回值 : null
 LOCAL @ps:PAINTSTRUCT
;-----------------------------------------------------
	pushad
	mov edi, _pack
	mov cl, (GamePack PTR [edi]).status
	
	;第一次接受数据：已就绪，分配玩家编号
	.if cl == game_NoStart
		mov al, (GamePack PTR [edi]).now_player
		mov playerNo, al
	.elseif cl == game_SendCard
		invoke updateScene,hWinMain,edi,addr operate,addr playerNo
	.elseif cl == game_GetLandlord
		mov ebx,0
		mov bl, (GamePack PTR [edi]).now_player
		.if bl == playerNo
			mov operate,1
		.endif
		invoke updateScene,hWinMain,edi,addr operate,addr playerNo
	.elseif cl == game_SendLandlordCard
		invoke updateScene,hWinMain,edi,addr operate,addr playerNo
	.elseif cl == game_Discard
		mov ebx,0
		mov bl, (GamePack PTR [edi]).now_player
		.if bl == playerNo
			mov operate,1
		.endif
		invoke updateScene,hWinMain,edi,addr operate,addr playerNo
	.elseif cl == game_GameOver
		invoke gameOver,hWinMain
	.endif
	popad
	ret

handleNewEvent ENDP

;================================================
gameInit proc uses edi, hwnd:HWND
;游戏初始化
 LOCAL @ps:PAINTSTRUCT
;---------------------------
	pushad

	;刷新画面
	lea edi,my_game
	invoke BeginPaint,hwnd,addr @ps
	invoke updateScene,hwnd,edi,addr operate,addr playerNo
	invoke EndPaint,hwnd,addr @ps
	popad
	ret
gameInit endp
;================================================


;================================================
gameOver proc hwnd:HWND
;游戏结束
;-----------------------------
	pushad
	lea edi,my_game
	lea esi,(GamePack PTR [edi]).all_players
	mov eax,SIZEOF Player
	mov ebx,3
	mul ebx
	add eax,esi
	.while esi<eax
		mov cl,(Player PTR [esi]).player_position
		mov ch,(Player PTR [esi]).cards_num
		.if ch == 0
			.if cl==0
				invoke MessageBox,hwnd,addr peasantWinStr,addr overMsg,MB_OK
			.elseif cl==1
				invoke MessageBox,hwnd,addr landLordWinStr,addr overMsg,MB_OK
			.endif
			.break
		.endif
		add esi,SIZEOF Player
	.endw
	push eax
	invoke updateScene,hWinMain,edi,addr operate,addr playerNo
	pop eax
	.if eax == IDOK
		invoke gameInit,hwnd
		mov operate,2
	.endif

	popad
	ret
gameOver endp
;================================================


;================================================
procWinMain proc uses ebx edi esi, hWnd, uMsg, wParam, lParam
;窗口事件处理函数
  LOCAL @hDc:HDC ;窗口对应的DC
  LOCAL @hInstance:HINSTANCE
  LOCAL @oldPen:HPEN
  LOCAL @ps:PAINTSTRUCT
;-----------------------------
	mov eax, uMsg
	.if eax == WM_CREATE
		invoke initScene, hWnd
	.elseif eax == WM_LBUTTONDOWN
		lea edi,my_game
		invoke click,hWnd,lParam,0,edi,addr operate,addr playerNo

	.elseif eax == WM_RBUTTONDOWN
		;mov operate,0
	;	invoke gameOver,hWnd,WIN

	.elseif eax == WM_PAINT
		lea edi,my_game
		invoke BeginPaint,hWnd,addr @ps
		invoke updateScene,hWnd,edi,addr operate,addr playerNo
		invoke EndPaint,hWnd,addr @ps

	.elseif eax == WM_SOCKET
		invoke recv, _sock, addr my_game, SIZEOF GamePack, 0
		.if eax != SOCKET_ERROR
			lea ebx,my_game
			invoke handleNewEvent, addr my_game
		.endif

	.else
		invoke DefWindowProc, hWnd, uMsg, wParam, lParam
		ret
		
	.endif
	
	xor eax, eax
	ret
procWinMain endp
;================================================


;================================================
WinMain proc uses ebx
	LOCAL @stWndClass:WNDCLASSEX
	LOCAL @stMsg:MSG
	LOCAL @hInstance:HINSTANCE
	invoke GetModuleHandle, 0
	mov @hInstance, eax
	invoke RtlZeroMemory, addr @stWndClass, sizeof @stWndClass
	
	; Register window class
	invoke LoadCursor, 0, IDC_ARROW
	mov @stWndClass.hCursor, eax
	push @hInstance
	pop @stWndClass.hInstance
	mov @stWndClass.cbSize, sizeof WNDCLASSEX
	mov @stWndClass.style, CS_HREDRAW or CS_VREDRAW
	mov @stWndClass.lpfnWndProc, offset procWinMain
	mov @stWndClass.hbrBackground, COLOR_WINDOW + 1
	mov @stWndClass.lpszClassName, offset wndClassname
	invoke RegisterClassEx, addr @stWndClass

	; Create and show window
	mov ebx, WS_OVERLAPPEDWINDOW
	xor ebx, WS_THICKFRAME
	invoke CreateWindowEx,WS_EX_CLIENTEDGE, addr wndClassname, addr Captionname,\
		ebx,100, 100, WND_WIDTH, WND_HEIGHT,\
		NULL, NULL, @hInstance, NULL
	mov hWinMain, eax

	invoke ShowWindow, hWinMain, SW_SHOWNORMAL
	invoke UpdateWindow, hWinMain

	invoke initClient,addr _sock
	invoke WSAAsyncSelect, _sock, hWinMain, WM_SOCKET, FD_READ

	;message loop
	.while TRUE
		invoke GetMessage, addr @stMsg, NULL, 0, 0
		.break .if eax == 0
		invoke TranslateMessage, addr @stMsg
		invoke DispatchMessage, addr @stMsg

		.if operate == 2
			mov eax,SOCKET_ERROR
			.repeat 
				;发送数据包
				invoke send, _sock,  addr my_game, SIZEOF GamePack, 0
			.until eax != SOCKET_ERROR
			mov operate,0
			invoke updateScene,hWinMain,addr my_game,addr operate,addr playerNo
		.endif
	.endw

	ret

WinMain endp
;================================================

;================================================
Main proc
	call WinMain
	invoke closesocket, _sock 
	invoke WSACleanup 
	invoke ExitProcess, 0
Main endp
;================================================

end Main