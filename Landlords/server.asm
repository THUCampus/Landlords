; #########################################################################
; 文件：
;	server.asm
;
; 功能：
;	完成服务器的各种信息处理操作
;
; #########################################################################
TITLE LandLordServer (server.asm)

include server.inc

.code

;-----------------------------------------------------
initServer PROC USES eax ebx
; 函数功能 : 初始化socket,绑定到TCP端口并开始监听。等到玩家连入socket,当所有玩家连入后，发送消息至客户端。
; 返回值 : null
;-----------------------------------------------------
	invoke WSAStartup, wsaVersion, addr wsaData
	.if eax   ;the call is unsuccessful
		invoke ExitProcess, 0
	.endif

	;create socket
	invoke socket, AF_INET, SOCK_STREAM, 0
	.if eax != INVALID_SOCKET 
		mov hListenSock, eax 
	.else 
		invoke WSAGetLastError 
    .endif

	;fulfill sockInfo
	invoke RtlZeroMemory, addr hListenSockAddr, SIZEOF  hListenSockAddr    ;use zero to fill the block
	invoke htons, TCP_PORT    ;convert the ip value to network byte order(big endiant)
	mov hListenSockAddr.sin_port, ax
	mov hListenSockAddr.sin_family, AF_INET
	mov hListenSockAddr.sin_addr, INADDR_ANY    ;set host

	;bind sock to listen ip:host, port:TCP_PORT
	invoke bind, hListenSock, addr hListenSockAddr, SIZEOF hListenSockAddr
    .if eax  ;bind error
		invoke crt_printf, addr szErrBindStr
        invoke ExitProcess, 0
    .endif
    invoke listen, hListenSock, 5 ;max connected num

    ;wait player to connect
	mov ebx, 0
    .while bl < gameSock
        invoke accept, hListenSock, NULL, NULL ; sockaddr, socklen not needed
        .continue .if eax == INVALID_SOCKET
        mov connectedSockList[ebx * 4], eax
        invoke crt_printf, addr szConnectStr, bl, eax
        inc bl
	.endw

    ret
initServer ENDP


;-----------------------------------------------------
listenSocket PROC
; 函数功能 : 监听客户端事件，传输发送至所有客户端
; 返回值 : null
;-----------------------------------------------------
	pushad

	;给每个client编号
	mov ebx, 0
	lea esi,my_game
	.while bl < gameSock
		mov (GamePack PTR [esi]).now_player,bl
		invoke sendPack, connectedSockList[ebx * 4],  addr my_game
		inc bl
	.endw

	;开始游戏并发牌
	invoke GameStart,addr my_game
	invoke SendCard,addr my_game
    mov ebx, 0
	mov (GamePack PTR [esi]).now_player,0
    .while bl < gameSock
		invoke sendPack, connectedSockList[ebx * 4],  addr my_game	
		inc bl
	.endw
	
    ;叫地主
    mov ebx, 0
	mov (GamePack PTR [esi]).status,game_GetLandlord
	mov (GamePack PTR [esi]).now_player,0
    .while bl < gameSock
		invoke sendPack, connectedSockList[ebx * 4],  addr my_game	
		invoke recvPack, connectedSockList[ebx * 4], addr my_game
		
		inc bl
		mov (GamePack PTR [esi]).now_player,bl
	.endw

	;设置地主并发地主牌
	invoke SetLandlord,addr my_game
	invoke SendLandlordCard,addr my_game

	mov ebx, 0
	mov (GamePack PTR [esi]).now_player,0
	.while bl < gameSock
		invoke sendPack, connectedSockList[ebx * 4], addr my_game
		inc bl
		mov (GamePack PTR [esi]).now_player,bl
	.endw


	;游戏进行中：不断循环
	mov (GamePack PTR [esi]).now_player,0
	.while TRUE
		;安排游戏状态
		invoke GamePlaying,addr my_game
		
		mov al,(GamePack PTR [esi]).status
		
		;若游戏已经结束
		.if al == game_GameOver
			;通知所有玩家
			mov ebx, 0
			.while bl < gameSock
				invoke sendPack, connectedSockList[ebx * 4],  addr my_game
				inc bl
			.endw
			.break
		.endif
		
		;若游戏仍在继续
		mov ebx, 0
		lea esi,my_game
		mov bl,(GamePack PTR [esi]).now_player
		invoke sendPack, connectedSockList[ebx * 4],  addr my_game
		invoke recvPack, connectedSockList[ebx * 4],  addr my_game
		
		mov ebx, 0
		.while bl < gameSock
			mov al,(GamePack PTR [esi]).now_player
			.if bl!=al
				invoke sendPack, connectedSockList[ebx * 4],  addr my_game
			.endif
			inc bl
		.endw
	
	.endw

	;游戏结束
	invoke GameOver,addr my_game

	popad
    ret
listenSocket ENDP


;-----------------------------------------------------
recvPack PROC USES ecx ebx,
    _hSock:DWORD,   ;socket to recv
	_pack: PTR GamePack
; 函数功能 : 接收数据包
; 返回值 : null
;-----------------------------------------------------
	mov eax, SOCKET_ERROR
    .repeat
		invoke recv, _hSock, _pack, SIZEOF GamePack, 0
	.until eax != SOCKET_ERROR

	ret
recvPack ENDP
;-----------------------------------------------------


;-----------------------------------------------------
sendPack PROC USES ebx eax ecx,
    _hSock:DWORD,   ;socket to send
    _packAddr:PTR GamePack   ;packet address
; 函数功能 : 发送数据包
; 返回值 : null
;-----------------------------------------------------
	mov eax, SOCKET_ERROR
	.repeat 
		invoke send, _hSock, _packAddr, SIZEOF GamePack, 0
	.until eax != SOCKET_ERROR
    
	ret
sendPack ENDP
;-----------------------------------------------------

server_main PROC
    invoke crt_printf, addr szInitSockNumStr

    invoke initServer

	.while 1
		invoke listenSocket
		;收到准备信号
		pushad
		mov ebx, 0
		.while bl < gameSock
			invoke recvPack, connectedSockList[ebx * 4],  addr my_game
			inc bl
		.endw
		lea esi,my_game
		mov al,game_NoStart
		mov (GamePack PTR [esi]).status,al
		popad
	.endw

    invoke closesocket, hListenSock
	invoke WSACleanup 

    invoke ExitProcess, NULL
server_main ENDP

END ;server_main