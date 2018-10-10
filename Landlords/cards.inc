; #########################################################################

	;=================
    ; Local prototypes
    ;=================
	;在此处添加函数
	Cards PROTO,my_cards:PTR BYTE,my_remain:PTR BYTE;初始化牌组cards_cards
	RandCards PROTO,my_cards:PTR BYTE,my_remain:PTR BYTE;随机洗牌
	GetCard PROTO,result:PTR BYTE,my_remain:PTR BYTE,my_cards:PTR BYTE;抽牌

; #########################################################################

    .data
		;在此处添加变量
        cards_cards BYTE 54 DUP(0);牌数组
		cards_remain BYTE 54;剩余牌数
		

; #########################################################################
