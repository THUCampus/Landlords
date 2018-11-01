; #########################################################################
;
; 文件功能介绍      
;
; #########################################################################

TITLE LandLordClient (client.asm)

include client.inc

.code

;-----------------------------------------------------
initClient PROC USES eax esi,_sock_addr:PTR DWORD
; 函数功能 : 初始化socket,连接到服务器的TCP端口。
; 返回值 : null
;-----------------------------------------------------

	mov esi,_sock_addr
	invoke WSAStartup, wsaVersion, addr wsaData
	.if eax   ;the call is unsuccessful
		invoke ExitProcess, 0
	.endif

	;create socket
	invoke socket, AF_INET, SOCK_STREAM, 0
	.if eax != INVALID_SOCKET 
		mov DWORD PTR [esi], eax 
	.else 
		invoke WSAGetLastError 
    .endif

	;fulfill sockInfo
	invoke RtlZeroMemory, addr _sockAddr, SIZEOF _sockAddr    ;use zero to fill the block

	mov _sockAddr.sin_family, AF_INET

	;invoke crt_printf, addr ipInputStr
	;invoke crt_scanf, addr _printS, addr ipString

    invoke inet_addr, addr ipString    ;convert the ip address into network byte order
	.if eax != INADDR_NONE
		mov _sockAddr.sin_addr, eax
	.else
		invoke crt_printf, _printS2, szErrIPStr
	.endif
    invoke htons, TCP_PORT   ;convert the port value to network byte order 
	mov _sockAddr.sin_port, ax

	;connect server
    invoke connect, DWORD PTR [esi], addr _sockAddr, SIZEOF _sockAddr
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
	.while TRUE
		invoke recv, _sock, addr my_game, SIZEOF GamePack, 0
		.if eax != SOCKET_ERROR ;timeOut 
			invoke parsePack, addr my_game
		.endif
	.endw
	ret
handleMessage ENDP


;-----------------------------------------------------
parsePack PROC,
	_pack: PTR GamePack
; 函数功能 : 解析数据包
; 返回值 : null
;-----------------------------------------------------

	pushad
	mov edi, _pack
	mov cl, (GamePack PTR [edi]).status
	
	;第一次接受数据：已就绪，分配玩家编号
	.if cl == game_NoStart
		mov al, (GamePack PTR [edi]).now_player
		mov playerNo, al

	;叫地主阶段
	.elseif cl == game_GetLandlord
		mov ebx,0
		mov bl, (GamePack PTR [edi]).now_player
		.if bl == playerNo
			;先用数字输入代表是否愿意叫地主，1为愿意，0为不愿意
			invoke crt_printf, addr landlordChooseStr
			lea esi,(GamePack PTR [edi]).all_players
			mov eax,SIZEOF Player
			mul ebx
			add esi,eax

			invoke crt_scanf, addr _printC, addr chooseLandlord
			invoke crt_scanf, addr _printC, addr chooseLandlord
			sub chooseLandlord, 48
			mov al, chooseLandlord
			.if al == 1
				get_landlord (Player PTR [esi])				
			.endif
			 
			 mov eax,SOCKET_ERROR
			.repeat 
				;发送数据包
				invoke send, _sock,  _pack, SIZEOF GamePack, 0
			.until eax != SOCKET_ERROR
		.else
			pushad
			invoke crt_printf, addr notYourTurnStr
			popad
		.endif

	;出牌阶段
	.elseif cl == game_Discard
		mov ebx,0
		mov bl, (GamePack PTR [edi]).now_player
		.if bl == playerNo
			;选择出牌并发送数据包
			lea esi,(GamePack PTR [edi]).all_players
			mov eax,SIZEOF Player
			mul ebx
			add esi,eax

			;显示已有的牌的数字
			invoke crt_printf, addr cardsHaveStr
			pushad
			mov ebx,0
			lea edi,(Player PTR [esi]).cards
			.while ebx<54
				mov al,BYTE PTR [edi]
				.if al == 1
					invoke crt_printf, addr _printD, ebx
				.endif		
				inc ebx
				inc edi
			.endw
			popad

			;选牌出牌
			invoke crt_printf, addr cardsChooseStr
			invoke DisCard,esi

			mov eax,SOCKET_ERROR
			.repeat 
				invoke send, _sock, _pack, SIZEOF GamePack, 0
			.until eax != SOCKET_ERROR
		.else
			pushad
			invoke crt_printf, addr notYourTurnStr
			popad
		.endif

	.elseif cl == game_GameOver
		;结束
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
					invoke crt_printf, addr peasantWinStr
				.elseif cl==1
					invoke crt_printf, addr landLordWinStr
				.endif
			.else
				.continue
			.endif
			add esi,SIZEOF Player
		.endw
		
	.endif

	popad
	ret

parsePack ENDP


client_main PROC

    ;invoke initClient

	invoke handleMessage

	invoke closesocket, _sock 
	invoke WSACleanup 
    invoke ExitProcess, NULL
client_main ENDP

END ;client_main