; #########################################################################

	;=================
	; include files
	;=================
	;在此处添加引用文件
	include cardgroup.inc

; #########################################################################
	;=============
    ; Local structures
    ;=============
	;在此处添加结构体
	Player STRUCT;218BYTE
		player_score WORD 1000;玩家当前分数（初始化均为1000）
		player_position BYTE 0;玩家当前是否为地主（是为1，不是为0）
		cards_num BYTE 0;玩家手牌数量
		cards BYTE 54 DUP(0);0-53牌的集合（手牌）
		card_group BYTE 15 DUP(0);0-14的权值集合（手牌规整之后的形式）
		to_pass BYTE 0;是否跳过跟牌
		cards_to_show CardGroup <>;将要出的牌（选择中）
		cards_showed CardGroup <>;上一轮刚出的牌
	Player ENDS

	;=================
    ; Local prototypes
    ;=================
	;在此处添加函数
	NewPlayer PROTO,my_player:PTR Player;初始化玩家数据
	AddCard PROTO,my_player:PTR Player,num:BYTE;加牌
	DelCard PROTO,my_player:PTR Player,num:BYTE;减牌

    ;=============
    ; Local macros
    ;=============
	;在此处添加宏定义
	get_landlord MACRO my_player:REQ;设置地主
		mov my_player.player_position,1		
	ENDM


; #########################################################################
