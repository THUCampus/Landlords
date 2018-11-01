; #########################################################################
; 文件：
;	cardgroup.asm
;
; 功能：
;	存储符合基本牌的一组牌，包含这组牌的类型、牌面、数量等。
;
; 作者：
;	程嘉梁
;
; 修改历史：
;	修改人	修改时间	修改内容
;	-------	-----------	-------------------------------
;	程嘉梁	2018/10/09	创建
;
; #########################################################################

TITLE Cardgroup (cardgroup.asm)

include cardgroup.inc

.code

;-----------------------------------------------------
AddNumber PROC,
	_group:PTR CardGroup, ;参数作用:添加牌的牌组结构
	num:BYTE	 ;参数作用:添加的牌数字
; 函数功能:添加0-53表示的牌元素
; 返回值:无
;-----------------------------------------------------
	;函数实现
	LOCAL num_translate:BYTE
	pushad
	mov edi,_group
	inc (CardGroup PTR [edi]).count

	lea esi,(CardGroup PTR [edi]).cards
	movzx eax,num
	add esi,eax
	mov al,[esi]
	inc al
	mov [esi],al

	invoke Translate,num,addr num_translate
	lea esi,(CardGroup PTR [edi]).card_group
	movzx eax,num_translate
	add esi,eax
	mov al,[esi]
	inc al
	mov [esi],al

	popad
	ret
AddNumber ENDP

;-----------------------------------------------------
DeleteNumber PROC,
	_group:PTR CardGroup, ;参数作用:删除牌的牌组结构
	num:BYTE	 ;参数作用:删除的牌数字
; 函数功能:删除0-53表示的牌元素
; 返回值:无
;-----------------------------------------------------
	;函数实现
	LOCAL num_translate:BYTE
	pushad
	mov edi,_group

	lea esi,(CardGroup PTR [edi]).cards
	movzx eax,num
	add esi,eax
	mov al,[esi]
	.if al == 0
		ret
	.else
		mov al,[esi]
		dec al
		mov [esi],al
	.endif

	dec (CardGroup PTR [edi]).count

	invoke Translate,num,addr num_translate
	lea esi,(CardGroup PTR [edi]).card_group
	movzx eax,num_translate
	add esi,eax
	mov al,[esi]
	dec al
	mov [esi],al

	popad
	ret
DeleteNumber ENDP

;-----------------------------------------------------
Clear PROC,
	_group:PTR CardGroup ;参数作用:清空的牌组结构
; 函数功能:重置此结构
; 返回值:无
;-----------------------------------------------------
	;函数实现
	pushad

	mov edi,_group
	bequal (CardGroup PTR [edi]).group_type,cardgroup_Unkown
	bequal (CardGroup PTR [edi]).value,0
	bequal (CardGroup PTR [edi]).count,0

	mov esi,0
	.while esi<54
		bequal (CardGroup PTR [edi]).cards[esi],0
		inc esi
	.endw

	mov esi,0
	.while esi<15
		bequal (CardGroup PTR [edi]).card_group[esi],0
		inc esi
	.endw
	popad
	ret
Clear ENDP

;-----------------------------------------------------
Translate PROC,
	num:BYTE, ;参数作用:牌数字
	result:PTR BYTE	 ;参数作用:转换结果
; 函数功能:把0-53转换成0-14权值，其中A（11）、2（12）、小王（13）、大王（14）
; 返回值:无
;-----------------------------------------------------
	;函数实现
	pushad
	
	mov esi,result
	mov eax,0
	mov bl,4
	.if num<52
		mov al,num
		div bl
		mov [esi],al
	.else
		mov al,num
		sub al,39
		mov [esi],al
	.endif

	popad
	ret
Translate ENDP

END