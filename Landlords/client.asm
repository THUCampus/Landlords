; #########################################################################
;
; 文件功能介绍      
;
; #########################################################################

TITLE LandLordClient (client.asm)

include client.inc

.code

;-----------------------------------------------------
initClient PROC USES eax
; 函数功能 : 初始化socket,连接到服务器的TCP端口。
; 返回值 : null
;-----------------------------------------------------
	invoke WSAStartup, wsaVersion, addr wsaData
	.if eax   ;the call is unsuccessful
		invoke ExitProcess, 0
	.endif

	;create socket
	invoke socket, AF_INET, SOCK_STREAM, 0
	.if eax != INVALID_SOCKET 
		mov _sock, eax 
	.else 
		invoke WSAGetLastError 
    .endif

	;fulfill sockInfo
	invoke RtlZeroMemory, addr _sockAddr, SIZEOF _sockAddr    ;use zero to fill the block

	mov _sockAddr.sin_family, AF_INET
	invoke crt_scanf, addr ipBuf, addr ipString
	;invoke crt_printf, addr ipString
    ;invoke wsprintf, addr ipBuf, OFFSET ipInputFormt, OFFSET ipAddr    ;input ipAddr to connect
    invoke inet_addr, addr ipString    ;convert the ip address into network byte order
	.if eax != INADDR_NONE
		mov _sockAddr.sin_addr, eax
	.else
		invoke crt_printf, _msg, szErrIP
	.endif
    invoke htons, TCP_PORT   ;convert the port value to network byte order 
	mov _sockAddr.sin_port, ax

    ;add to message loop
    ;invoke WSAAsyncSelect, _sock, hwnd, WM_SOCKET, FD_CONNECT+FD_READ+FD_CLOSE
    ;.if eax == SOCKET_ERROR
	;	invoke WSAGetLastError
	;	.if eax != WSAEWOULDBLOCK
	;	invoke closesocket, _sock 
    ;    invoke ExitProcess, NULL
    ;.endif

	;connect server
    invoke connect, _sock, addr _sockAddr, SIZEOF _sockAddr
    .if eax == SOCKET_ERROR
        invoke WSAGetLastError
        invoke ExitProcess, NULL
    .endif
	
    ret
initClient ENDP



;-----------------------------------------------------
handleMessage PROC USES eax
; 函数功能 : 进行信息交互
; 返回值 : null
;-----------------------------------------------------
	LOCAL @recvPack:GAME_PACKAGE 
	.while TRUE
		invoke recv, _sock, addr @recvPack, SIZEOF @recvPack, 0
		.if eax != SOCKET_ERROR ;timeOut 
			invoke parsePack, addr @recvPack.state
		.endif
	.endw
	ret
handleMessage ENDP



;-----------------------------------------------------
parsePack PROC USES ebx ecx eax edi,
	_pack: PTR GAME_PACKAGE
; 函数功能 : 解析数据包
; 返回值 : null
;-----------------------------------------------------
	LOCAL @tempPack: GAME_PACKAGE
	mov @tempPack.player, 0
	mov @tempPack.askLord, 0
	mov @tempPack.ifSuccess, 0
	mov edi, _pack
	invoke crt_printf, addr szRecvPack, (GAME_PACKAGE PTR [edi]).state, (GAME_PACKAGE PTR [edi]).player
	mov cl, (GAME_PACKAGE PTR [edi]).state
	
	;receive message : all ready
	.if cl == S2C_READY
		mov al, (GAME_PACKAGE PTR [edi]).player
		mov player, al

	;turn to ask landlord
	.elseif cl == S2C_LORDTURN
		mov al, (GAME_PACKAGE PTR [edi]).player
		.if al == player
			mov @tempPack.state, C2S_ASKLORD
			mov @tempPack.player, al
			mov @tempPack.askLord, 1 ;选择是否叫地主
			.repeat 
				;发送数据包
				invoke send, _sock,  addr @tempPack, SIZEOF GAME_PACKAGE, 0
			.until eax != SOCKET_ERROR
		.else
			pushad
			invoke crt_printf, addr szErrPlayer
			popad
		.endif

	;show landlord info from other players
	.elseif cl == S2C_REPLYLORD
		;player x 是否叫了地主，并显示
		;.if  (GAME_PACKAGE PTR [edi]).askLord == 1
		;mov al, (GAME_PACKAGE PTR [edi]).player


	;receive: who is landlord
	.elseif cl == S2C_ISLORD
		mov al, (GAME_PACKAGE PTR [edi]).player
		.if al == player
			;我是地主
		.else
			;我不是地主
		.endif

	;turn to play card
	.elseif cl == S2C_PLAYTURN
		mov al, (GAME_PACKAGE PTR [edi]).player
		.if al == player
			;选择出牌并发送数据包
			mov @tempPack.player, al
			mov @tempPack.state, C2S_PLAYCARD
			mov @tempPack.ifSuccess, 1
			.repeat 
				invoke send, _sock,  addr @tempPack, SIZEOF GAME_PACKAGE, 0
			.until eax != SOCKET_ERROR
		.else
			pushad
			invoke crt_printf, addr szErrPlayer
			popad
		.endif

	.elseif cl == S2C_PLAYCARD
		;其他玩家的出牌信息
		;如果有玩家胜利，显示胜利界面

	.endif

	ret

parsePack ENDP



main PROC

    invoke initClient

	invoke handleMessage

	;invoke 
	invoke closesocket, _sock 
	invoke WSACleanup 
    invoke ExitProcess, NULL
main ENDP

END main