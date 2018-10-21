; #########################################################################

	;=================
	; include files
	;=================
	;�ڴ˴����������ļ�
	include cardgroup.inc

; #########################################################################
	;=============
    ; Local structures
    ;=============
	;�ڴ˴����ӽṹ��
	Player STRUCT;218BYTE
		player_score WORD 1000;��ҵ�ǰ��������ʼ����Ϊ1000��
		player_position BYTE 0;��ҵ�ǰ�Ƿ�Ϊ��������Ϊ1������Ϊ0��
		cards_num BYTE 0;�����������
		cards BYTE 54 DUP(0);0-53�Ƶļ��ϣ����ƣ�
		card_group BYTE 15 DUP(0);0-14��Ȩֵ���ϣ����ƹ���֮�����ʽ��
		to_pass BYTE 0;�Ƿ���������
		cards_to_show CardGroup <>;��Ҫ�����ƣ�ѡ���У�
		cards_showed CardGroup <>;��һ�ָճ�����
	Player ENDS

	;=================
    ; Local prototypes
    ;=================
	;�ڴ˴����Ӻ���
	NewPlayer PROTO,my_player:PTR Player;��ʼ���������
	AddCard PROTO,my_player:PTR Player,num:BYTE;����
	DelCard PROTO,my_player:PTR Player,num:BYTE;����
	DisCard PROTO,my_player:PTR Player;����
	PassCard PROTO,my_player:PTR Player;����

    ;=============
    ; Local macros
    ;=============
	;�ڴ˴����Ӻ궨��
	get_landlord MACRO my_player:REQ;���õ���
		mov my_player.player_position,1		
	ENDM


; #########################################################################