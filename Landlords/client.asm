; #########################################################################
;
; 文件功能介绍      
;
; #########################################################################

TITLE LandLordClient (client.asm)

include client.inc

.code

;-----------------------------------------------------
initClient PROC USES eax esi,_sock_addr:PTR DWORD,ip_addr:PTR BYTE
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

    invoke inet_addr, ip_addr   ;convert the ip address into network byte order
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

END