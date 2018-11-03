TITLE SCENE (scene.asm)

.386
.model flat, stdcall
option casemap:none


INCLUDE winMain.inc

.code 

;=======================================================================
initScene proc uses eax ebx ecx esi edi, hWnd
  LOCAL @hDc:HDC ;窗口对应的DC
  LOCAL @hInstance:HINSTANCE
  LOCAL @oldPen:HPEN
;---------------------------------------
	invoke GetModuleHandle, 0
	mov @hInstance, eax

	;初始化各种DC
	invoke GetDC, hWnd
	mov @hDc,eax
	;load 内存DC
	invoke CreateCompatibleDC, @hDc
	mov hdcScene, eax
	invoke CreateCompatibleDC, @hDc
	mov hdcBkg, eax
	invoke CreateCompatibleDC, @hDc
	mov hdcMyCards, eax
	invoke CreateCompatibleDC, @hDc
	mov hdcCards, eax
	invoke CreateCompatibleDC, @hDc
	mov hdcNoDiscard, eax
	invoke CreateCompatibleDC, @hDc
	mov hdcCardBack, eax
	invoke CreateCompatibleDC, @hDc
	mov hdcBtn, eax
	invoke CreateCompatibleDC, @hDc
	mov hdcPassBtn, eax
	invoke CreateCompatibleDC, @hDc
	mov hdcDiscardBtn, eax
	invoke CreateCompatibleDC, @hDc
	mov hdcNoCallBtn, eax
	invoke CreateCompatibleDC, @hDc
	mov hdcCallBtn, eax
	invoke CreateCompatibleDC, @hDc
	mov hdcLDCard, eax

	;load 位图DC或位图
	invoke LoadBitmap, @hInstance, addr background
	mov hbmBkg, eax
	invoke CreatePatternBrush,hbmBkg
	mov hbrush, eax ;背景画刷，填充空白？？？？
	invoke DeleteObject, hbmBkg

	invoke CreateCompatibleBitmap, @hDc,860,540
	mov hbmScene,eax
	invoke CreateCompatibleBitmap, @hDc,860,540
	mov hbmBkg,eax
	invoke CreateCompatibleBitmap, @hDc,650,128
	mov hbmMyCards,eax
	invoke LoadBitmap, @hInstance, addr cards
	mov hbmCards, eax
	invoke LoadBitmap, @hInstance, addr nodiscard
	mov hbmNoDiscard, eax
	invoke LoadBitmap, @hInstance, addr cardback
	mov hbmCardBack, eax
	invoke CreateCompatibleBitmap, @hDc,200,50
	mov hbmBtn,eax
	invoke LoadBitmap, @hInstance, addr pass
	mov hbmPassBtn, eax
	invoke LoadBitmap, @hInstance, addr discard
	mov hbmDiscardBtn, eax
	invoke LoadBitmap, @hInstance, addr no
	mov hbmNoCallBtn, eax
	invoke LoadBitmap, @hInstance, addr score1
	mov hbmCallBtn, eax
	invoke CreateCompatibleBitmap, @hDc,249,96
	mov hbmLDCard,eax

	;选择位图DC到内存DC中
	invoke SelectObject,hdcScene,hbmScene
	invoke SelectObject,hdcBkg,hbmBkg
	invoke SelectObject,hdcBkg,hbrush
	invoke SelectObject,hdcMyCards,hbmMyCards
	invoke SelectObject,hdcMyCards,hbrush
	invoke SelectObject,hdcCards,hbmCards
	invoke SelectObject,hdcNoDiscard,hbmNoDiscard
	invoke SelectObject,hdcCardBack,hbmCardBack
	invoke SelectObject,hdcBtn,hbmBtn
	invoke SelectObject,hdcBtn,hbrush
	invoke SelectObject,hdcPassBtn,hbmPassBtn
	invoke SelectObject,hdcDiscardBtn,hbmDiscardBtn
	invoke SelectObject,hdcCallBtn,hbmCallBtn
	invoke SelectObject,hdcNoCallBtn,hbmNoCallBtn
	invoke SelectObject,hdcLDCard,hbmLDCard
	invoke SelectObject,hdcLDCard,hbrush

  ;绘制背景到内存DC
	invoke PatBlt,hdcBkg,0,0,860,540,PATCOPY
	invoke CreatePen,PS_SOLID,3,00C0C0C0h
	invoke SelectObject,hdcBkg,eax
	mov @oldPen,eax
	invoke Rectangle,hdcBkg,100,-5,750,380
	invoke SelectObject,hdcBkg,@oldPen

	invoke ReleaseDC,hWnd,@hDc
	ret
initScene endp
;=======================================================================

;=======================================================================
ShowBtn proc uses eax ebx ecx edx esi edi,number,_pack: PTR GamePack,operate_addr:PTR BYTE
;显示出牌按钮
;---------------------------------

	invoke PatBlt,hdcBtn,0,0,200,50,PATCOPY
	mov edi,operate_addr
	mov al,BYTE PTR [edi]
	.if al != 1;隐藏按钮
		ret
	.endif

	mov eax,82
	mul number

	mov edi, _pack
	mov cl, (GamePack PTR [edi]).status

	.if cl == game_Discard
		invoke TransparentBlt,hdcBtn,10,5,82,40,hdcPassBtn,eax,0,82,40,00000000h
		invoke TransparentBlt,hdcBtn,100,5,82,40,hdcDiscardBtn,eax,0,82,40,00000000h
	.elseif cl == game_GetLandlord
		invoke TransparentBlt,hdcBtn,10,5,82,40,hdcNoCallBtn,eax,0,82,40,00000000h
		invoke TransparentBlt,hdcBtn,100,5,82,40,hdcCallBtn,eax,0,82,40,00000000h
	.endif
	ret
ShowBtn endp
;=======================================================================

;=======================================================================
updateScene proc uses eax ebx ecx esi edi, hWnd,_pack: PTR GamePack,operate_addr:PTR BYTE,playerNo_addr:PTR BYTE
;显示初始界面
  LOCAL @hDc:HDC ;窗口对应的DC
;---------------------------------
	invoke GetDC, hWnd
	mov @hDc,eax

	invoke BitBlt,hdcScene,0,0,860,540,hdcBkg,0,0,SRCCOPY;背景
	invoke ShowBtn,1,_pack,operate_addr;出牌按钮
	invoke drawMyCards,hdcScene,_pack,playerNo_addr;玩家的手牌
	invoke DisPlayer1Card,_pack,playerNo_addr;对手1打出的牌
	invoke DisPlayer2Card,_pack,playerNo_addr;对手2打出的牌
	invoke DrawPlayerCard,_pack,playerNo_addr;对手的手牌
	invoke drawLandLordCards,_pack;地主牌
	invoke drawRole,_pack,playerNo_addr;玩家身份
	invoke BitBlt,hdcScene,500,300,200,50,hdcBtn,0,0,SRCCOPY;
	invoke BitBlt,hdcScene,306,20,249,96,hdcLDCard,0,0,SRCCOPY;
	invoke disMyCard,_pack,playerNo_addr;玩家打出的牌
	invoke BitBlt,@hDc, 0, 0, 860, 540, hdcScene, 0, 0, SRCCOPY

	invoke ReleaseDC,hWnd,@hDc
	ret
updateScene endp
;=======================================================================

;=======================================================================
drawLandLordCards proc uses ecx ebx eax edx esi edi,_pack: PTR GamePack
LOCAL x:DWORD
;---------------------------------
	invoke PatBlt,hdcLDCard,0,0,249,96,PATCOPY
	mov edi, _pack
	mov cl, (GamePack PTR [edi]).status

	.if cl < game_GetLandlord
		ret
	.elseif cl ==game_GetLandlord;叫地主阶段
		mov ecx,0
		mov x,9
		.while ecx<3
			push ecx
			invoke TransparentBlt, hdcLDCard, x, 0, 71, 96, hdcCardBack,\
				0, 0, 71, 96, 00ff0000h
			add x,80
			pop ecx
			inc ecx
		.endw
		ret
	.else
		mov x,9
		mov ecx,0
		mov edi, _pack
		lea esi, (GamePack PTR [edi]).landlord_cards
		.while ecx<3
			mov eax,71
			movzx ebx,BYTE PTR [esi]
			mul ebx
			push ecx
			invoke TransparentBlt, hdcLDCard, x, 0, 71, 96, hdcCards,\
				eax, 0, 71, 96, 00ff0000h
			add x,80
			pop ecx
			inc ecx
			inc esi
		.endw
		ret
	.endif
drawLandLordCards endp
;=======================================================================

;=======================================================================
drawRole proc uses eax ebx ecx edx esi edi,_pack: PTR GamePack,playerNo_addr:PTR BYTE
;roles三人角色：0为地主，1为农民
;isShow:是否显示文字
LOCAL @oldFont:HFONT
LOCAL @oldColor:COLORREF
;---------------------------------

	mov edi, _pack
	mov cl, (GamePack PTR [edi]).status

	.if cl < game_SendLandlordCard
		ret
	.endif

	invoke CreateFont, 20, 0, 0, 0, 0, 0, 0, 0, DEFAULT_CHARSET, 0, 0, 0, 0, addr fontStyle
	invoke SelectObject, hdcScene,eax
	mov @oldFont,eax
	invoke SetTextColor, hdcScene,00000000h
	mov @oldColor,eax
	invoke SetBkMode,hdcScene,TRANSPARENT

	;player1
	mov edi,_pack
	lea esi,(GamePack PTR [edi]).all_players
	mov eax,SIZEOF Player
	mov ebx,0
	push esi
	mov esi,playerNo_addr
	mov bl,BYTE PTR [esi]
	pop esi
	.if bl == 2
		mov bl,0
	.else
		inc bl
	.endif
	mul ebx
	add esi,eax
	movzx eax,(Player PTR [esi]).player_position

	.if eax==0
		invoke TextOut,hdcScene,688,70,addr peasantChar,7
	.else
		invoke TextOut,hdcScene,688,70,addr landlordChar,8		
	.endif	

	;player2
	mov edi,_pack
	lea esi,(GamePack PTR [edi]).all_players
	mov eax,SIZEOF Player
	mov ebx,0
	push esi
	mov esi,playerNo_addr
	mov bl,BYTE PTR [esi]
	pop esi
	.if bl == 0
		mov bl,2
	.else
		dec bl
	.endif
	mul ebx
	add esi,eax
	movzx eax,(Player PTR [esi]).player_position

	.if eax==0
		invoke TextOut,hdcScene,105,70,addr peasantChar,7
	.else
		invoke TextOut,hdcScene,105,70,addr landlordChar,8
	.endif

	;player3
	mov edi,_pack
	lea esi,(GamePack PTR [edi]).all_players
	mov eax,SIZEOF Player
	mov ebx,0
	push esi
	mov esi,playerNo_addr
	mov bl,BYTE PTR [esi]
	pop esi
	mul ebx
	add esi,eax
	movzx eax,(Player PTR [esi]).player_position

	.if eax ==0
		invoke TextOut,hdcScene,415,360,addr peasantChar,7
	.else
		invoke TextOut,hdcScene,415,360,addr landlordChar,8
	.endif

	invoke SetTextColor,hdcScene,@oldColor
	invoke SelectObject,hdcScene,@oldFont
	ret
drawRole endp
;=======================================================================

;=======================================================================
drawMyCards proc uses eax ebx ecx esi edi,hDc,_pack: PTR GamePack,playerNo_addr:PTR BYTE
;绘制我的手牌
LOCAL x:DWORD
LOCAL y:DWORD
LOCAL base:DWORD
;---------------------------------
	invoke PatBlt,hdcMyCards, 0, 0, 650, 128, PATCOPY
	;计算牌堆的起始位置
	mov base,0
	mov x, 601

	mov edi,_pack
	lea esi,(GamePack PTR [edi]).all_players
	mov eax,SIZEOF Player
	mov ebx,0
	push esi
	mov esi,playerNo_addr
	mov bl,BYTE PTR [esi]
	pop esi
	mul ebx
	add esi,eax
	mov eax,0
	movzx eax, (Player PTR [esi]).cards_num
	.if cardNum < eax
		mov cardNum,eax
	.endif

	mov eax, cardNum
	mov ebx, 22
	mul ebx
	sub x,eax
	mov eax,x
	mov ebx,2
	div ebx
	mov x,eax
	mov startPos,eax

	pushad
	mov edi,_pack
	lea esi,(GamePack PTR [edi]).all_players
	mov eax,SIZEOF Player
	mov ebx,0
	push esi
	mov esi,playerNo_addr
	mov bl,BYTE PTR [esi]
	pop esi
	mul ebx
	add esi,eax
	
	lea edi,(Player PTR [esi]).cards
	lea eax,(Player PTR [esi]).cards_to_show
	lea esi,(CardGroup PTR [eax]).cards

	mov ecx,0
	mov ebx,0
	.while ecx<54
		mov al,BYTE PTR [edi]
		.if al == 1
			mov OrdOfMycards[ebx],ecx
			mov y,17
			pushad
				invoke TransparentBlt, hdcMyCards, x, y, 71, 96, hdcCards, base, 0, 71, 96, 00ff0000h
			popad
			add x,22
			add ebx,4 
		.endif	
		mov al,BYTE PTR [esi]
		.if al == 1
			mov OrdOfMycards[ebx],ecx
			mov y,2
			pushad
				invoke TransparentBlt, hdcMyCards, x, y, 71, 96, hdcCards, base, 0, 71, 96, 00ff0000h
			popad
			add x,22
			add ebx,4 
		.endif		
		inc ecx
		inc edi
		inc esi
		add base,71
	.endw
	popad

	add x,49
	mov eax,x
	mov endPos,eax

	invoke BitBlt,hDc, 100, 380, 650, 128, hdcMyCards, 0, 0, SRCCOPY
	ret
drawMyCards endp
;=======================================================================


;=======================================================================
click proc uses eax ebx ecx edx esi edi,hWnd, lParam,stage,_pack: PTR GamePack,operate_addr:PTR BYTE,playerNo_addr:PTR BYTE
;点击屏幕事件
LOCAL @ptMouse:POINT;鼠标位置
LOCAL @hDc:HDC
;选牌
;----------------------------------
	mov edi,operate_addr
	mov al,BYTE PTR [edi]
	.if al!=1
		ret
	.endif
	mov eax, 0
	mov ax, WORD ptr lParam
	mov @ptMouse.POINT.x, eax
	mov ax, WORD ptr lParam+2
	mov @ptMouse.POINT.y, eax

	mov edi, _pack
	mov cl, (GamePack PTR [edi]).status
	.if cl == game_Discard ;出牌阶段
		.if @ptMouse.POINT.y >=305 && @ptMouse.POINT.y <=345;点击按钮
			mov ebx,operate_addr
			mov BYTE PTR [ebx],2
			mov cardNum,0

			mov edi,_pack
			lea esi,(GamePack PTR [edi]).all_players
			mov eax,SIZEOF Player
			mov ebx,0
			push esi
			mov esi,playerNo_addr
			mov bl,BYTE PTR [esi]
			pop esi
			mul ebx
			add esi,eax

			.if @ptMouse.POINT.x >=510 && @ptMouse.POINT.x <=592;点击"不出"
				pushad
				lea eax,(Player PTR [esi]).cards_to_show
				lea edi,(CardGroup PTR [eax]).cards
				mov eax,0
				mov cl,0
				.while cl<54
					mov al,[edi]
					.if al==1
						invoke AddCard,esi,cl
						lea ebx,(Player PTR [esi]).cards_to_show
						invoke DeleteNumber,ebx,cl	
					.endif
					inc edi
					inc cl
				.endw

				mov (Player PTR [esi]).to_pass,1
				lea edi,(Player PTR [esi]).cards_to_show
				invoke Clear,edi
				lea edi,(Player PTR [esi]).cards_showed
				invoke Clear,edi

				popad
			
			.endif
			.if @ptMouse.POINT.x >=600 && @ptMouse.POINT.x <=682;点击"出牌"			
				lea eax,(Player PTR [esi]).cards_to_show
				mov edi,eax
				mov dl,(CardGroup PTR [edi]).count
				.if dl == 0
					mov (Player PTR [esi]).to_pass,1
				.else
					mov (Player PTR [esi]).to_pass,0
					lea ebx,(Player PTR [esi]).cards_showed
					cardgroup_equal (CardGroup PTR [ebx]),(CardGroup PTR [eax])
					invoke Clear,edi	
				.endif						;
			.endif
		.endif

		.if @ptMouse.POINT.y >=380 && @ptMouse.POINT.y <= 500;点击手牌
			mov ebx,startPos
			mov eax,@ptMouse.POINT.x
			sub eax,100
			.if eax > ebx && eax <= endPos
			;计算是选中的牌
				sub eax,ebx
				mov ebx,22
				div ebx;
				.if eax >= cardNum
					mov eax,cardNum
					dec eax
				.endif
				mov ebx,4
				mul ebx
				mov ecx,OrdOfMycards[eax];

				pushad
					mov edi,_pack
					lea esi,(GamePack PTR [edi]).all_players
					mov eax,SIZEOF Player
					mov ebx,0
					push esi
					mov esi,playerNo_addr
					mov bl,BYTE PTR [esi]
					pop esi
					mul ebx
					add esi,eax

					lea edi,(Player PTR [esi]).cards_to_show
					mov al,(CardGroup PTR [edi]).cards[ecx]
					.if al == 1
						invoke AddCard,esi,cl
						invoke DeleteNumber,edi,cl
					.else
						invoke DelCard,esi,cl
						invoke AddNumber,edi,cl							
					.endif
				popad

				invoke GetDC, hWnd
				mov @hDc,eax
				invoke drawMyCards,@hDc,_pack,playerNo_addr
				invoke ReleaseDC,hWnd,@hDc
			.endif
		.endif
	.elseif cl == game_GetLandlord ;叫地主阶段
		.if @ptMouse.POINT.y >=305 && @ptMouse.POINT.y <=345;点击按钮
			mov ebx,operate_addr
			mov BYTE PTR [ebx],2
			mov cardNum,0
			.if @ptMouse.POINT.x >=510 && @ptMouse.POINT.x <=592;点击"不叫"
				;
			.endif
			.if @ptMouse.POINT.x >=600 && @ptMouse.POINT.x <=682;点击"叫地主"
				mov ebx,0
				push esi
				mov esi,playerNo_addr
				mov bl,BYTE PTR [esi]
				pop esi
				lea esi,(GamePack PTR [edi]).all_players
				mov eax,SIZEOF Player
				mul ebx
				add esi,eax
				get_landlord (Player PTR [esi])
			.endif
		.endif
	.endif

	ret
click endp
;=======================================================================



;=======================================================================
disMyCard proc uses eax ebx ecx edx esi edi,_pack: PTR GamePack,playerNo_addr:PTR BYTE
LOCAL x:DWORD
LOCAL y:DWORD
LOCAL base:DWORD
LOCAL count:DWORD;出牌张数
;---------------------------------
	mov edi,_pack
	lea esi,(GamePack PTR [edi]).all_players
	mov eax,SIZEOF Player
	mov ebx,0
	push esi
	mov esi,playerNo_addr
	mov bl,BYTE PTR [esi]
	pop esi
	mul ebx
	add esi,eax

	mov eax,0
	mov al,(Player PTR [esi]).to_pass
	;如果不出牌
	.if al==1
		invoke TransparentBlt, hdcScene, 392, 320, 63, 27, hdcNoDiscard,\
			0, 0, 63, 27, 00ffffffh
		ret
	.endif

	;出牌
	lea eax,(Player PTR [esi]).cards_showed
	mov ebx,0
	mov bl,(CardGroup PTR [eax]).count
	mov count,ebx
	.if ebx == 0
		ret
	.endif

	;计算牌堆的起始位置
	mov base,0
	mov x, 799
	mov eax, 22
	mul count
	sub x,eax
	mov eax,x
	mov ebx,2
	div ebx
	mov x,eax
	mov y,250


	lea eax,(Player PTR [esi]).cards_showed
	mov ebx,0
	lea esi,(CardGroup PTR [eax]).cards
	mov ecx, 0

	.while ecx < 54
		push ecx
		mov ecx,0
		mov cl,BYTE PTR [esi]
		.if cl==1;选择了这张牌 
			invoke TransparentBlt, hdcScene, x, y, 71, 96, hdcCards,\
				base, 0, 71, 96, 00ff0000h
			add x,22
		.endif
		pop ecx
		inc ecx
		inc esi
		add base,71
	.endw

	ret 
disMyCard endp
;=======================================================================


;=======================================================================
DisPlayer1Card proc uses eax ebx ecx esi edi,_pack: PTR GamePack,playerNo_addr:PTR BYTE
;对手1出的牌
LOCAL x:DWORD
LOCAL y:DWORD
LOCAL base:DWORD
LOCAL count:DWORD
;--------------------------------
	mov edi,_pack
	lea esi,(GamePack PTR [edi]).all_players
	mov eax,SIZEOF Player
	mov ebx,0
	push esi
	mov esi,playerNo_addr
	mov bl,BYTE PTR [esi]
	pop esi
	.if bl == 2
		mov bl,0
	.else
		inc bl
	.endif
	mul ebx
	add esi,eax

	mov eax,0
	mov al,(Player PTR [esi]).to_pass
	;如果不出牌
	.if al==1
		invoke TransparentBlt, hdcScene, 682, 200, 63, 27, hdcNoDiscard,\
			0, 0, 63, 27, 00ffffffh
		ret
	.endif

	;出牌
	lea eax,(Player PTR [esi]).cards_showed
	mov ebx,0
	mov bl,(CardGroup PTR [eax]).count
	mov count,ebx
	.if ebx == 0
		ret
	.endif

	;计算牌堆的起始位置
	mov base,0
	mov x, 685
	mov eax, 20
	mul count
	sub x,eax
	mov y,120

	lea eax,(Player PTR [esi]).cards_showed
	mov ebx,0
	lea esi,(CardGroup PTR [eax]).cards
	mov ecx, 0

	.while ecx < 54
		push ecx
		mov ecx,0
		mov cl,BYTE PTR [esi]
		.if cl==1;选择了这张牌 
			invoke TransparentBlt, hdcScene, x, y, 71, 96, hdcCards,\
				base, 0, 71, 96, 00ff0000h
			add x,22
		.endif
		pop ecx
		inc ecx
		inc esi
		add base,71
	.endw

	ret 

DisPlayer1Card endp

;=======================================================================
DisPlayer2Card proc uses eax ebx ecx edx esi edi,_pack: PTR GamePack,playerNo_addr:PTR BYTE
;对手2出的牌
LOCAL x:DWORD
LOCAL y:DWORD
LOCAL base:DWORD
;--------------------------------
	mov edi,_pack
	lea esi,(GamePack PTR [edi]).all_players
	mov eax,SIZEOF Player
	mov ebx,0
	push esi
	mov esi,playerNo_addr
	mov bl,BYTE PTR [esi]
	pop esi
	.if bl == 0
		mov bl,2
	.else
		dec bl
	.endif
	mul ebx
	add esi,eax

	mov eax,0
	mov al,(Player PTR [esi]).to_pass
	;如果不出牌
	.if al==1
		invoke TransparentBlt, hdcScene, 105, 200, 63, 27, hdcNoDiscard,\
			0, 0, 63, 27, 00ffffffh
		ret
	.endif

	;出牌
	lea eax,(Player PTR [esi]).cards_showed
	mov ebx,0
	mov bl,(CardGroup PTR [eax]).count
	.if ebx == 0
		ret
	.endif

	;计算牌堆的起始位置
	mov x,105
	mov y,120
	mov base,0

	lea eax,(Player PTR [esi]).cards_showed
	mov ebx,0
	lea esi,(CardGroup PTR [eax]).cards
	mov ecx,0

	.while ecx < 54
		push ecx
		mov ecx,0
		mov cl,BYTE PTR [esi]
		.if cl==1;选择了这张牌 
			invoke TransparentBlt, hdcScene, x, y, 71, 96, hdcCards,\
				base, 0, 71, 96, 00ff0000h
			add x,22
		.endif
		pop ecx
		inc ecx
		inc esi
		add base,71
	.endw

	ret 

DisPlayer2Card endp
;=======================================================================

;=======================================================================
DrawPlayerCard proc uses eax ebx ecx edx esi edi,_pack: PTR GamePack,playerNo_addr:PTR BYTE
;绘制对手手牌
LOCAL x:DWORD
LOCAL y:DWORD
LOCAL base:DWORD
LOCAL @oldFont:HFONT
LOCAL @oldColor:COLORREF
LOCAL szText[5]:BYTE
LOCAL num1:DWORD
LOCAL num2:DWORD
;--------------------------------
	mov edi, _pack
	mov cl, (GamePack PTR [edi]).status

	.if cl!=game_GameOver;游戏未结束
		;先绘制牌背面
		invoke TransparentBlt, hdcScene, 760, 65, 71, 96, hdcCardBack,\
			0,0,71,96, 00ff0000h
		invoke TransparentBlt, hdcScene, 14, 65, 71, 96, hdcCardBack,\
			0,0,71,96, 00ff0000h
		invoke CreateFont, 72, 0, 0, 0, 0, 0, 0, 0, DEFAULT_CHARSET, 0, 0, 0, 0, addr fontStyle
		invoke SelectObject, hdcScene,eax
		mov @oldFont,eax
		invoke SetTextColor, hdcScene,008000ffh
		mov @oldColor,eax
		invoke SetBkMode,hdcScene,TRANSPARENT
		;在牌背面绘制剩余牌数
		;player1
		lea esi,(GamePack PTR [edi]).all_players
		mov eax,SIZEOF Player
		mov ebx,0
		push esi
		mov esi,playerNo_addr
		mov bl,BYTE PTR [esi]
		pop esi
		.if bl == 2
			mov bl,0
		.else
			inc bl
		.endif
		mul ebx
		add esi,eax
		movzx eax,(Player PTR [esi]).cards_num
		mov num1,eax
		invoke wsprintf, addr szText,addr szFmt,num1
		.if num1>9
			invoke TextOut,hdcScene,756,77,addr szText,2
		.ELSE
			invoke TextOut,hdcScene,756,77,addr szText,1
		.endif

		;player2
		lea esi,(GamePack PTR [edi]).all_players
		mov eax,SIZEOF Player
		mov ebx,0
		push esi
		mov esi,playerNo_addr
		mov bl,BYTE PTR [esi]
		pop esi
		.if bl == 0
			mov bl,2
		.else
			dec bl
		.endif
		mul ebx
		add esi,eax
		movzx eax,(Player PTR [esi]).cards_num
		mov num2,eax
		invoke wsprintf, addr szText,addr szFmt,num2
		.if num2>9
			invoke TextOut,hdcScene,15,77,addr szText,2
		.ELSE
			invoke TextOut,hdcScene,15,77,addr szText,1
		.endif
		invoke SetTextColor,hdcScene,@oldColor
		invoke SelectObject,hdcScene,@oldFont

	.ELSE;结束，显示全部手牌     
		;绘制对手1的牌 
		pushad

		mov edi,_pack
		lea esi,(GamePack PTR [edi]).all_players
		mov eax,SIZEOF Player
		mov ebx,0
		push esi
		mov esi,playerNo_addr
		mov bl,BYTE PTR [esi]
		pop esi
		.if bl == 2
			mov bl,0
		.else
			inc bl
		.endif
		mul ebx
		add esi,eax
	
		lea edi,(Player PTR [esi]).cards
		mov ecx,0
		mov x,756
		mov y,65
		mov base,0

		.while ecx<54
			push ecx
			mov eax,0
			mov al,BYTE PTR [edi]
			.if al==1
				invoke TransparentBlt, hdcScene, x, y, 71, 96, hdcCards,\
					base, 0, 71, 96, 00ff0000h
				add y,20
			.endif
			pop ecx
			inc ecx
			add base,71
			inc edi
		.endw
		popad

		;绘制对手2的牌    
		pushad

		mov edi,_pack
		lea esi,(GamePack PTR [edi]).all_players
		mov eax,SIZEOF Player
		mov ebx,0
		push esi
		mov esi,playerNo_addr
		mov bl,BYTE PTR [esi]
		pop esi
		.if bl == 0
			mov bl,2
		.else
			dec bl
		.endif
		mul ebx
		add esi,eax
	
		lea edi,(Player PTR [esi]).cards
		mov ecx,0
		mov x,15
		mov y,65
		mov base,0

		.while ecx<54
			push ecx
			mov eax,0
			mov al,BYTE PTR [edi]
			.if al==1
				invoke TransparentBlt, hdcScene, x, y, 71, 96, hdcCards,\
					base, 0, 71, 96, 00ff0000h
				add y,20
			.endif
			pop ecx
			inc ecx
			add base,71
			inc edi
		.endw

		popad

	.endif

	ret 
DrawPlayerCard endp
end 
;=======================================================================

