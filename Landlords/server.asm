; #########################################################################
;
; 文件功能介绍      
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

	;invoke crt_printf, addr _msg, hListenSockAddr.sin_addr
	;invoke crt_printf, addr _msg, hListenSockAddr.sin_port

	;bind sock to listen ip:host, port:TCP_PORT
	invoke bind, hListenSock, addr hListenSockAddr, SIZEOF hListenSockAddr
    .if eax  ;bind error
		invoke crt_printf, addr szErrBind
        invoke ExitProcess, 0
    .endif
    invoke listen, hListenSock, 5 ;max connected num

    ;wait player to connect
	mov ebx, 0
    .while bl < gameSock
        invoke accept, hListenSock, NULL, NULL ; sockaddr, socklen not needed
        .continue .if eax == INVALID_SOCKET
        mov connectedSockList[ebx * 4], eax
        invoke crt_printf, addr szConnect, bl, eax
        inc bl
	.endw

    ret
initServer ENDP



;-----------------------------------------------------
listenSocket PROC USES eax ebx
; 函数功能 : 监听客户端事件，传输发送至所有客户端
; 返回值 : null
;-----------------------------------------------------
	LOCAL @tempPack: GAME_PACKAGE
	;进行package的初始化，该package是传输包也是接收包
	mov	@tempPack.state, 0
	mov	@tempPack.player, 0
	mov @tempPack.ifSuccess, 0
	mov @tempPack.askLord, 0


	;send:all players are ready + serial number
	mov ebx, 0
	mov @tempPack.state, S2C_READY
	.while bl < gameSock
		mov @tempPack.player, bl
		invoke sendPack, connectedSockList[ebx * 4],  addr @tempPack
		inc bl
	.endw

	
    ;send to player 0: allow to ask landlord, receive ask_landlord package and send to all players
    mov ebx, 0
    .while bl < gameSock
		mov @tempPack.player, bl
		mov @tempPack.state, S2C_LORDTURN
		;.repeat 
		invoke sendPack, connectedSockList[ebx * 4],  addr @tempPack
		;.until eax != SOCKET_ERROR
		
		invoke recvPack, bl, connectedSockList[ebx * 4], C2S_ASKLORD, addr @tempPack
		
		XOR @tempPack.state, 80h ; from recv pack to send pack
        mov ecx, 0
        .while cl < gameSock
            invoke sendPack, connectedSockList[ecx * 4], addr @tempPack
            inc cl
        .endw
		inc bl
	.endw

    ;receive: who_is_landload pack
    ;mov ebx, 0
    ;.while bl < gameSock
	;	invoke recvPack, bl, connectedSockList[ebx * 4], C2S_askLord, addr @tempPack
	;	inc bl
	;.endw

	;send : who is landlord
	mov @tempPack.state, S2C_ISLORD
	mov bl, landLord
	mov @tempPack.player, bl
	mov ebx, 0
	.while bl < gameSock
		invoke sendPack, connectedSockList[ebx * 4], addr @tempPack
		inc bl
	.endw


	;listen loop : deal with cards play
	mov @tempPack.state, S2C_PLAYTURN
	.while TRUE
		.if bl >= gameSock
			mov ebx, 0
		.endif
		.while bl < gameSock
			mov @tempPack.player, bl
			mov @tempPack.state, S2C_PLAYTURN
			;allow to play card
			invoke sendPack, connectedSockList[ebx * 4],  addr @tempPack
			invoke recvPack, bl, connectedSockList[ebx * 4], C2S_PLAYCARD, addr @tempPack
			
			;.if al >= 80h ; one player success
			;		mov winner, bl
			;		;invoke crt_printf, addr szSuccess, bl
			;.endif

			XOR @tempPack.state, 80h
			;send processed package to players
			push ebx
			mov ebx, 0
			.while bl < gameSock
				invoke sendPack, connectedSockList[ebx * 4], addr @tempPack
				inc bl
			.endw
			pop ebx

			.if @tempPack.ifSuccess == 1
				invoke crt_printf, addr szSuccess, @tempPack.player
				;成功之后的断开连接？？？？？？？？？
			.endif

			inc bl
		.endw
	.endw

    ret
listenSocket ENDP



;-----------------------------------------------------
recvPack PROC USES ecx ebx,
    _player:BYTE,
    _hSock:DWORD,   ;socket to recv
    _cmd:BYTE,      ;cmd type
	_pack: PTR GAME_PACKAGE
; 函数功能 : 接收数据包
; 返回值 : ESI, 如需要发送的数据包; al, 如果数据包是地主信息，返回地主编号；如果结束游戏，返回8xh x为玩家编号
;-----------------------------------------------------
	;LOCAL @recvPack : GAME_PACKAGE
	mov eax, SOCKET_ERROR
    .repeat
		invoke recv, _hSock, _pack, SIZEOF GAME_PACKAGE, 0
	.until eax != SOCKET_ERROR

	mov edi, _pack
	mov cl, (GAME_PACKAGE PTR [edi]).state
    .if cl == _cmd        ;valid cmd
		pushad
		invoke crt_printf, addr szRecvPack, (GAME_PACKAGE PTR [edi]).state, bl
		popad

		;check if is lord
		.if cl == C2S_ASKLORD
			mov cl, (GAME_PACKAGE PTR [edi]).askLord
			.if cl == 1           ;this player is landlod
				mov al, (GAME_PACKAGE PTR [edi]).player
				mov landLord, al
			.endif
		.endif

		;check if game over
		;.if cl == C2S_PLAYCARD
		;	mov cl, (GAME_PACKAGE PTR [edi]).ifSuccess
		;	.if cl                ;this player wins
		;		mov al, _player
		;		mov winner, al
		;	.endif
		;.endif

		;XOR  (GAME_PACKAGE PTR [edi]).state, 80h    ;change cmd, from recv cmd to send cmd

     .else                     ;invalid cmd
        invoke crt_printf, addr szErrRequest, _player
    .endif

	ret

recvPack ENDP
;-----------------------------------------------------


;-----------------------------------------------------
sendPack PROC USES ebx eax ecx,
    _hSock:DWORD,   ;socket to send
    _packAddr:PTR GAME_PACKAGE   ;packet address
; 函数功能 : 发送数据包
; 返回值 : esi : 需要发送的包的地址
;-----------------------------------------------------
	;mov edi, _packAddr
	;mov cl, (GAME_PACKAGE PTR [edi]).state
	
		.repeat 
			invoke send, _hSock, _packAddr, SIZEOF GAME_PACKAGE, 0
		.until eax != SOCKET_ERROR
    
	ret

sendPack ENDP
;-----------------------------------------------------


 

main PROC
    invoke crt_printf, addr szInitSockNum, minSock, maxSock

    .while TRUE
        invoke crt_scanf, addr _sockNum, addr gameSock
		;invoke crt_printf, addr _sockNum, gameSock
		sub gameSock, 48
		mov bl, gameSock
		.break .if bl >= minSock && bl <= maxSock
	.endw

    invoke initServer

    invoke listenSocket

    invoke closesocket, hListenSock
	invoke WSACleanup 

    invoke ExitProcess, NULL
main ENDP
END main