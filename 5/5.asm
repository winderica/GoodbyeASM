.386
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
include \masm32\include\comctl32.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\comctl32.lib

WinMain     proto :dword, :dword, :dword, :dword
WndProc     proto :dword, :dword, :dword, :dword
PrintAll    proto :dword
Int2String  proto :word

Item struct
    itemName    db 10 dup(0)
    discount    dw 0
    inPrice     dw 0
    price       dw 0
    inNum       dw 0
    outNum      dw 0
    suggestion  dw 0
Item ends

.data
    H_INSTANCE          dd  0
    COMMAND_LINE        dd  0
    MAIN_WINDOW         dd  0
    itemNumber          equ 30
    ClassName           db  'WindowsClass', 0
    AppName             db  'My Shop', 0
    MenuName            db  'SysMenu', 0
    AboutMsg            db  'Developed by CS1702 ZhangChengRu', 0
    items               Item <'pen', 10, 35, 56, 70, 25, 0>
                        Item <'book', 9, 12, 30, 25, 5, 0>
                        Item <'bag', 9, 40, 100, 45, 5, 0>
                        Item itemNumber - 3 dup(<'temp', 8, 15, 30, 30, 2, 0>)
    itoabuf             db  100 dup(0)
    nameHeader          db  'name', 0
    discountHeader      db  'discount', 0
    inPriceHeader       db  'inPrice', 0
    priceHeader         db  'price', 0
    inNumHeader         db  'inNum', 0
    outNumHeader        db  'outNum', 0
    suggestionHeader    db  'suggestion', 0
    reprint             dw  0

.code
start:
    invoke  GetModuleHandle,
            NULL
    mov     H_INSTANCE, eax
    invoke  GetCommandLine
    mov     COMMAND_LINE, eax
    invoke  WinMain,
            H_INSTANCE,
            NULL,
            COMMAND_LINE,
            SW_SHOWDEFAULT
    invoke  ExitProcess,
            eax

WinMain proc hInstance:dword, hPrevInstance:dword, lpCmdLine:dword, nShowindowClassmd:dword
    local   windowClass:WNDCLASSEX
    local   message:MSG

    invoke  InitCommonControls
    mov     windowClass.cbSize, sizeof WNDCLASSEX
    mov     windowClass.style, CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNWINDOW
    mov     windowClass.lpfnWndProc, offset WndProc
    mov     windowClass.cbClsExtra, 0
    mov     windowClass.cbWndExtra, 0
    push    hInstance
    pop     windowClass.hInstance
    mov     windowClass.hbrBackground, COLOR_WINDOW + 1
    mov     windowClass.lpszMenuName, NULL
    mov     windowClass.lpszClassName, offset ClassName
    invoke  LoadIcon,
            NULL,
            IDI_APPLICATION
    mov     windowClass.hIcon, eax
    mov     windowClass.hIconSm, 0
    invoke  LoadCursor,
            NULL,
            IDC_ARROW
    mov     windowClass.hCursor, eax
    invoke  RegisterClassEx,
            addr windowClass
    invoke  CreateWindowEx,
            NULL,
            addr ClassName,
            addr AppName,
            WS_OVERLAPPEDWINDOW,
            CW_USEDEFAULT,
            CW_USEDEFAULT,
            CW_USEDEFAULT,
            CW_USEDEFAULT,
            NULL,
            NULL,
            hInstance,
            NULL
    mov     MAIN_WINDOW, eax
    invoke  LoadMenu, hInstance, 600
    invoke  SetMenu, MAIN_WINDOW, eax
    invoke  ShowWindow,
            MAIN_WINDOW,
            SW_SHOWNORMAL
    invoke  UpdateWindow,
            MAIN_WINDOW

messageLoop:
    invoke  GetMessage,
            addr message,
            NULL,
            0,
            0
    cmp     eax, 0
    je      exitWinMain
    invoke  TranslateMessage,
            addr message
    invoke  DispatchMessage,
            addr message
    jmp     messageLoop
exitWinMain:
    mov     eax, message.wParam
    ret
WinMain endp


WndProc proc hWnd:dword, uMsg:dword, wParam:dword, lParam:dword
    .if uMsg == WM_DESTROY
        invoke  PostQuitMessage, NULL
        ret
    .elseif uMsg == WM_COMMAND
        .if wParam == 10001
            invoke  SendMessage,
                    hWnd,
                    WM_CLOSE,
                    0,
                    0
        .elseif wParam == 20002
            mov     ebx, offset reprint
            mov     word ptr[ebx], 1
            invoke  PrintAll,
                    hWnd
        .elseif wParam == 20001
            call    CalcAll
        .elseif wParam == 30001
            invoke  MessageBox,
                    hWnd,
                    ADDR AboutMsg,
                    ADDR AppName,
                    MB_OK
        .endif
    .elseif uMsg == WM_PAINT
        mov     ebx, offset reprint
        cmp     word ptr[ebx], 0
        jz      next
        invoke  PrintAll,
                hWnd
    next:
        nop

    .endif
    invoke  DefWindowProc,
            hWnd,
            uMsg,
            wParam,
            lParam
    ret
WndProc endp

PrintAll proc hWnd:dword
    local   hdc:HDC
    local   vertical:dword
    local   current:dword

    pusha
    call    CalcAll
    mov     vertical, 10
    invoke  GetDC,
            hWnd
    mov     hdc, eax
    invoke  TextOut,
            hdc,
            10,
            vertical,
            addr nameHeader,
            4
    invoke  TextOut,
            hdc,
            110,
            vertical,
            addr discountHeader,
            8
    invoke  TextOut,
            hdc,
            210,
            vertical,
            addr inPriceHeader,
            7
    invoke  TextOut,
            hdc,
            310,
            vertical,
            addr priceHeader,
            5
    invoke  TextOut,
            hdc,
            410,
            vertical,
            addr inNumHeader,
            5
    invoke  TextOut,
            hdc,
            510,
            vertical,
            addr outNumHeader,
            6
    invoke  TextOut,
            hdc,
            610,
            vertical,
            addr suggestionHeader,
            10
    mov     current, 0
    add     vertical, 30
loop_print_all:
    mov     edx, current
    invoke  TextOut,
            hdc,
            10,
            vertical,
            addr items[edx].itemName,
            10
    mov     edx, current
    invoke  Int2String,
            items[edx].discount
    invoke  TextOut,
            hdc,
            110,
            vertical,
            addr itoabuf,
            5
    mov     edx, current
    invoke  Int2String,
            items[edx].inPrice
    invoke  TextOut,
            hdc,
            210,
            vertical,
            addr itoabuf,
            5
    mov     edx, current
    invoke  Int2String,
            items[edx].price
    invoke  TextOut,
            hdc,
            310,
            vertical,
            addr itoabuf,
            5
    mov     edx, current
    invoke  Int2String,
            items[edx].inNum
    invoke  TextOut,
            hdc,
            410,
            vertical,
            addr itoabuf,
            5
    mov     edx, current
    invoke  Int2String,
            items[edx].outNum
    invoke  TextOut,
            hdc,
            510,
            vertical,
            addr itoabuf,
            5
    mov     edx, current
    invoke  Int2String,
            items[edx].suggestion
    invoke  TextOut,
            hdc,
            610,
            vertical,
            addr itoabuf,
            5
    add     vertical, 30
    add     current, 22
    cmp     current, itemNumber * 22
    jne     loop_print_all
    popa
    ret
PrintAll endp

Int2String proc integer:word
    pusha
    mov     ax, integer
    mov     esi, offset itoabuf
    mov     ebx, 0
clear_buffer:
    mov     byte ptr[esi+ebx], 0
    inc     ebx
    cmp     ebx, 100
    jne     clear_buffer
    mov     bx, 10
    mov     cx, 0
loop_divide_number:
    mov     dx, 0
    div     bx
    add     dl, '0'
    push    dx
    inc     cx
    cmp     ax, 0
    jne     loop_divide_number
loop_print_number:
    pop     dx
    mov     byte ptr[esi], dl
    inc     esi
    dec     cx
    cmp     cx, 0
    jne     loop_print_number
    popa
    ret
Int2String endp

calcSuggestionLevel proc
    pusha
    mov     esi, edx
    mov     ax, items[esi].discount
    imul    ax, items[esi].price
    cwd
    mov     dx, 0
    mov     bx, 10
    idiv    bx
    mov     bx, ax
    mov     ax, items[esi].inPrice
    imul    ax, 1280
    cwd
    mov     dx, 0
    cmp     bx, 0
    je      calc_failed
    idiv    bx
    mov     cx, ax
    mov     bx, items[esi].inNum
    mov     ax, items[esi].outNum
    imul    ax, 1280
    cwd
    mov     dx, 0
    cmp     bx, 0
    je      calc_failed
    idiv    bx
    add     cx, ax
    mov     ax, cx
    cwd
    mov     dx, 0
    mov     bx, 10
    idiv    bx
    mov     cx, ax
    mov     items[esi].suggestion, cx
    popa
    ret
calc_failed:
    popa
    ret
calcSuggestionLevel endp

CalcAll proc
    pusha
    mov     edx, 0
loop_calc_all:
    call    calcSuggestionLevel
    add     edx, 22
    cmp     edx, itemNumber * 22
    jne     loop_calc_all
    popa
    ret
CalcAll endp

end start
