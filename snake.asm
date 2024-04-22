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

;������������
printf				PROTO C:dword, :vararg
srand				PROTO C:dword, :vararg
rand				PROTO C:vararg
memset				PROTO C:dword, :dword, :dword, :vararg
sprintf				PROTO C:dword, :dword, :dword, :vararg

;������Ҫ�õ���id
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
dwX					dd				500		dup(0);�洢�ߵ�����
dwY					dd				500		dup(0)
dwXT				dd				500		dup(0);���ڴ洢��ӡ�����յ�
dwYT				dd				500		dup(0)
printBuffer			byte			10		dup(0)
dwNextX				dd				?
dwNextY				dd				?
dwXTemp				dd				?			;��ʱ
dwYTemp				dd				?			;��ʱ		
dwSnakeLen			dd				?			;�ߵĳ���
dwSnakeSize			dd				10			;�ߴ�С,��Ҫ�����ߴ�СΪ������һ�����ʵ��ͷ�������������ɳ���
dwStep				dd				20			;��������ÿ���ƶ��ľ���
dwTime				dd				300			;ˢ��ʱ����
dwDirection			dd				?			;1��ʾ�ϣ�2��ʾ�£�3��ʾ��4��ʾ�ң�0��ʾֹͣ
dwDirectionTemp		dd				0			;������ʱ�����ƶ�����
dwRandX				dd				?			;�����������������
dwRandY				dd				?			
dwModuleflag		dd				1			;��ʾѡ���ģʽ��0��1��2��3�ֱ�������š��򵥡����ס�����ģʽ
Num					byte			"%d", 0		;�������
Blank				byte			" ", 0		;����ո�
Line				byte			0ah, 0		;�����������
szButton			byte			"button", 0
szButton_Stop		byte			"��ͣ", 0
szButton_Restart	byte			"����", 0
hButton				dd				?
ButtonFlag			dd				0			;0��ʾֹͣ��1��ʾ�˶���2��ʾ����
szStatic			byte			"static", 0
szEdit				byte			"edit", 0
dwSCORE				db				"����:", 0
dwSPEED				byte			"�ٶ�:", 0
hScore				dd				?
szBoxTitle			db				"��Ϸ��ʾ", 0
szBoxText			db				"��Ϸ������", 0
; SpeedFlag			dd				0;	���ɼ��ٱ�־ 
dwMODULE			db				"ģʽ:", 0
dwMODULESET			byte			'ģʽ����', 0
dwMODULESTARTER		byte			'����', 0
dwMODULESIMPLE		byte			'��', 0
dwMODULEADVANCED	byte			'����', 0
dwMODULEHARD		byte			'����', 0

;wk �ϰ������
barrierX 			dd				500 	dup(0)
barrierY 			dd				500		dup(0)
barrierXT			dd				500		dup(0)
barrierYT			dd				500 	dup(0)
barrierNum			dd				?
numbe				byte			"%d", 0ah, 0	
hBarrierPen 		HPEN			?

;�������
hFont_small			HFONT			?
hFont_big			HFONT			?
hFont_Show			HFONT			?
hFont_digit			HFONT			?
szYaHei				byte			'΢���ź�', 0
szShuTi				byte			'��������', 0
szMVBoli			byte			'MV Boli', 0


;��ˢ���ʾ��
hWhiteBrush			HBRUSH			?
hBorderPen			HPEN			?
hSnakeHeadPen		HPEN			?
hSnakeBodyPen		HPEN			?
hFoodPen			HPEN			?

;���Ƶ�ǰ��ʾҳ���flag
menuFlag			byte			0	;0:��ʼ�˵�;1:��Ϸ����;2:�����ٶ�;3:����ģʽ...
;�����Ƿ���"����"��ť��flag
continueBtnFlag		byte			0

.const
szClassName			db				'̰����', 0
szSetModule			byte			'ѡ��ģʽ', 0
szHelp				byte			'����', 0
szAbout				byte			'����', 0
szNewGame			byte			'����Ϸ', 0
szContinue			byte			'����', 0
szHelpText			byte			'ʹ��W��A��S��D������������������ֱ����̰��������������ת���ԳԵ���ɫ��ʳ���������岢��÷�����', LF, LF
szHelpText2			byte			'ģʽ˵��:', LF,
									'����: ��Ϊһ������é®��С�ߣ�̰���߽��Խ������ƶ��ٶȽ������Բ�ʳ��', LF,
									'��: ̰����ϰ����һ���Ĳ��Ծ��飬����������ʱ���ƶ��ٶȱ�ø�����', LF,
									'������Ĭ�ϵ�ģʽ', LF,
									'����: ̰�����������ͣ�������ʳ���������Բ���ʳ���м�ȡ��������õ������ƶ��ٶ�', LF,
									'����: ���Ѿ���һ������Ĵ����ˣ�̰���߽���ȫ���Բ�ʳ��', 0
szAboutText			byte			'����Ϸ��2022��������ѧ���������ӿڼ����γ̷���ʵ����ҵ�ɹ���������:', LF,
									'rpy, wk, jjy', LF,
									'ʵ��Ĳ���˼·�ο������粩�͡�', 0

.code
;***************************************************************************************
;
;��������ɺ���
;
;***************************************************************************************
_Rand				proc	
					
					local @stTime:SYSTEMTIME
					invoke GetLocalTime, addr @stTime
					movzx eax, @stTime.wMilliseconds
					invoke srand, eax					;��������
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
;��ʼ�����������ڳ�ʼ���Ĵ�����ֵ�����ʻ�ˢ����
;
;***************************************************************************************
_Init				proc
					;�������������������ȫ����ʼ��Ϊ0
					invoke			memset, addr dwX, 0, sizeof dwX
					invoke			memset, addr dwY, 0, sizeof dwY
					invoke			memset, addr dwXT, 0, sizeof dwXT
					invoke			memset, addr dwYT, 0, sizeof dwYT

					;��ʼ��һ����
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

					;��ʼ����һ�������λ��
					invoke _Rand
					mov eax, dwRandX
					mov dwNextX, eax
					mov eax, dwRandY
					mov dwNextY, eax

					;��ʼ���߳���
					mov dwSnakeLen, 1

					;��ʼ������
					mov dwDirection, 2

					;wk,�ϰ����ʼ����Ϊ 5
					mov				barrierNum, 5
					;�ϰ���λ�ó�ʼ��
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
;��������
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
;���û�ˢ����
;
;***************************************************************************************
_createPens			proc
					;��ʼ��������ˢ
					mov				eax, 0ffffffh		
					invoke			CreateSolidBrush, eax
					mov				hWhiteBrush, eax

					;��Ϸ�߿򻭱�
					mov				eax, 0473A2Ch	;BGR
					invoke			CreatePen, PS_INSIDEFRAME, 1, eax
					mov				hBorderPen, eax

					;��ͷ������
					mov				eax, 0F7CC25h
					invoke			CreatePen, PS_SOLID, dwSnakeSize, eax
					mov				hSnakeHeadPen, eax
					mov				eax, 0FC9C1Bh
					; mov				eax, 0ffh + 0d3h * 100h + 01h * 10000h
					invoke			CreatePen, PS_SOLID, dwSnakeSize, eax
					mov				hSnakeBodyPen, eax
					;���ﻭ��
					mov				eax, 129cf3h
					invoke			CreatePen, PS_SOLID, dwSnakeSize, eax
					mov				hFoodPen, eax
					;wk �ϰ��ﻭ��
					mov				eax, 666666h
					invoke			CreatePen, PS_SOLID, dwSnakeSize, eax
					mov				hBarrierPen, eax

					ret
_createPens			endp


;***************************************************************************************
;
;���ߺ�������(x1, y1)���ߵ�(x2, y2)
;
;***************************************************************************************
_DrawLine			proc			_hDC, X1, Y1, X2, Y2
					invoke			MoveToEx, _hDC, X1, Y1, NULL
					invoke			LineTo, _hDC, X2, Y2
					ret
_DrawLine			endp


;***************************************************************************************
;
;����º������ú���ÿ����һ�Σ�����һ��λ��
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

					;�����һ�����λ��
					mov esi, dwStep
					mov edx, dwDirection
					.if				edx == 1								;��ʾ������
									mov eax, dwYTemp
									sub eax, esi
									mov dwYTemp, eax
					.elseif			edx == 2								;��ʾ������
									mov eax, dwYTemp
									add eax, esi
									mov dwYTemp, eax
					.elseif			edx == 3								;��ʾ����
									mov eax, dwXTemp
									sub eax, esi
									mov dwXTemp, eax
					.elseif			edx == 4								;��ʾ����
									mov eax, dwXTemp
									add eax, esi
									mov dwXTemp, eax
					.endif

					;�ж���һ�����Ƿ������У��ж��Ƿ������߽�
					.if dwDirection != 0															;����δֹͣ������²Ž����ж�
						mov esi, dwSnakeLen
						imul esi, 4
						.repeat
							sub esi, 4
							mov eax, dwX[esi]
							mov ebx, dwY[esi]
							.if (dwXTemp > 410 || dwXTemp < 30 || dwYTemp > 410 || dwYTemp < 30) || (eax == dwXTemp && ebx == dwYTemp)
									invoke KillTimer, _hWnd, ID_TIMER								;�رռ�ʱ��
									mov	dwXTemp, 0
									mov dwYTemp, 0
									mov dwDirection, 0
									mov ButtonFlag, 2												;�޸������־
									invoke SendMessage,hButton,WM_SETTEXT,0,addr szButton_Restart ;��ť��ʾ����
									;����������ʾ��
									invoke	MessageBox, NULL, offset szBoxText, offset szBoxTitle, MB_OK
									.break															;����ѭ��
							.endif
						.until esi == 0
					.endif

					;wk �ж����Ƿ������ϰ���
					.if dwDirection != 0															;����δֹͣ������²Ž����ж�
						mov esi, barrierNum
						imul esi, 4
						.repeat
							sub esi, 4
							mov eax, barrierX[esi]
							mov ebx, barrierY[esi]
							.if (eax == dwXTemp && ebx == dwYTemp)
									invoke KillTimer, _hWnd, ID_TIMER								;�رռ�ʱ��
									mov	dwXTemp, 0
									mov dwYTemp, 0
									mov dwDirection, 0
									mov ButtonFlag, 2												;�޸������־
									invoke SendMessage,hButton,WM_SETTEXT,0,addr szButton_Restart ;��ť��ʾ����
									;����������ʾ��
									invoke	MessageBox, NULL, offset szBoxText, offset szBoxTitle, MB_OK
									.break															;����ѭ��
							.endif
						.until esi == 0
					.endif

					;�жϵ�ǰ�Ƿ�ֹͣ��ֹ֮ͣ����һ�����������Ϊ0
					.if			dwDirection == 0								
									mov	dwXTemp, 0
									mov dwYTemp, 0
					.endif

					;jjy �ж�ģʽ�Ƿ�Ϊ����ģʽ
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
							mov dwTime, ecx										;���ų��ȸı��ٶ�
							invoke SetTimer, _hWnd, ID_TIMER, dwTime, NULL          
							.break
						.until dwDirection == 0
					.endif

					;���Ʒ���
					mov eax, dwSnakeLen
					sub eax, 1
					invoke 	sprintf, offset printBuffer, offset Num, eax ;������ת��Ϊ�ַ���
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
					invoke 	sprintf, offset printBuffer, offset Num, eax ;������ת��Ϊ�ַ���
					invoke	GetDlgItem, _hWnd, ID_SpeedShow
					invoke  SetWindowText, eax, offset printBuffer

					;�жϸõ�ͺڵ��Ƿ����
					mov eax, dwXTemp
					mov ebx, dwYTemp
					.if eax == dwNextX && ebx == dwNextY && dwXTemp != 0;����򽫸õ���뵽������
									mov esi, dwSnakeLen
									imul esi, 4 
									mov eax, dwNextX
									mov ebx, dwNextY
									mov dwX[esi], eax
									add eax, dwSnakeSize
									mov dwXT[esi], eax					;���´�ӡ�յ�����
									mov dwY[esi], ebx
									add ebx, dwSnakeSize
									mov dwYT[esi], ebx
									add dwSnakeLen, 1

									;���ºڵ��λ��
									invoke _Rand
									mov eax, dwRandX
									mov dwNextX, eax
									mov eax, dwRandY
									mov dwNextY, eax

									;�жϲ����ĵ��Ƿ�������
									mov esi, dwSnakeLen
									imul esi, 4
									.repeat
										sub esi, 4
										mov eax, dwX[esi]
										mov ebx, dwY[esi]
										.if eax == dwNextX
											.if ebx == dwNextY
												;��������������������λ��
												invoke _Rand
												mov eax, dwRandX
												mov dwNextX, eax
												mov eax, dwRandY
												mov dwNextY, eax
												;ѭ�������ж��ж�
												mov esi, dwSnakeLen
												imul esi, 4
											.endif
										.endif
									.until esi == 0

									;wk �ж����ɵĵ��Ƿ����ϰ�����
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

					.elseif dwXTemp != 0;����ȣ���ԭ�е������0��esi���ε��Ƹ�ֵ
									mov esi, dwSnakeLen
									imul esi, 4
									mov eax, dwXTemp			;�����������ֵ����ĩβ
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
										add eax, dwSnakeSize	;���´�ӡ�յ�����
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
;�����ƺ���
;
;***************************************************************************************
_DrawBorad			proc			_hDC
					local			@hdc,@hBMP,@hDCTemp

					invoke 			KillTimer, hWinMain, ID_TIMER

					;����˫����DC
					invoke			GetDC, hWinMain											;��ȡ����DC
					mov				@hdc, eax
					invoke			CreateCompatibleDC, @hdc								;��������DC
					mov				@hDCTemp, eax
					invoke			CreateCompatibleBitmap, @hdc, 410, 410					;��������λͼ
					mov				@hBMP, eax
					invoke			SelectObject, @hDCTemp, @hBMP							;��λͼѡ��DC
					invoke			ReleaseDC, hWinMain, @hdc		
					invoke			SelectObject, @hDCTemp, hWhiteBrush
					invoke			PatBlt, @hDCTemp, 0, 0, 420, 420, PATCOPY				;����

					;������Ϸ����߿�
					invoke			SelectObject, _hDC, hBorderPen
					invoke			Rectangle, _hDC, 10, 10, 30, 430   ;������
					invoke			Rectangle, _hDC, 10, 10, 430, 30	 ;�Ϻ���
					invoke			Rectangle, _hDC, 410, 29, 430, 430   ;������
					invoke			Rectangle, _hDC, 10, 410, 430, 430   ;�º���

					;������ͷ��
					mov				edx, dwSnakeSize 
					mov				ebx, dwSnakeLen
					sub				ebx, 1
					imul			ebx, 4
					invoke			SelectObject, @hDCTemp, hSnakeHeadPen
					invoke			Rectangle, @hDCTemp, dwX[ebx], dwY[ebx], dwXT[ebx], dwYT[ebx]

					;���������岿��
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

					;��������
					invoke			SelectObject, @hDCTemp, hFoodPen
					mov				eax, dwNextX
					add				eax, dwSnakeSize
					mov				ebx, dwNextY
					add				ebx, dwSnakeSize
					invoke			Rectangle, @hDCTemp, dwNextX, dwNextY, eax, ebx
					invoke			DeleteObject, eax

					;wk �����ϰ���
					invoke			SelectObject, @hDCTemp, hBarrierPen
					mov 			ebx, barrierNum
					imul			ebx, 4
					.repeat		
						sub			ebx, 4	
						invoke		Rectangle, @hDCTemp, barrierX[ebx], barrierY[ebx], barrierXT[ebx], barrierYT[ebx]
					.until			ebx == 0

					;Ϊ�˱��������˸�����½�DC�еĻ��濽����������DC��
					invoke			BitBlt, _hDC, 30, 30, 410, 410, @hDCTemp, 30, 30, SRCCOPY
					;ɾ��DC
					invoke			DeleteDC, @hDCTemp	
					invoke SetTimer, hWinMain, ID_TIMER, dwTime, NULL

					ret
_DrawBorad			endp			


;***************************************************************************************
;
;���ڻ滭�Ҳ���Ϣ��ʾ�߿�
;
;***************************************************************************************
_DrawMsgBorder		proc			_hDC
					invoke			SelectObject, _hDC, hBorderPen
					invoke			Rectangle, _hDC, 430, 10, 610 , 30		;�Ϻ���
					invoke			Rectangle, _hDC, 430, 210, 610 , 230	;�к���
					invoke			Rectangle, _hDC, 430, 410, 610 , 430	;�ײ�����
					invoke			Rectangle, _hDC, 610, 10, 630 , 430		;�Ҳ�����
					ret
_DrawMsgBorder		endp

;***************************************************************************************
;
;���ز˵�����
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
;��ʾ�˵�����
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
;��ʾѡ��ģʽ����
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
;����ѡ��ģʽ����
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
;��ʾ����Ϸ�Ĵ���
;
;***************************************************************************************
_showGameWindow		proc			hWnd
					local			@stRect:RECT
					
					;��Ҫ�ػ�ľ�������
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
;��������Ϸ�Ĵ���
;
;***************************************************************************************

_hideGameWindow		proc			hWnd
					local			@stRect:RECT
					;��Ҫ�ػ�ľ�������
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
;��Ϣ���������������Ϣ
;
;***************************************************************************************
_ProcWinMain		proc			uses ebx edi esi hWnd, uMsg, wParam, lParam
					local			@stPS:PAINTSTRUCT
					local			@stRect:RECT
					local			@hDC, @hBMP
					;��Ҫ�ػ�ľ�������
					mov @stRect.left, 30
					mov @stRect.right, 410
					mov @stRect.top, 30
					mov @stRect.bottom, 410
					.if				uMsg == WM_TIMER										;��ʱ����ʱ
									invoke 	_UpdatePosition, hWnd
									;������Ծ�ȷ�����ػ�����ʹ��Ч�ʸ���
									invoke 	InvalidateRect, hWnd, addr @stRect, FALSE		;��ʱ����ʱ,�����ػ�������ǲ�ˢ�½���
					.elseif			uMsg == WM_PAINT
									invoke BeginPaint, hWnd, addr @stPS
									mov @hDC, eax
									.IF	menuFlag == 1
										invoke _DrawBorad, @hDC									;���û滭���溯��
										invoke _DrawMsgBorder, @hDC								;�滭�Ҳ�߿�
									.ELSE 
										invoke			SelectObject, @hDC, hWhiteBrush
										invoke			PatBlt, @hDC, 0, 0, 656, 479, PATCOPY
									.ENDIF
									invoke EndPaint, hWnd, addr @stPS
					.elseif			uMsg == WM_CREATE
									; invoke SetTimer, hWnd, ID_TIMER, dwTime, NULL			;���ö�ʱ��
									
									;����������ʾ����
									invoke	CreateWindowEx, ES_LEFT,\
											offset szEdit, offset szClassName,\
											WS_CHILD or WS_VISIBLE,\
											240, 20, 200, 100,\
											hWnd, 99, hInstance, NULL 
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_big, NULL

									;����Ϸ��ť
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset szNewGame,\
											WS_CHILD or WS_VISIBLE or BS_FLAT,\
											270, 130, 100, 50,\
											hWnd, ID_NewGame, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;����ģʽ��ť
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset szSetModule,\
											WS_CHILD or WS_VISIBLE or BS_FLAT,\
											270, 190, 100, 50,\
											hWnd, ID_SetModule,	 hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;������ť
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset szHelp,\
											WS_CHILD or WS_VISIBLE or BS_FLAT,\
											270, 250, 100, 50,\
											hWnd, ID_HELP, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL
									
									;���ڰ�ť
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset szAbout,\
											WS_CHILD or WS_VISIBLE or BS_FLAT,\
											270, 310, 100, 50,\
											hWnd, ID_About, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;������ť
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
									
									;����ģʽ���ð�ť
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset dwMODULESTARTER,\
											WS_CHILD or BS_FLAT,\
											270, 130, 100, 50,\
											hWnd, ID_MODULESTARTER, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;��ģʽ���ð�ť
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset dwMODULESIMPLE,\
											WS_CHILD or BS_FLAT,\
											270, 190, 100, 50,\
											hWnd, ID_MODULESIMPLE, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;����ģʽ���ð�ť
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset dwMODULEADVANCED,\
											WS_CHILD or BS_FLAT,\
											270, 250, 100, 50,\
											hWnd, ID_MODULEADVANCED, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;����ģʽ���ð�ť
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
									
									;����������ʾ����
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

									;����ģʽ��ʾ����
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

									;�����ٶ���ʾ����
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


									;��ͣ/��ʼ/���水ť
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
									.if	eax == VK_UP													;w����ʾ����
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_UP,0		
									.elseif eax == VK_DOWN												;s����ʾ����
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_DOWN,0
									.elseif eax == VK_LEFT												;a����ʾ����
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_LEFT,0
									.elseif eax == VK_RIGHT												;d����ʾ����
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_RIGHT,0
									.elseif	eax == 87													;w����ʾ����
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_UP,0		
									.elseif eax == 83													;s����ʾ����
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_DOWN,0
									.elseif eax == 65													;a����ʾ����
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_LEFT,0
									.elseif eax == 68													;d����ʾ����
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_RIGHT,0
									.endif

									;********************************�������ɼ���
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
									.if	eax == ID_UP && ButtonFlag < 2 && esi != 2					;�����߲���ת���෴����
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
											.IF	ButtonFlag == 2		;�ؿ���Ϸ
												mov 	ButtonFlag, 0
												mov		continueBtnFlag, 0
												invoke SendMessage,hButton,WM_SETTEXT,0,addr szButton_Stop ;��ť��ʾ��ͣ
											.ENDIF
											invoke	_hideGameWindow, hWnd
											invoke	_showMenuWindow, hWnd
											invoke 	KillTimer, hWnd, ID_TIMER
									.elseif	eax == ID_MODULESTARTER		;���ż��Ѷ�										;�����ٶ��л���ť
											mov	dwModuleflag, 0
											mov dwTime, 500				;�������ö�ʱ�����
											invoke	_hideModuleWindow, hWnd
											invoke	_showMenuWindow, hWnd
									.elseif	eax == ID_MODULESIMPLE		;���Ѷ�	
											mov dwModuleflag, 1
											mov dwTime, 300
											invoke	_hideModuleWindow, hWnd
											invoke	_showMenuWindow, hWnd
									.elseif eax == ID_MODULEADVANCED	;�����Ѷ�
											mov dwModuleflag, 2
											invoke	_hideModuleWindow, hWnd
											invoke	_showMenuWindow, hWnd
									.elseif	eax == ID_MODULEHARD		;�����Ѷ�
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
									.elseif	eax == ID_NewGame		;����Ϸ
											mov		continueBtnFlag, 1
											mov 	ButtonFlag, 1
											invoke 	_Init
											mov		menuFlag, 1	
											invoke	_hideMenuWindow, hWnd
											invoke	_showGameWindow, hWnd
											invoke 	SetTimer, hWnd, ID_TIMER, dwTime, NULL	;���ö�ʱ��
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
											invoke SetFocus, hWnd										;��Ϸ�������ô��ڻ�ý���
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
;ע�Ტ�������ں���
;
;***************************************************************************************
_WinMain			proc
					local			@stWndClass:WNDCLASSEX
					local			@stMsg:MSG
					invoke			GetModuleHandle, NULL
					mov				hInstance, eax

					;ע�ᴰ����
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

					;��������ʾ����
					invoke			CreateWindowEx,NULL, \
									offset szClassName, offset szClassName,\
									 WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX,\
									CW_USEDEFAULT, CW_USEDEFAULT, \
									656, 479,\
									NULL, NULL, hInstance, NULL
					mov				hWinMain, eax
					invoke			ShowWindow, hWinMain, SW_SHOWNORMAL
					invoke			UpdateWindow, hWinMain

					;��Ϣѭ��
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
;���������������
;
;***************************************************************************************
main				proc

					;���ó�ʼ��������ʼ���Ĵ�����ֵ
					invoke			_Init
					invoke			_createFont
					invoke			_createPens				

					;���ô���ע�ắ��
					call			_WinMain
					invoke			ExitProcess, NULL
main				endp
end					main
