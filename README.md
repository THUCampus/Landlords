# 环境要求
* 操作系统：Windows 10 （64 位）
* IDE：Visual Studio 2015/2017
* 汇编开发工具包：MASM32
# 实现原理
## 项目架构目录
```
./Landlords
├── 头文件
│   ├── resource.h
│   ├── cardgroup.inc
│   ├── cards.inc
│   ├── client.inc
│   ├── game.inc
│   ├── player.inc
│   └── server.inc
├── 源文件
│   ├── cardgroup.asm           // 存储牌组（出牌时选择的手牌）
│   ├── cards.asm               // 管理扑克牌操作（洗牌、发牌）
│   ├── client.asm              // 管理客户端的各种操作
│   ├── game.asm                // 控制整个游戏进行过程
│   ├── player.asm              // 管理玩家操作（抽牌、出牌）
│   ├── scene.asm               // 管理游戏界面与点击事件         
│   └── server.asm              // 管理服务器的各种操作
└── 资源文件
    ├── xxx.bmp                 // 各种图片资源
    └── landlord_gui.rc         // 资源管理文件
```
## 程序模块设计
### 1、游戏逻辑
* 可以等概率地洗牌、发牌；
* 可以判断哪位玩家成功叫得地主，并将三张地主牌发给此玩家；
* 每轮游戏均从地主开始按照逆时针顺序轮流出牌，出牌情况会告知所有玩家；
* 每次出牌结束后，更新所有玩家的数据与界面显示；
* 当一个玩家牌数为0时，游戏结束，判定胜方（地主or农民）并进行游戏结束提示。
### 2、网络通信
* 服务器负责接受所有玩家的传入数据，进行处理判断后将结果告知所有玩家；
* 客户端可以接受服务器传入的数据，也可以将玩家操作之后的新数据传给服务器。
### 3、界面设计
* 在游戏开始时，界面上会弹出一个输入框，用户输入服务器所在ip地址进行连接；
* 在游戏过程中，界面上会显示三张地主牌，玩家自身的手牌，玩家自身的角色（地主还是农民），所有玩家的出牌情况，其他玩家的手牌数量；
* 在游戏过程中，玩家可以点击按钮进行叫地主的操作与出牌的操作；
* 当游戏结束后，界面上会弹出提示框，告知玩家游戏结束信息，同时会展示其他玩家手牌；
* 当游戏结束后，玩家可以点击提示框的确认按钮继续游戏，也可以关闭窗口离开游戏。
# 操作说明
## 程序的生成与使用
1. 在client.asm文件中将client_main设置为程序入口点，设置子系统为窗口，汇编生成exe文件；
2. 在Debug目录下找到生成的exe文件，分别拷贝三份到另一个目录下（重命名为player1.exe、player2.exe、player3.exe）；
3. 在server.asm文件中将server_main设置为程序入口点，设置子系统为控制台，汇编生成exe文件；
4. 在Debug目录下找到生成的exe文件，拷贝到另一个目录下（命名为server.exe）；
5. 先启动server.exe，显示**Game Start!**则表示服务器运行正确；
6. 依次启动player1.exe、player2.exe、player3.exe，输入ip地址与服务器进行连接；
7. 进行游戏
  1. **叫地主环节**：点击**一分**按钮叫地主，点击**不叫**按钮放弃叫地主；
  2. **出牌环节**：点击**手牌**进行选择，点击**出牌按钮**出牌，点击**不出按钮**过牌；
  3. **游戏结束**：点击**提示框上的确定按钮**继续下一轮游戏。
## 程序的运行截图
### 服务器
![图片](https://images-cdn.shimo.im/AYpKfD0uPMU9JECV/无标题.png!thumbnail)
### 客户端
1、ip地址输入框<br>
![图片](https://images-cdn.shimo.im/6eDmhA0Is6c5ye6s/无标题.png!thumbnail)<br>
2、叫地主界面<br>
![图片](https://images-cdn.shimo.im/45Hfe4SmgRodCXEa/无标题.png!thumbnail)<br>
3、游戏界面<br>
![图片](https://images-cdn.shimo.im/vXirYaHPmaExxXvd/无标题.png!thumbnail)<br>
4、结束界面<br>
![图片](https://images-cdn.shimo.im/Myd8xJX1hx4P1ZLF/无标题.png!thumbnail)<br>


