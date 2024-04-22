.386
.model flat, stdcall
option casemap:none

include				windows.inc
include				user32.inc
includelib			user32.lib
include				kernel32.inc
includelib			kernel32.lib
include				Gdi32.inc
includelib			Gdi32.lib
includelib			msvcrt.lib
include				shell32.inc
includelib			shell32.lib
include				comctl32.inc
includelib			comctl32.lib
include				masm32.inc
includelib			masm32.lib

;申明几个函数
printf				PROTO C:dword, :vararg
srand				PROTO C:dword, :vararg
rand				PROTO C:vararg
memset				PROTO C:dword, :dword, :dword, :vararg
sprintf				PROTO C:dword, :dword, :dword, :vararg

;定义需要用到的id
IDI_ICON			equ				201
ID_TIMER			equ				1
ID_UP				equ				101
ID_DOWN				equ				102
ID_LEFT				equ				103
ID_RIGHT			equ				104
ID_STOP				equ				100
ID_SCORE			equ				105
ID_MODULESTARTER	equ				106
ID_MODULESIMPLE		equ				107
ID_MODULEADVANCED	equ				108
ID_MODULEHARD		equ				109
ID_MODULESHOW		equ				110
ID_SpeedShow		equ				111
ID_NewGame			equ				98
ID_SetModule		equ				97
ID_HELP				equ				96
ID_About			equ				95
ID_Continue			equ				94
LF					equ				0ah

.data
hInstance			dd				?
hWinMain			dd				?
dwX					dd				500		dup(0);存储蛇的坐标
dwY					dd				500		dup(0)
dwXT				dd				500		dup(0);用于存储打印坐标终点
dwYT				dd				500		dup(0)
printBuffer			byte			10		dup(0)
dwNextX				dd				?
dwNextY				dd				?
dwXTemp				dd				?			;临时
dwYTemp				dd				?			;临时		
dwSnakeLen			dd				?			;蛇的长度
dwSnakeSize			dd				10			;蛇大小,需要设置蛇大小为步长的一半才能实现头部碰到东西即可吃下
dwStep				dd				20			;步长，即每次移动的距离
dwTime				dd				300			;刷新时间间隔
dwDirection			dd				?			;1表示上，2表示下，3表示左，4表示右，0表示停止
dwDirectionTemp		dd				0			;用于临时保存移动方向
dwRandX				dd				?			;保存随机产生的坐标
dwRandY				dd				?			
dwModuleflag		dd				1			;表示选择的模式，0、1、2、3分别代表入门、简单、进阶、困难模式
Num					byte			"%d", 0		;输出数字
Blank				byte			" ", 0		;输出空格
Line				byte			0ah, 0		;用于输出空行
szButton			byte			"button", 0
szButton_Stop		byte			"暂停", 0
szButton_Restart	byte			"重玩", 0
hButton				dd				?
ButtonFlag			dd				0			;0表示停止，1表示运动，2表示重玩
szStatic			byte			"static", 0
szEdit				byte			"edit", 0
dwSCORE				db				"分数:", 0
dwSPEED				byte			"速度:", 0
hScore				dd				?
szBoxTitle			db				"游戏提示", 0
szBoxText			db				"游戏结束！", 0
; SpeedFlag			dd				0;	自由加速标志 
dwMODULE			db				"模式:", 0
dwMODULESET			byte			'模式设置', 0
dwMODULESTARTER		byte			'入门', 0
dwMODULESIMPLE		byte			'简单', 0
dwMODULEADVANCED	byte			'进阶', 0
dwMODULEHARD		byte			'困难', 0

;wk 障碍物相关
barrierX 			dd				500 	dup(0)
barrierY 			dd				500		dup(0)
barrierXT			dd				500		dup(0)
barrierYT			dd				500 	dup(0)
barrierNum			dd				?
numbe				byte			"%d", 0ah, 0	
hBarrierPen 		HPEN			?

;字体相关
hFont_small			HFONT			?
hFont_big			HFONT			?
hFont_Show			HFONT			?
hFont_digit			HFONT			?
szYaHei				byte			'微软雅黑', 0
szShuTi				byte			'方正舒体', 0
szMVBoli			byte			'MV Boli', 0


;画刷画笔句柄
hWhiteBrush			HBRUSH			?
hBorderPen			HPEN			?
hSnakeHeadPen		HPEN			?
hSnakeBodyPen		HPEN			?
hFoodPen			HPEN			?

;控制当前显示页面的flag
menuFlag			byte			0	;0:开始菜单;1:游戏界面;2:设置速度;3:设置模式...
;控制是否有"继续"按钮的flag
continueBtnFlag		byte			0

.const
szClassName			db				'贪吃蛇', 0
szSetModule			byte			'选择模式', 0
szHelp				byte			'帮助', 0
szAbout				byte			'关于', 0
szNewGame			byte			'新游戏', 0
szContinue			byte			'继续', 0
szHelpText			byte			'使用W、A、S、D或↑、↓、←、→键分别控制贪吃蛇向上下左右转向，以吃到橙色的食物增长身体并获得分数。', LF, LF
szHelpText2			byte			'模式说明:', LF,
									'入门: 作为一条初出茅庐的小蛇，贪吃蛇将以较慢的移动速度谨慎地猎捕食物', LF,
									'简单: 贪吃蛇习得了一定的捕猎经验，现在它捕猎时的移动速度变得更快了', LF,
									'↑这是默认的模式', LF,
									'进阶: 贪吃蛇嘴痒难耐，渴望捕食，它将从猎捕的食物中汲取能量，获得递增的移动速度', LF,
									'困难: 你已经是一条成熟的大蛇了，贪吃蛇将以全速猎捕食物', 0
szAboutText			byte			'本游戏是2022北京理工大学汇编语言与接口技术课程分组实验作业成果，贡献者:', LF,
									'rpy, wk, jjy', LF,
									'实验的部分思路参考了网络博客。', 0

.code
;***************************************************************************************
;
;随机数生成函数
;
;***************************************************************************************
_Rand				proc	
					
					local @stTime:SYSTEMTIME
					invoke GetLocalTime, addr @stTime
					movzx eax, @stTime.wMilliseconds
					invoke srand, eax					;更新种子
					invoke rand
					mov ebx, 19
					div ebx
					imul edx, dwStep
					add edx, 35
					mov dwRandX, edx

					movzx eax, @stTime.wMilliseconds
					invoke rand
					mov ebx, 19
					div ebx
					imul edx, dwStep
					add edx, 35
					mov dwRandY, edx
					
					ret
_Rand				endp


;***************************************************************************************
;
;初始化函数，用于初始化寄存器的值及画笔画刷对象。
;
;***************************************************************************************
_Init				proc
					;将保存坐标的两个数组全部初始化为0
					invoke			memset, addr dwX, 0, sizeof dwX
					invoke			memset, addr dwY, 0, sizeof dwY
					invoke			memset, addr dwXT, 0, sizeof dwXT
					invoke			memset, addr dwYT, 0, sizeof dwYT

					;初始第一个点
					mov eax, 215
					mov ebx, 0
					mov dwX[ebx], eax
					add eax, dwSnakeSize
					mov dwXT[ebx], eax
					mov eax, 35
					mov ebx, 0
					mov dwY[ebx], eax
					add eax, dwSnakeSize
					mov dwYT[ebx], eax

					;初始化第一个猎物的位置
					invoke _Rand
					mov eax, dwRandX
					mov dwNextX, eax
					mov eax, dwRandY
					mov dwNextY, eax

					;初始化蛇长度
					mov dwSnakeLen, 1

					;初始化方向
					mov dwDirection, 2

					;wk,障碍物初始个数为 5
					mov				barrierNum, 5
					;障碍物位置初始化
					mov esi, 0
					.repeat
						;push esi
						;invoke _sleep
						;invoke _Rand
						.repeat
							push esi
							invoke rand
							pop esi
							mov ebx, 19
							div ebx
							imul edx, dwStep
							add edx, 35
						.until edx != dwNextX && edx != dwX[0]
						mov eax, edx
						mov barrierX[esi], eax
						add eax, dwSnakeSize
						mov barrierXT[esi], eax

						.repeat
							push esi
							invoke rand
							pop esi
							mov ebx, 19
							div ebx
							imul edx, dwStep
							add edx, 35
						.until edx != dwNextY && edx != dwY[0]
						mov eax, edx
						mov barrierY[esi], eax
						add eax, dwSnakeSize
						mov barrierYT[esi], eax
						invoke printf, offset numbe, eax
						add esi, 4
						mov ebx, barrierNum
						imul ebx, 4
					.until esi == ebx

					ret
_Init				endp

;***************************************************************************************
;
;设置字体
;
;***************************************************************************************
_createFont			proc
					invoke  CreateFont,
								-16, 
								-8,
								0, 0, 
								400,
								FALSE, FALSE, FALSE,
								DEFAULT_CHARSET,
								OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS,
								DEFAULT_QUALITY,
								FF_DONTCARE,
								offset szYaHei
					mov     hFont_small, eax   
					invoke  CreateFont,
								-48, 
								-24,
								0, 0, 
								FW_BOLD,
								FALSE, FALSE, FALSE,
								DEFAULT_CHARSET,
								OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS,
								DEFAULT_QUALITY,
								FF_DONTCARE,
								offset szShuTi
					mov     hFont_big, eax  
					invoke  CreateFont,
								-30, 
								-15,
								0, 0, 
								FW_BOLD,
								FALSE, FALSE, FALSE,
								DEFAULT_CHARSET,
								OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS,
								DEFAULT_QUALITY,
								FF_DONTCARE,
								offset szShuTi
					mov     hFont_Show, eax  
					invoke  CreateFont,
								-30, 
								-15,
								0, 0, 
								FW_BOLD,
								FALSE, FALSE, FALSE,
								DEFAULT_CHARSET,
								OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS,
								DEFAULT_QUALITY,
								FF_DONTCARE,
								offset szMVBoli
					mov     hFont_digit, eax  

					ret
_createFont			endp

;***************************************************************************************
;
;设置画刷画笔
;
;***************************************************************************************
_createPens			proc
					;初始化背景画刷
					mov				eax, 0ffffffh		
					invoke			CreateSolidBrush, eax
					mov				hWhiteBrush, eax

					;游戏边框画笔
					mov				eax, 0473A2Ch	;BGR
					invoke			CreatePen, PS_INSIDEFRAME, 1, eax
					mov				hBorderPen, eax

					;蛇头蛇身画笔
					mov				eax, 0F7CC25h
					invoke			CreatePen, PS_SOLID, dwSnakeSize, eax
					mov				hSnakeHeadPen, eax
					mov				eax, 0FC9C1Bh
					; mov				eax, 0ffh + 0d3h * 100h + 01h * 10000h
					invoke			CreatePen, PS_SOLID, dwSnakeSize, eax
					mov				hSnakeBodyPen, eax
					;猎物画笔
					mov				eax, 129cf3h
					invoke			CreatePen, PS_SOLID, dwSnakeSize, eax
					mov				hFoodPen, eax
					;wk 障碍物画笔
					mov				eax, 666666h
					invoke			CreatePen, PS_SOLID, dwSnakeSize, eax
					mov				hBarrierPen, eax

					ret
_createPens			endp


;***************************************************************************************
;
;画线函数，从(x1, y1)画线到(x2, y2)
;
;***************************************************************************************
_DrawLine			proc			_hDC, X1, Y1, X2, Y2
					invoke			MoveToEx, _hDC, X1, Y1, NULL
					invoke			LineTo, _hDC, X2, Y2
					ret
_DrawLine			endp


;***************************************************************************************
;
;点更新函数，该函数每调用一次，更新一次位置
;
;***************************************************************************************
_UpdatePosition		proc	_hWnd
					mov eax, 0
					invoke _Rand
					mov esi, dwSnakeLen
					sub esi, 1
					imul esi, 4
					mov eax, dwX[esi]
					mov dwXTemp, eax
					mov eax, dwY[esi]
					mov dwYTemp, eax

					;求出下一个点的位置
					mov esi, dwStep
					mov edx, dwDirection
					.if				edx == 1								;表示向上走
									mov eax, dwYTemp
									sub eax, esi
									mov dwYTemp, eax
					.elseif			edx == 2								;表示向下走
									mov eax, dwYTemp
									add eax, esi
									mov dwYTemp, eax
					.elseif			edx == 3								;表示向左
									mov eax, dwXTemp
									sub eax, esi
									mov dwXTemp, eax
					.elseif			edx == 4								;表示向右
									mov eax, dwXTemp
									add eax, esi
									mov dwXTemp, eax
					.endif

					;判断下一个点是否在蛇中，判断是否碰到边界
					.if dwDirection != 0															;在蛇未停止的情况下才进行判断
						mov esi, dwSnakeLen
						imul esi, 4
						.repeat
							sub esi, 4
							mov eax, dwX[esi]
							mov ebx, dwY[esi]
							.if (dwXTemp > 410 || dwXTemp < 30 || dwYTemp > 410 || dwYTemp < 30) || (eax == dwXTemp && ebx == dwYTemp)
									invoke KillTimer, _hWnd, ID_TIMER								;关闭计时器
									mov	dwXTemp, 0
									mov dwYTemp, 0
									mov dwDirection, 0
									mov ButtonFlag, 2												;修改重玩标志
									invoke SendMessage,hButton,WM_SETTEXT,0,addr szButton_Restart ;按钮显示重玩
									;弹出重玩提示框
									invoke	MessageBox, NULL, offset szBoxText, offset szBoxTitle, MB_OK
									.break															;跳出循环
							.endif
						.until esi == 0
					.endif

					;wk 判断蛇是否碰上障碍物
					.if dwDirection != 0															;在蛇未停止的情况下才进行判断
						mov esi, barrierNum
						imul esi, 4
						.repeat
							sub esi, 4
							mov eax, barrierX[esi]
							mov ebx, barrierY[esi]
							.if (eax == dwXTemp && ebx == dwYTemp)
									invoke KillTimer, _hWnd, ID_TIMER								;关闭计时器
									mov	dwXTemp, 0
									mov dwYTemp, 0
									mov dwDirection, 0
									mov ButtonFlag, 2												;修改重玩标志
									invoke SendMessage,hButton,WM_SETTEXT,0,addr szButton_Restart ;按钮显示重玩
									;弹出重玩提示框
									invoke	MessageBox, NULL, offset szBoxText, offset szBoxTitle, MB_OK
									.break															;跳出循环
							.endif
						.until esi == 0
					.endif

					;判断当前是否停止，停止之后将下一个点的坐标置为0
					.if			dwDirection == 0								
									mov	dwXTemp, 0
									mov dwYTemp, 0
					.endif

					;jjy 判断模式是否为进阶模式
					.if dwModuleflag == 2
						mov esi, dwSnakeLen
						.repeat
							mov eax, esi
							mov ebx, 10
							mul ebx
							add	eax, 190
							.if eax > 400
								mov eax,400
							.endif
							mov ecx,500
							sub ecx,eax
							mov dwTime, ecx										;随着长度改变速度
							invoke SetTimer, _hWnd, ID_TIMER, dwTime, NULL          
							.break
						.until dwDirection == 0
					.endif

					;绘制分数
					mov eax, dwSnakeLen
					sub eax, 1
					invoke 	sprintf, offset printBuffer, offset Num, eax ;将分数转化为字符串
					invoke 	SendMessage,hScore,WM_SETTEXT,0,offset printBuffer
					
					invoke	GetDlgItem, _hWnd, ID_MODULESHOW
					.if	dwModuleflag == 0
						invoke  SetWindowText, eax, offset dwMODULESTARTER
					.elseif	dwModuleflag == 1
						invoke  SetWindowText, eax, offset dwMODULESIMPLE
					.elseif	dwModuleflag == 2
						invoke  SetWindowText, eax, offset dwMODULEADVANCED
					.else	;== 3
						invoke  SetWindowText, eax, offset dwMODULEHARD
					.endif

					mov	eax, 600
					sub	eax, dwTime
					invoke 	sprintf, offset printBuffer, offset Num, eax ;将分数转化为字符串
					invoke	GetDlgItem, _hWnd, ID_SpeedShow
					invoke  SetWindowText, eax, offset printBuffer

					;判断该点和黑点是否相等
					mov eax, dwXTemp
					mov ebx, dwYTemp
					.if eax == dwNextX && ebx == dwNextY && dwXTemp != 0;相等则将该点加入到数组中
									mov esi, dwSnakeLen
									imul esi, 4 
									mov eax, dwNextX
									mov ebx, dwNextY
									mov dwX[esi], eax
									add eax, dwSnakeSize
									mov dwXT[esi], eax					;更新打印终点坐标
									mov dwY[esi], ebx
									add ebx, dwSnakeSize
									mov dwYT[esi], ebx
									add dwSnakeLen, 1

									;更新黑点的位置
									invoke _Rand
									mov eax, dwRandX
									mov dwNextX, eax
									mov eax, dwRandY
									mov dwNextY, eax

									;判断产生的点是否在蛇中
									mov esi, dwSnakeLen
									imul esi, 4
									.repeat
										sub esi, 4
										mov eax, dwX[esi]
										mov ebx, dwY[esi]
										.if eax == dwNextX
											.if ebx == dwNextY
												;如果存在相等则更新猎物的位置
												invoke _Rand
												mov eax, dwRandX
												mov dwNextX, eax
												mov eax, dwRandY
												mov dwNextY, eax
												;循环进行判断判断
												mov esi, dwSnakeLen
												imul esi, 4
											.endif
										.endif
									.until esi == 0

									;wk 判断生成的点是否在障碍物中
									mov esi, 0
									.repeat
										mov eax, barrierX[esi]
										mov ebx, barrierY[esi]
										.if dwNextX == eax && dwNextY == ebx
											.repeat
												push eax
												push ebx
												push esi
												invoke rand
												pop esi
												mov ebx, 19
												div ebx
												imul edx, dwStep
												add edx, 35
												mov dwNextX, edx

												push esi
												invoke rand
												pop esi
												mov ebx, 19
												div ebx
												imul edx, dwStep
												add edx, 35
												mov dwNextY, edx
												pop ebx
												pop eax
											.until barrierX[esi] != eax || barrierY[esi] != ebx
										.endif
										add esi, 4
										mov ebx, barrierNum
										imul ebx, 4
									.until esi == ebx

					.elseif dwXTemp != 0;不相等，则将原有的数组从0到esi依次递推赋值
									mov esi, dwSnakeLen
									imul esi, 4
									mov eax, dwXTemp			;将计算出来的值赋给末尾
									mov dwX[esi], eax
									add eax, dwSnakeSize
									mov dwXT[esi], eax
									mov ebx, dwYTemp
									mov dwY[esi], ebx
									add eax, dwSnakeSize
									mov dwYT[esi], eax
									mov ebx, 0
									mov edi, 4
									.repeat
										mov eax, dwX[edi]
										mov dwX[ebx], eax
										add eax, dwSnakeSize	;更新打印终点坐标
										mov dwXT[ebx], eax
										mov eax, dwY[edi]
										mov dwY[ebx], eax
										add eax, dwSnakeSize
										mov dwYT[ebx], eax
										add ebx, 4
										add edi, 4
									.until ebx == esi
					.endif
					ret
_UpdatePosition		endp


;***************************************************************************************
;
;面板绘制函数
;
;***************************************************************************************
_DrawBorad			proc			_hDC
					local			@hdc,@hBMP,@hDCTemp

					invoke 			KillTimer, hWinMain, ID_TIMER

					;创建双缓冲DC
					invoke			GetDC, hWinMain											;获取界面DC
					mov				@hdc, eax
					invoke			CreateCompatibleDC, @hdc								;创建兼容DC
					mov				@hDCTemp, eax
					invoke			CreateCompatibleBitmap, @hdc, 410, 410					;创建兼容位图
					mov				@hBMP, eax
					invoke			SelectObject, @hDCTemp, @hBMP							;将位图选入DC
					invoke			ReleaseDC, hWinMain, @hdc		
					invoke			SelectObject, @hDCTemp, hWhiteBrush
					invoke			PatBlt, @hDCTemp, 0, 0, 420, 420, PATCOPY				;复制

					;绘制游戏界面边框
					invoke			SelectObject, _hDC, hBorderPen
					invoke			Rectangle, _hDC, 10, 10, 30, 430   ;左竖线
					invoke			Rectangle, _hDC, 10, 10, 430, 30	 ;上横线
					invoke			Rectangle, _hDC, 410, 29, 430, 430   ;右竖线
					invoke			Rectangle, _hDC, 10, 410, 430, 430   ;下横线

					;绘制蛇头部
					mov				edx, dwSnakeSize 
					mov				ebx, dwSnakeLen
					sub				ebx, 1
					imul			ebx, 4
					invoke			SelectObject, @hDCTemp, hSnakeHeadPen
					invoke			Rectangle, @hDCTemp, dwX[ebx], dwY[ebx], dwXT[ebx], dwYT[ebx]

					;绘制蛇身体部分
					invoke			SelectObject, @hDCTemp, hSnakeBodyPen
					mov				ebx, dwSnakeLen
					.if				ebx >= 2
									sub				ebx, 1
									imul			ebx, 4
									.repeat			
													sub				ebx, 4
													invoke			Rectangle, @hDCTemp, dwX[ebx], dwY[ebx], dwXT[ebx], dwYT[ebx]
									.until			ebx == 0
					.endif

					;绘制猎物
					invoke			SelectObject, @hDCTemp, hFoodPen
					mov				eax, dwNextX
					add				eax, dwSnakeSize
					mov				ebx, dwNextY
					add				ebx, dwSnakeSize
					invoke			Rectangle, @hDCTemp, dwNextX, dwNextY, eax, ebx
					invoke			DeleteObject, eax

					;wk 绘制障碍物
					invoke			SelectObject, @hDCTemp, hBarrierPen
					mov 			ebx, barrierNum
					imul			ebx, 4
					.repeat		
						sub			ebx, 4	
						invoke		Rectangle, @hDCTemp, barrierX[ebx], barrierY[ebx], barrierXT[ebx], barrierYT[ebx]
					.until			ebx == 0

					;为了避免界面闪烁，将新建DC中的画面拷贝到主界面DC中
					invoke			BitBlt, _hDC, 30, 30, 410, 410, @hDCTemp, 30, 30, SRCCOPY
					;删除DC
					invoke			DeleteDC, @hDCTemp	
					invoke SetTimer, hWinMain, ID_TIMER, dwTime, NULL

					ret
_DrawBorad			endp			


;***************************************************************************************
;
;用于绘画右侧信息显示边框
;
;***************************************************************************************
_DrawMsgBorder		proc			_hDC
					invoke			SelectObject, _hDC, hBorderPen
					invoke			Rectangle, _hDC, 430, 10, 610 , 30		;上横线
					invoke			Rectangle, _hDC, 430, 210, 610 , 230	;中横线
					invoke			Rectangle, _hDC, 430, 410, 610 , 430	;底部横线
					invoke			Rectangle, _hDC, 610, 10, 630 , 430		;右侧竖线
					ret
_DrawMsgBorder		endp

;***************************************************************************************
;
;隐藏菜单窗口
;
;***************************************************************************************
_hideMenuWindow		proc			uses ebx, hWnd
					mov				ebx, 99
					.WHILE	ebx >= 94
							invoke		GetDlgItem, hWnd, ebx
							invoke		ShowWindow, eax, SW_HIDE
							dec			ebx
					.ENDW
					ret
_hideMenuWindow		endp

;***************************************************************************************
;
;显示菜单窗口
;
;***************************************************************************************
_showMenuWindow		proc			uses ebx, hWnd
					mov				ebx, 99
					.WHILE	ebx >= 95
							invoke		GetDlgItem, hWnd, ebx
							invoke		ShowWindow, eax, SW_SHOW
							dec			ebx
					.ENDW

					.IF	continueBtnFlag	==	1
							invoke		GetDlgItem, hWnd, ID_Continue
							invoke		ShowWindow, eax, SW_SHOW
					.ENDIF
					ret
_showMenuWindow		endp

;***************************************************************************************
;
;显示选择模式窗口
;
;***************************************************************************************
_showModuleWindow	proc			uses ebx, hWnd
					mov				ebx, 109
					.WHILE	ebx >= 106
							invoke		GetDlgItem, hWnd, ebx
							invoke		ShowWindow, eax, SW_SHOW
							dec			ebx
					.ENDW

					invoke		GetDlgItem, hWnd, 99
					push		eax
					invoke		ShowWindow, eax, SW_SHOW
					pop			eax
					invoke  	SetWindowText, eax, offset dwMODULESET
					
					ret
_showModuleWindow	endp

;***************************************************************************************
;
;隐藏选择模式窗口
;
;***************************************************************************************
_hideModuleWindow	proc			uses ebx, hWnd
					mov				ebx, 109
					.WHILE	ebx >= 106
							invoke		GetDlgItem, hWnd, ebx
							invoke		ShowWindow, eax, SW_HIDE
							dec			ebx
					.ENDW

					invoke		GetDlgItem, hWnd, 99
					invoke  	SetWindowText, eax, offset szClassName

					ret
_hideModuleWindow	endp


;***************************************************************************************
;
;显示新游戏的窗口
;
;***************************************************************************************
_showGameWindow		proc			hWnd
					local			@stRect:RECT
					
					;需要重绘的矩形区域
					mov @stRect.left, 0
					mov @stRect.right, 656
					mov @stRect.top, 0
					mov @stRect.bottom, 479
					invoke 			InvalidateRect, hWnd, addr @stRect, FALSE
					
					invoke			GetDlgItem, hWnd, 50
					invoke			ShowWindow, eax, SW_SHOW
					invoke			GetDlgItem, hWnd, ID_SCORE
					invoke			ShowWindow, eax, SW_SHOW
					invoke			GetDlgItem, hWnd, ID_STOP
					invoke			ShowWindow, eax, SW_SHOW
					invoke			GetDlgItem, hWnd, 51
					invoke			ShowWindow, eax, SW_SHOW
					invoke			GetDlgItem, hWnd, ID_MODULESHOW
					invoke			ShowWindow, eax, SW_SHOW
					invoke			GetDlgItem, hWnd, 52
					invoke			ShowWindow, eax, SW_SHOW
					invoke			GetDlgItem, hWnd, ID_SpeedShow
					invoke			ShowWindow, eax, SW_SHOW
					
					ret
_showGameWindow		endp

;***************************************************************************************
;
;隐藏新游戏的窗口
;
;***************************************************************************************

_hideGameWindow		proc			hWnd
					local			@stRect:RECT
					;需要重绘的矩形区域
					mov @stRect.left, 0
					mov @stRect.right, 656
					mov @stRect.top, 0
					mov @stRect.bottom, 479
					invoke 			InvalidateRect, hWnd, addr @stRect, FALSE
					invoke			GetDlgItem, hWnd, 50
					invoke			ShowWindow, eax, SW_HIDE
					invoke			GetDlgItem, hWnd, ID_SCORE
					invoke			ShowWindow, eax, SW_HIDE
					invoke			GetDlgItem, hWnd, ID_STOP
					invoke			ShowWindow, eax, SW_HIDE
					invoke			GetDlgItem, hWnd, 51
					invoke			ShowWindow, eax, SW_HIDE
					invoke			GetDlgItem, hWnd, ID_MODULESHOW
					invoke			ShowWindow, eax, SW_HIDE
					invoke			GetDlgItem, hWnd, 52
					invoke			ShowWindow, eax, SW_HIDE
					invoke			GetDlgItem, hWnd, ID_SpeedShow
					invoke			ShowWindow, eax, SW_HIDE
					ret
_hideGameWindow		endp


;***************************************************************************************
;
;消息函数，处理各种消息
;
;***************************************************************************************
_ProcWinMain		proc			uses ebx edi esi hWnd, uMsg, wParam, lParam
					local			@stPS:PAINTSTRUCT
					local			@stRect:RECT
					local			@hDC, @hBMP
					;需要重绘的矩形区域
					mov @stRect.left, 30
					mov @stRect.right, 410
					mov @stRect.top, 30
					mov @stRect.bottom, 410
					.if				uMsg == WM_TIMER										;计时器到时
									invoke 	_UpdatePosition, hWnd
									;这里可以精确设置重绘区域使得效率更高
									invoke 	InvalidateRect, hWnd, addr @stRect, FALSE		;定时器到时,发送重绘命令，但是不刷新界面
					.elseif			uMsg == WM_PAINT
									invoke BeginPaint, hWnd, addr @stPS
									mov @hDC, eax
									.IF	menuFlag == 1
										invoke _DrawBorad, @hDC									;调用绘画界面函数
										invoke _DrawMsgBorder, @hDC								;绘画右侧边框
									.ELSE 
										invoke			SelectObject, @hDC, hWhiteBrush
										invoke			PatBlt, @hDC, 0, 0, 656, 479, PATCOPY
									.ENDIF
									invoke EndPaint, hWnd, addr @stPS
					.elseif			uMsg == WM_CREATE
									; invoke SetTimer, hWnd, ID_TIMER, dwTime, NULL			;设置定时器
									
									;创建标题显示区域
									invoke	CreateWindowEx, ES_LEFT,\
											offset szEdit, offset szClassName,\
											WS_CHILD or WS_VISIBLE,\
											240, 20, 200, 100,\
											hWnd, 99, hInstance, NULL 
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_big, NULL

									;新游戏按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset szNewGame,\
											WS_CHILD or WS_VISIBLE or BS_FLAT,\
											270, 130, 100, 50,\
											hWnd, ID_NewGame, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;设置模式按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset szSetModule,\
											WS_CHILD or WS_VISIBLE or BS_FLAT,\
											270, 190, 100, 50,\
											hWnd, ID_SetModule,	 hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;帮助按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset szHelp,\
											WS_CHILD or WS_VISIBLE or BS_FLAT,\
											270, 250, 100, 50,\
											hWnd, ID_HELP, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL
									
									;关于按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset szAbout,\
											WS_CHILD or WS_VISIBLE or BS_FLAT,\
											270, 310, 100, 50,\
											hWnd, ID_About, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;继续按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset szContinue,\
											WS_CHILD or BS_FLAT,\
											270, 370, 100, 50,\
											hWnd, ID_Continue, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL


									;----------------------------------------------------------
									
									;入门模式设置按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset dwMODULESTARTER,\
											WS_CHILD or BS_FLAT,\
											270, 130, 100, 50,\
											hWnd, ID_MODULESTARTER, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;简单模式设置按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset dwMODULESIMPLE,\
											WS_CHILD or BS_FLAT,\
											270, 190, 100, 50,\
											hWnd, ID_MODULESIMPLE, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;进阶模式设置按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset dwMODULEADVANCED,\
											WS_CHILD or BS_FLAT,\
											270, 250, 100, 50,\
											hWnd, ID_MODULEADVANCED, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;困难模式设置按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset dwMODULEHARD,\
											WS_CHILD or BS_FLAT,\
											270, 310, 100, 50,\
											hWnd, ID_MODULEHARD, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;----------------------------------------------------------
									
									;创建分数显示区域
									invoke	CreateWindowEx, ES_LEFT,\
											offset szEdit, offset dwSCORE,\
											WS_CHILD  ,\
											440, 30, 70, 30,\
											hWnd, 50, hInstance, NULL 
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_Show, NULL
									invoke	CreateWindowEx, ES_LEFT,\
											offset szEdit,offset Blank ,\
											WS_CHILD  ,\
											520, 30, 70, 30,\
											hWnd, ID_SCORE, hInstance, NULL
									mov		hScore, eax
									invoke  SendMessage,
											hScore,
											WM_SETFONT,
											hFont_Show, NULL

									;创建模式显示区域
									invoke	CreateWindowEx, ES_LEFT,\
											offset szEdit, offset dwMODULE,\
											WS_CHILD  ,\
											440, 70, 70, 30,\
											hWnd, 51, hInstance, NULL 
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_Show, NULL
									invoke	CreateWindowEx, ES_LEFT,\
											offset szEdit,offset Blank ,\
											WS_CHILD  ,\
											520, 70, 70, 30,\
											hWnd, ID_MODULESHOW, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_Show, NULL

									;创建速度显示区域
									invoke	CreateWindowEx, ES_LEFT,\
											offset szEdit, offset dwSPEED,\
											WS_CHILD  ,\
											440, 110, 70, 30,\
											hWnd, 52, hInstance, NULL 
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_Show, NULL
									invoke	CreateWindowEx, ES_LEFT,\
											offset szEdit,offset Blank ,\
											WS_CHILD  ,\
											520, 110, 70, 30,\
											hWnd, ID_SpeedShow, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_Show, NULL


									;暂停/开始/重玩按钮
									invoke	CreateWindowEx, NULL,\
											offset szButton, offset szButton_Stop,\
											WS_CHILD   or BS_FLAT,\
											440, 280, 160, 80,\
											hWnd, ID_STOP, hInstance, NULL
									mov		hButton,eax
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

					.elseif			uMsg == WM_KEYDOWN
									mov eax,wParam
									mov ebx, dwDirection
									.if	eax == VK_UP													;w键表示向上
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_UP,0		
									.elseif eax == VK_DOWN												;s键表示向下
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_DOWN,0
									.elseif eax == VK_LEFT												;a键表示向左
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_LEFT,0
									.elseif eax == VK_RIGHT												;d键表示向右
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_RIGHT,0
									.elseif	eax == 87													;w键表示向上
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_UP,0		
									.elseif eax == 83													;s键表示向下
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_DOWN,0
									.elseif eax == 65													;a键表示向左
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_LEFT,0
									.elseif eax == 68													;d键表示向右
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_RIGHT,0
									.endif

									;********************************可以自由加速
									; .if SpeedFlag == 1
									; 		invoke 	KillTimer, hWnd, ID_TIMER
									; 		invoke 	_UpdatePosition, hWnd
									; 		invoke	GetDC, hWinMain											
									; 		mov		@hDC, eax
									; 		invoke 	_DrawBorad, @hDC
									; 		invoke 	SetTimer, hWnd, ID_TIMER, dwTime, NULL
									; .endif
									;********************************
									
					.elseif			uMsg == WM_COMMAND												
									mov eax,wParam
									mov ebx, dwStep		
									mov esi, dwDirection
									.if	eax == ID_UP && ButtonFlag < 2 && esi != 2					;设置蛇不能转向相反方向
											mov dwDirection, 1
									.elseif eax == ID_DOWN && ButtonFlag != 2 && esi != 1	
											mov dwDirection, 2
									.elseif eax == ID_LEFT && ButtonFlag != 2 && esi != 4
											mov dwDirection, 3
									.elseif	eax == ID_RIGHT && ButtonFlag != 2 && esi != 3	
											mov dwDirection, 4
									.elseif eax == ID_STOP
											mov dwDirectionTemp, esi
											mov dwDirection, 0
											mov menuFlag, 0
											.IF	ButtonFlag == 2		;重开游戏
												mov 	ButtonFlag, 0
												mov		continueBtnFlag, 0
												invoke SendMessage,hButton,WM_SETTEXT,0,addr szButton_Stop ;按钮显示暂停
											.ENDIF
											invoke	_hideGameWindow, hWnd
											invoke	_showMenuWindow, hWnd
											invoke 	KillTimer, hWnd, ID_TIMER
									.elseif	eax == ID_MODULESTARTER		;入门级难度										;处理速度切换按钮
											mov	dwModuleflag, 0
											mov dwTime, 500				;重新设置定时器间隔
											invoke	_hideModuleWindow, hWnd
											invoke	_showMenuWindow, hWnd
									.elseif	eax == ID_MODULESIMPLE		;简单难度	
											mov dwModuleflag, 1
											mov dwTime, 300
											invoke	_hideModuleWindow, hWnd
											invoke	_showMenuWindow, hWnd
									.elseif eax == ID_MODULEADVANCED	;进阶难度
											mov dwModuleflag, 2
											invoke	_hideModuleWindow, hWnd
											invoke	_showMenuWindow, hWnd
									.elseif	eax == ID_MODULEHARD		;困难难度
											mov dwModuleflag, 3
											mov dwTime, 100	
											invoke	_hideModuleWindow, hWnd
											invoke	_showMenuWindow, hWnd
									.elseif	eax == ID_SetModule	
											invoke	_hideMenuWindow, hWnd
											invoke	_showModuleWindow, hWnd
									.elseif eax == ID_HELP
										invoke	MessageBox, hWnd, offset szHelpText, offset szHelp, MB_OK	
									.elseif eax == ID_About
										invoke	MessageBox, hWnd, offset szAboutText, offset szAbout, MB_OK	
									.elseif	eax == ID_NewGame		;新游戏
											mov		continueBtnFlag, 1
											mov 	ButtonFlag, 1
											invoke 	_Init
											mov		menuFlag, 1	
											invoke	_hideMenuWindow, hWnd
											invoke	_showGameWindow, hWnd
											invoke 	SetTimer, hWnd, ID_TIMER, dwTime, NULL	;设置定时器
									.elseif	eax == ID_Continue
											mov edx, dwDirectionTemp
											mov dwDirection, edx
											mov menuFlag, 1
											mov ButtonFlag, 0
											invoke	_hideMenuWindow, hWnd
											invoke	_showGameWindow, hWnd
											invoke SetTimer, hWnd, ID_TIMER, dwTime, NULL
									.endif 
									.if    	ButtonFlag != 2
											invoke SetFocus, hWnd										;游戏中总是让窗口获得焦点
									.endif
									
					.elseif			uMsg == WM_CLOSE
									invoke KillTimer, hWnd, ID_TIMER
									invoke DestroyWindow, hWinMain
									invoke PostQuitMessage, NULL
					.else
									invoke DefWindowProc, hWnd, uMsg, wParam, lParam
									ret
					.endif
					xor				eax, eax
					ret
_ProcWinMain		endp


;***************************************************************************************
;
;注册并创建窗口函数
;
;***************************************************************************************
_WinMain			proc
					local			@stWndClass:WNDCLASSEX
					local			@stMsg:MSG
					invoke			GetModuleHandle, NULL
					mov				hInstance, eax

					;注册窗口类
					invoke			RtlZeroMemory, addr @stWndClass, sizeof @stWndClass
					invoke			LoadIcon, hInstance, IDI_ICON
					mov				@stWndClass.hIcon, eax
					mov				@stWndClass.hIconSm, eax
					invoke			LoadCursor, 0, IDC_ARROW
					mov				@stWndClass.hCursor, eax
					push			hInstance
					pop				@stWndClass.hInstance
					mov				@stWndClass.cbSize, sizeof WNDCLASSEX
					mov				@stWndClass.style, CS_HREDRAW or CS_VREDRAW
					mov				@stWndClass.lpfnWndProc, offset _ProcWinMain
					mov				@stWndClass.hbrBackground, COLOR_WINDOW + 1
					mov				@stWndClass.lpszClassName, offset szClassName
					invoke			RegisterClassEx, addr @stWndClass

					;建立并显示窗口
					invoke			CreateWindowEx,NULL, \
									offset szClassName, offset szClassName,\
									 WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX,\
									CW_USEDEFAULT, CW_USEDEFAULT, \
									656, 479,\
									NULL, NULL, hInstance, NULL
					mov				hWinMain, eax
					invoke			ShowWindow, hWinMain, SW_SHOWNORMAL
					invoke			UpdateWindow, hWinMain

					;消息循环
					.while			TRUE
									invoke GetMessage, addr @stMsg, NULL, 0, 0
									.break .if eax == 0
									invoke TranslateMessage, addr @stMsg
									invoke DispatchMessage, addr @stMsg
					.endw
					ret
_WinMain			endp

;***************************************************************************************
;
;主函数，程序入口
;
;***************************************************************************************
main				proc

					;调用初始化函数初始化寄存器的值
					invoke			_Init
					invoke			_createFont
					invoke			_createPens				

					;调用窗口注册函数
					call			_WinMain
					invoke			ExitProcess, NULL
main				endp
end					main
