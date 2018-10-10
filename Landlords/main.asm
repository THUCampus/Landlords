; #########################################################################
;
; 程序入口文件     
;
; #########################################################################

TITLE Main (main.asm)

;引用文件
include irvine32.inc
includelib irvine32.lib

include cardgroup.inc
include cards.inc
include player.inc

INCLUDE Macros.inc


.data
	group1 CardGroup <>
	group2 CardGroup <>
	result BYTE ?
	player1 Player <,3>

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

	mov player1.cards[12],1
	set_landlord player1
	invoke AddCard,addr player1,13
	invoke AddCard,addr player1,14
	invoke AddCard,addr player1,45
	invoke DelCard,addr player1,45

	new_game player1
	mDumpMem OFFSET player1.cards_num, LENGTHOF player1.cards_num, TYPE player1.cards_num

	ret
Main ENDP

END Main