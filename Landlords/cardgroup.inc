.386
.model  flat, stdcall

; #########################################################################

	;=============
    ; Local structures
    ;=============
	;在此处添加结构体
	CardGroup STRUCT
		group_type BYTE 0;牌型类型
		value BYTE 0;//权值
		count BYTE 0;//此结构元素数量
		cards BYTE 54 DUP(0);0-53牌的集合
		card_group BYTE 15 DUP(0);0-14的权值集合
	CardGroup ENDS


	;=================
    ; Local prototypes
    ;=================
	;在此处添加函数
	AddNumber PROTO,_group:PTR CardGroup,num:BYTE;添加0-53表示的牌元素
	DeleteNumber PROTO,_group:PTR CardGroup,num:BYTE;去掉一张牌
	Clear PROTO,_group:PTR CardGroup;//重置此结构
	Translate PROTO,num:BYTE,result:PTR BYTE;把0-53转换成0-14权值，其中A（11）、2（12）、小王（13）、大王（14）


    ;=============
    ; Local macros
    ;=============
	;在此处添加宏定义
	bequal MACRO val1:REQ,val2:REQ ;赋值BYTE值
		push ax
		mov al,val2
		mov val1,al
		pop ax
	ENDM

	wequal MACRO val1:REQ,val2:REQ ;赋值WORD值
		push ax
		mov ax,val2
		mov val1,ax
		pop ax
	ENDM		

	cardgroup_equal MACRO group1:REQ,group2:REQ ;赋值牌组
		push esi
		bequal group1.group_type,group2.group_type
		bequal group1.value,group2.value
		bequal group1.count,group2.count

		mov esi,0
		.while esi<54
			bequal group1.cards[esi],group2.cards[esi]
			inc esi
		.endw

		mov esi,0
		.while esi<15
			bequal group1.card_group[esi],group2.card_group[esi]
			inc esi
		.endw
		pop esi

	ENDM	

; #########################################################################

    .data
		;在此处添加变量

        ;一组牌的可能类型
		cardgroup_Unkown = 0;未知
		cardgroup_Single = 1;单张
		cardgroup_Double = 2;对子
		cardgroup_Three = 3;三条
		cardgroup_SingleSeq = 4;单顺
		cardgroup_DoubleSeq = 5;双顺
		cardgroup_ThreeSeq = 6;三顺
		cardgroup_ThreePlus = 7;三带一（一张或一对）
		cardgroup_Airplane = 8;飞机
		cardgroup_FourSeq = 9;四带二（两张或两对）
		cardgroup_Bomb = 10;炸弹、王炸
	

; #########################################################################
