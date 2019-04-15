public print_number, calc_all, calc_rank, print_all, calc_suggestion_level

print_newline macro
    push    ax
    push    dx
    mov     ah, 02h
    mov     dl, 13
    int     21h
    mov     ah, 02h
    mov     dl, 10
    int     21h
    pop     dx
    pop     ax
endm

print macro string
    push    ax
    push    dx
    mov     dx, offset string
    mov     ah, 09h
    int     21h
    pop     dx
    pop     ax
endm

print_address macro address
    push    ax
    push    dx
    mov     dx, address
    mov     ah, 09h
    int     21h
    pop     dx
    pop     ax
endm

print_char macro char
    push    ax
    push    dx
    mov     ah, 02h
    mov     dl, char
    int     21h
    pop     dx
    pop     ax
endm

input macro string
    push    ax
    push    dx
    mov     dx, offset string
    mov     ah, 0Ah
    int     21h
    print_newline
    pop     dx
    pop     ax
endm

.386

stack segment use16 stack
    db 500 dup(0)
stack ends

data segment use16 para public 'data'
    item_number             equ 30
    calc_fail_hint          db  'Error: Divide by zero!', 13, 10, '$'
    info_header_2           db  'name', 9, 'discnt', 9, 'inPrice', 9, 'price', 9, 'inNum', 9, 'outNum', 9, 'suggestion', 9, 'rank', 13, 10, '$'
data ends

code segment use16 para public 'code'
    assume cs:code, ds:data, ss:stack

print_number proc far
    pusha
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
    print_char dl
    loop    loop_print_number
    print_char 9
    popa
    ret
print_number endp

calc_all proc far
    pusha
    mov     cx, item_number
loop_calc_all:
    call    calc_suggestion_level
    add     dx, 21
    loop    loop_calc_all
    popa
    ret
calc_all endp

calc_rank proc far
    pusha
    call    calc_all
    push    di
    push    dx
    push    cx
    mov     bx, 0
    mov     si, dx
loop_set_array:
    mov     [di + bx], si
    add     si, 21
    add     bx, 2
    cmp     bx, item_number * 2
    je      loop_sort
    jmp     loop_set_array
loop_sort:
    mov     dx, 0
    mov     bx, 0
compare:
    mov     si, [di + bx]
    add     si, 19
    mov     ax, [si]
    mov     si, [di + bx + 2]
    add     si, 19
    mov     cx, [si]
    add     bx, 2
    cmp     bx, item_number * 2
    je      judge_loop_sort
    cmp     ax, cx
    jge     compare
    mov     dx, 1
    mov     ax, [di + bx]
    push    ax
    mov     ax, [di + bx - 2]
    mov     [di + bx], ax
    pop     ax
    mov     [di + bx - 2], ax
    jmp     compare
judge_loop_sort:
    cmp     dx, 1
    je      loop_sort
    pop     di ; rank
    pop     si ; items
    pop     bx ; to_sort
    mov     dx, 0
loop_call_set_rank:
    call    set_rank_func
    inc     dx
    cmp     dx, item_number
    jne     loop_call_set_rank
    popa
    ret
calc_rank endp

set_rank_func proc
    pusha
    push    dx
    mov     cx, 1
    imul    dx, 21
    add     si, dx
loop_set_rank:
    mov     ax, [si + 19]
    mov     dx, [bx]
    push    bx
    mov     bx, dx
    mov     dx, [bx + 19]
    pop     bx
    cmp     ax, dx
    je      set_rank
    inc     cx
    add     bx, 2
    jmp     loop_set_rank
set_rank:
    pop     bx
    mov     [di + bx], cl
    popa
    ret
set_rank_func endp

print_all proc far
    pusha
    call    calc_rank
    print   info_header_2
    mov     bx, 0
    mov     si, dx
    mov     di, cx
loop_print_all:
    print_address si
    print_char 9
    movzx   ax, byte ptr[si + 10]
    call    print_number
    mov     ax, [si + 11]
    call    print_number
    mov     ax, [si + 13]
    call    print_number
    mov     ax, [si + 15]
    call    print_number
    mov     ax, [si + 17]
    call    print_number
    mov     ax, [si + 19]
    call    print_number
    movzx   ax, byte ptr[di + bx]
    call    print_number
    print_newline
    inc     bx
    add     si, 21
    cmp     bx, item_number
    jne     loop_print_all
    popa
    ret
print_all endp

calc_suggestion_level proc far
    pusha
    mov     si, dx
    add     si, 10
    movzx   ax, byte ptr[si]
    inc     si
    imul    ax, word ptr[si+2]
    cwd
    mov     dx, 0
    mov     bx, 10
    idiv    bx
    mov     bx, ax
    mov     ax, word ptr[si]
    imul    ax, 1280
    cwd
    mov     dx, 0
    cmp     bx, 0
    je      calc_failed
    idiv    bx
    mov     cx, ax
    mov     bx, word ptr[si+4]
    mov     ax, word ptr[si+6]
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
    mov     word ptr[si+8], cx
    popa
    ret
calc_failed:
    print   calc_fail_hint
    popa
    ret
calc_suggestion_level endp

code ends
end
