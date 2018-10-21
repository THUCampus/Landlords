; #########################################################################

	;=================
    ; Local prototypes
    ;=================
	;在此处添加函数
	Cards PROTO,my_cards:PTR BYTE,my_remain:PTR BYTE;初始化牌组cards_cards
	RandCards PROTO,my_cards:PTR BYTE,my_remain:PTR BYTE;随机洗牌
	GetCard PROTO,result:PTR BYTE,my_remain:PTR BYTE,my_cards:PTR BYTE;发牌

; #########################################################################
