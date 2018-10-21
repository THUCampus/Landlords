; #########################################################################

	;=================
	; include files
	;=================
	;在此处添加引用文件
	include player.inc
	include cards.inc

; #########################################################################

	;=============
    ; Local structures
    ;=============
	;在此处添加结构体
	GamePack STRUCT;714BYTE
		now_player BYTE 0;现在的游戏玩家编号
		status BYTE 0;游戏进度
		all_cards BYTE 54 DUP(0);牌数组
		all_cards_remain BYTE 54;剩余牌数
		landlord_cards BYTE 3 DUP(0);地主牌
		all_players Player 3 DUP(<>);所有玩家信息
	GamePack ENDS

	;=================
    ; Local prototypes
    ;=================
	;在此处添加函数
    GameStart PROTO,gamePtr:PTR GamePack;游戏开始初始化
	SendCard PROTO,gamePtr:PTR GamePack;发牌
	SetLandlord PROTO,gamePtr:PTR GamePack;设置地主
	SendLandlordCard PROTO,gamePtr:PTR GamePack;发地主牌
	GamePlaying PROTO,gamePtr:PTR GamePack;游戏进行中
	GameOver PROTO,gamePtr:PTR GamePack;游戏结束

; #########################################################################

    .data
		;在此处添加变量

        ;游戏状态
		game_NoStart = 0;未开始
		game_GetLandlord= 1;叫地主阶段
		game_SendLandlordCard = 2;发地主牌阶段
		game_Discard = 3;出牌阶段
		game_GameOver = 4;游戏结束	

; #########################################################################
