网络通讯流程：
1. server初始化玩家人数，开启端口监听（默认9999端口）
2. client连接端口（直接输入ip地址，如：127.0.0.1）
3. 所有玩家连入，server向所有玩家发送信息，并告知玩家编号，游戏可以开始
4. server轮询所有玩家是否愿意当地主
    （server向某个client发送消息,可以开始叫地主；client回复是否叫地主；server将client回复的信息处理后发给所有玩家）
5. server决定地主，并发送给所有玩家告知地主编号（目前默认最后一个叫地主的为地主，否则第一个玩家为地主）
6. server轮询所有玩家是否出牌
    （server向某个client发送消息,可以开始出牌；client回复必要信息；server将client回复的信息处理后发给所有client，client还需额外判断该玩家是否成功）
    （server判断是否有client成功，有的话退出监听，不再轮询）
7. 结束游戏


可修改接口：
1. 游戏传输包内容,GAME_PACKAGE。client.inc和server.inc中的结构体定义
2. client端对于数据包的处理：client.asm 函数parsePack


游戏传输包格式：
GAME_PACKAGE struct
	state BYTE ?
	player BYTE ?      ;在ISLORD命令中，存地主的游戏编号
	ifSuccess BYTE ?
	askLord BYTE ?
GAME_PACKAGE ends

state : 命令，每次接收包需要核对命令（握手）
player: 是哪个玩家的信息
ifSuccess: 牌是否出完，在出牌命令中有效
askLord: 是否叫地主，在叫地主命令中有效
注：根据需要可添加其他信息，要注意的是client.inc和server.inc中要同步修改

命令：
S2C_READY EQU 00h        ;开始游戏   
S2C_LORDTURN EQU 01h     ;可以开始叫地主 
C2S_ASKLORD EQU 82h      ;是否叫地主
S2C_REPLYLORD EQU 02h    ;其他玩家的叫地主信息
C2S_ISLORD EQU 83h       ;;;;;;;;目前无效，可能会删除
S2C_ISLORD EQU 03h       ;是否成功叫到地主
S2C_PLAYTURN EQU 04h     ;可以出牌
C2S_PLAYCARD EQU 85h     ;出牌信息
S2C_PLAYCARD EQU 05h     ;其他玩家的出牌信息
S2C_SUCCESS EQU 06h      ;;;;;;;;目前无效，可能会删除

S2C ： server发给client   C2S: client发给server


未完成工作：
1. 有玩家中途中断连接后的处理
2. 有玩家成功后的处理：是否断开连接或者直接关闭server.exe。
3. bind socket失败,包的数据错误etc.   这个太烦了可能只输出一个错误信息，不处理了orz
注：以上会导致一些bug，比如关闭server.exe后，client.exe会一直循环接收包.....

