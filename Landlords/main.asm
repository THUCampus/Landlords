; #########################################################################
;
; 程序入口文件     
;
; #########################################################################

TITLE Main (main.asm)

;引用文件
include irvine32.inc
includelib irvine32.lib

include game.inc

INCLUDE Macros.inc


.data
	group1 CardGroup <>
	group2 CardGroup <>
	result BYTE ?
	player1 Player <,3>

	my_game Game  <>

.code

;-----------------------------------------------------
Main PROC
; 函数功能:暂无
; 返回值:无
;-----------------------------------------------------
	;函数实现
		
	;invoke AddNumber,ADDR group2,18
	;invoke AddNumber,ADDR group2,31
	;invoke AddNumber,ADDR group2,5
	;invoke AddNumber,ADDR group2,6

	;invoke DeleteNumber,ADDR group2,31
	;invoke DeleteNumber,ADDR group2,3

	;invoke Clear,ADDR group2

	;mDumpMem OFFSET group2.count, LENGTHOF group2.count, TYPE group2.count
	;mDumpMem OFFSET group2.card_group, LENGTHOF group2.card_group, TYPE group2.card_group
	;mDumpMem OFFSET group2.cards, LENGTHOF group2.cards, TYPE group2.cards

	;invoke Cards,ADDR cards_cards,ADDR cards_remain
	;invoke GetCard,ADDR result,ADDR cards_remain,ADDR cards_cards
	;mDumpMem OFFSET cards_cards, LENGTHOF cards_cards, TYPE cards_cards
	;mDumpMem OFFSET cards_remain, LENGTHOF cards_remain, TYPE cards_remain
	;mDumpMem OFFSET result, LENGTHOF result, TYPE result

	;mov player1.cards[12],1
	;set_landlord player1
	;invoke AddCard,addr player1,13
	;invoke AddCard,addr player1,14
	;invoke AddCard,addr player1,45
	;invoke DelCard,addr player1,45

	;invoke NewPlayer,addr player1
	;mDumpMem OFFSET player1.card_group, LENGTHOF player1.card_group, TYPE player1.card_group


	;lea esi,my_game.all_players
	;invoke AddCard,esi,13
	;lea edi,(Player PTR [esi]).card_group
	;invoke GameStart,addr my_game
	;mDumpMem edi, LENGTHOF (Player PTR [esi]).card_group, TYPE (Player PTR [esi]).card_group

;	add esi,TYPE Player
;	invoke AddCard,esi,20
;	lea edi,(Player PTR [esi]).card_group
;	invoke GameStart,addr my_game
;	mDumpMem edi, LENGTHOF (Player PTR [esi]).card_group, TYPE (Player PTR [esi]).card_group

;	mDumpMem OFFSET my_game.all_cards, LENGTHOF my_game.all_cards, TYPE my_game.all_cards
;	lea edi,my_game.landlord_cards
;	mDumpMem edi, LENGTHOF my_game.landlord_cards, TYPE my_game.landlord_cards
;	;--------------------------------------------------------
;	invoke SendCard,addr my_game
;	lea esi,my_game.all_players
;	;mov (Player PTR [esi]).player_position,1
;	add esi,TYPE Player
;	mov (Player PTR [esi]).player_position,1
;	add esi,TYPE Player
;	mov (Player PTR [esi]).player_position,1
;	invoke SetLandlord,addr my_game
;	invoke SendLandlordCard,addr my_game
;
;	lea esi,my_game.all_players
;	lea edi,(Player PTR [esi]).card_group
;	mDumpMem edi, LENGTHOF (Player PTR [esi]).card_group, TYPE (Player PTR [esi]).card_group
;
;	add esi,TYPE Player
;	lea edi,(Player PTR [esi]).card_group
;	mDumpMem edi, LENGTHOF (Player PTR [esi]).card_group, TYPE (Player PTR [esi]).card_group
;
;	add esi,TYPE Player
;;	lea edi,(Player PTR [esi]).card_group
;	mDumpMem edi, LENGTHOF (Player PTR [esi]).card_group, TYPE (Player PTR [esi]).card_group
;
;	lea edi,my_game.landlord_cards
;	mDumpMem edi, LENGTHOF my_game.landlord_cards, TYPE my_game.landlord_cards
;	;-----------------------------------------------------------------
;

;	lea esi,my_game.all_players
;	lea edi,(Player PTR [esi]).player_position
;	mDumpMem edi, LENGTHOF (Player PTR [esi]).player_position, TYPE (Player PTR [esi]).player_position
;
;	add esi,TYPE Player
;	lea edi,(Player PTR [esi]).player_position
;	mDumpMem edi, LENGTHOF (Player PTR [esi]).player_position, TYPE (Player PTR [esi]).player_position
;
;	add esi,TYPE Player
;	lea edi,(Player PTR [esi]).player_position
;	mDumpMem edi, LENGTHOF (Player PTR [esi]).player_position, TYPE (Player PTR [esi]).player_position

	invoke GameStart,addr my_game
	invoke SendCard,addr my_game
	invoke SetLandlord,addr my_game
	invoke SendLandlordCard,addr my_game

	lea esi,my_game.all_players
	lea edi,(Player PTR [esi]).cards
	mDumpMem edi, LENGTHOF (Player PTR [esi]).cards, TYPE (Player PTR [esi]).cards

	invoke Discard,esi
	lea esi,my_game.all_players
	lea edi,(Player PTR [esi]).cards
	mDumpMem edi, LENGTHOF (Player PTR [esi]).cards, TYPE (Player PTR [esi]).cards

	lea esi,my_game.all_players
	lea edi,(Player PTR [esi]).cards_to_show
	lea esi,(CardGroup PTR [edi]).cards
	mDumpMem esi, LENGTHOF (CardGroup PTR [edi]).cards, TYPE (CardGroup PTR [edi]).cards

	lea esi,my_game.all_players
	lea edi,(Player PTR [esi]).cards_showed
	lea esi,(CardGroup PTR [edi]).cards
	mDumpMem esi, LENGTHOF (CardGroup PTR [edi]).cards, TYPE (CardGroup PTR [edi]).cards


	ret
Main ENDP

END Main