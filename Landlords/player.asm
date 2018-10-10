; #########################################################################
; 文件：
;	player.asm
;
; 功能：
;	模拟玩家操作过程
;
; 作者：
;	程嘉梁
;
; 修改历史：
;	修改人	修改时间	修改内容
;	-------	-----------	-------------------------------
;	程嘉梁	2018/10/10	创建
;
; #########################################################################

TITLE Player (player.asm)

include player.inc

.code

;-----------------------------------------------------
AddCard PROC,
	my_player:PTR Player,	;参数作用：玩家地址
	num:BYTE	;参数作用：插入的牌
; 函数功能:加牌
; 返回值:无
;-----------------------------------------------------
	;函数实现
	LOCAL result:BYTE
	pushad
	
	mov edi,my_player
	mov esi,0
	movzx eax,num
	add esi,eax
	mov (Player PTR [edi]).cards[esi],1

	invoke Translate,num,ADDR result
	mov esi,0
	movzx eax,result
	add esi,eax
	inc (Player PTR [edi]).card_group[esi]

	inc (Player PTR [edi]).cards_num

	popad
	ret
AddCard ENDP

;-----------------------------------------------------
DelCard PROC,
	my_player:PTR Player,	;参数作用：玩家地址
	num:BYTE	;参数作用：去除的牌
; 函数功能:减牌
; 返回值:无
;-----------------------------------------------------
	;函数实现
	LOCAL result:BYTE
	pushad
	
	mov edi,my_player
	mov esi,0
	movzx eax,num
	add esi,eax

	mov bl,(Player PTR [edi]).cards[esi]
	.if bl==0
		ret
	.endif

	mov (Player PTR [edi]).cards[esi],0

	invoke Translate,num,ADDR result
	mov esi,0
	movzx eax,result
	add esi,eax
	dec (Player PTR [edi]).card_group[esi]

	dec (Player PTR [edi]).cards_num

	popad
	ret
DelCard ENDP

END