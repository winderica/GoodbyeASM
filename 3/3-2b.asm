.386

; public _func1
public _func2
public _func3
public _func4
public _func5
public _calc

extrn _shop:byte
extrn _print:near

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

_STACK segment use16 stack
    db 500 dup(0)
_STACK ends

_DATA segment use16 word public 'DATA'
    item_number             equ 30
    not_found_hint          db  'Item not found, please input again', 13, 10, '$'
    item_hint               db  'Input item name:', 13, 10, '$'
    calc_fail_hint          db  'Error: Divide by zero!', 13, 10, '$'
    calced_all_hint         db  'Calced suggestion level of all items successfully!', 13, 10, '$'
    ranked_all_hint         db  'Ranked suggestion level of all items successfully!', 13, 10, '$'
    invalid_value_hint      db  'Invalid value! Input again.', 13, 10, '$'
    info_header_2           db  'name', 9, 'discnt', 9, 'inPrice', 9, 'price', 9, 'inNum', 9, 'outNum', 9, 'suggestion', 9, 'rank', 13, 10, '$'
    info_name               db  'name: ', '$'
    info_discount           db  'discount: ', '$'
    info_in_price           db  'inPrice: ', '$'
    info_price              db  'price: ', '$'
    info_in_num             db  'inNum: ', '$'
    info_out_num            db  'outNum: ', '$'
    input_item              db  20
                            db  0
    input_item_value        db  20 dup(0)
    input_discount          db  3
                            db  0
    input_discount_value    db  3 dup(0)
    input_in_price          db  5
                            db  0
    input_in_price_value    db  5 dup(0)
    input_price             db  5
                            db  0
    input_price_value       db  5 dup(0)
    input_in_num            db  5
                            db  0
    input_in_num_value      db  5 dup(0)
    input_out_num           db  5
                            db  0
    input_out_num_value     db  5 dup(0)
    to_sort                 dw  item_number dup(0)
    rank                    db  item_number dup(0)
_DATA ends

_TEXT segment use16 byte public 'CODE'
    assume cs:_TEXT, ds:_DATA, ss:_STACK


_func2:
    call    set_item
    ret
_func3:
    mov     dx, offset _shop
    call    calc_all
    print   calced_all_hint
    ret
_func4:
    mov     dx, offset _shop
    mov     di, offset to_sort
    mov     cx, offset rank
    call    calc_rank
    print   ranked_all_hint
    ret
_func5:
    mov     dx, offset _shop
    mov     di, offset to_sort
    mov     cx, offset rank
    call    print_all
    ret

find proc
    print   item_hint
    input   input_item
    mov     bx, offset input_item_value
    cmp     byte ptr[bx], 13
    je      return_enter
query:
    mov     si, offset _shop
    mov     bx, offset input_item_value
    mov     cx, 0
loop_item:
    mov     dx, si
check_item:
    mov     al, [bx]
    cmp     byte ptr[si], al
    jne     next_item
    inc     si
    inc     bx
    cmp     byte ptr[bx], 13
    je      return_found
    jmp     check_item
next_item:
    add     dx, 21
    mov     si, dx
    mov     bx, offset input_item_value
    add     cx, 1
    cmp     cx, item_number
    je      return_not_found
    jmp     loop_item
return_enter:
    mov     ax, 0
    ret
return_found:
    mov     ax, 1
    ret
return_not_found:
    mov     ax, 2
    ret
find endp

set_item proc
    pusha
    call    find
    cmp     ax, 0
    je      return
    cmp     ax, 1
    je      set_item_found
    jmp     set_item_not_found
set_item_not_found:
    print   not_found_hint
    call    set_item
    jmp     return
set_item_found:
    call    calc_suggestion_level
    print   info_name
    mov     si, dx
    push    si
    call    _print
    pop     si
    print_newline
    add     si, 10
set_discount:
    print   info_discount
    movzx   ax, byte ptr[si]
    call    print_number
    input   input_discount
    mov     ax, offset input_discount_value
    mov     bx, si
    mov     cl, 0 ; is byte ptr
    mov     ch, 0 ; can be zero
    call    set_value
    cmp     dx, 0
    je      set_discount
    print_newline
    add     si, 1
set_in_price:
    print   info_in_price
    mov     ax, [si]
    call    print_number
    input   input_in_price
    mov     ax, offset input_in_price_value
    mov     bx, si
    mov     cl, 1 ; is byte ptr
    mov     ch, 0 ; can be zero
    call    set_value
    cmp     dx, 0
    je      set_in_price
    print_newline
    add     si, 2
set_price:
    print   info_price
    mov     ax, [si]
    call    print_number
    input   input_price
    mov     ax, offset input_price_value
    mov     bx, si
    mov     cl, 1 ; is byte ptr
    mov     ch, 0 ; can be zero
    call    set_value
    cmp     dx, 0
    je      set_price
    print_newline
    add     si, 2
set_in_num:
    print   info_in_num
    mov     ax, [si]
    call    print_number
    input   input_in_num
    mov     ax, offset input_in_num_value
    mov     bx, si
    mov     cl, 1 ; is byte ptr
    mov     ch, 0 ; can be zero
    call    set_value
    cmp     dx, 0
    je      set_in_num
    print_newline
    add     si, 2
set_out_num:
    print   info_out_num
    mov     ax, [si]
    call    print_number
    input   input_out_num
    mov     ax, offset input_out_num_value
    mov     bx, si
    mov     cl, 1 ; is byte ptr
    mov     ch, 1 ; can be zero
    call    set_value
    cmp     dx, 0
    je      set_out_num
    print_newline
    jmp     return
set_item endp

set_value proc
    pusha
    mov     si, ax
    mov     dx, 0
    cmp     byte ptr[si], 13
    je      empty_value
loop_set_value:
    cmp     byte ptr[si], 13
    je      valid_value
    cmp     byte ptr[si], '0'
    jl      invalid_value
    cmp     byte ptr[si], '9'
    jg      invalid_value
    imul    dx, 10
    add     dl, byte ptr[si]
    sub     dx, '0'
    inc     si
    jmp     loop_set_value
invalid_value:
    popa
    print   invalid_value_hint
    mov     dx, 0
    ret
valid_value:
    cmp     dx, 0
    jne     set_valid_value
    cmp     ch, 1
    jne     invalid_value
set_valid_value:
    cmp     cl, 0
    je      set_byte_value
    jmp     set_word_value
set_byte_value:
    mov     byte ptr[bx], dl
    jmp     empty_value
set_word_value:
    mov     [bx], dx
empty_value:
    popa
    mov     dx, 1
    ret
set_value endp

print_number proc
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

calc_all proc
    pusha
    mov     cx, item_number
loop_calc_all:
    call    calc_suggestion_level
    add     dx, 21
    loop    loop_calc_all
    popa
    ret
calc_all endp

calc_rank proc
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

print_all proc
    pusha
    call    calc_rank
    print   info_header_2
    mov     bx, 0
    mov     si, dx
    mov     di, cx
loop_print_all:
    push    si
    call    _print
    pop     si
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

_calc proc
    mov     dx, ax
    call    calc_suggestion_level
    ret
_calc endp

calc_suggestion_level proc
    pusha
    mov     si, dx
    add     si, 10
    movzx   ax, byte ptr[si]
    inc     si
    imul    ax, [si+2]
    cwd
    mov     dx, 0
    mov     bx, 10
    idiv    bx
    mov     bx, ax
    mov     ax, [si]
    imul    ax, 1280
    cwd
    mov     dx, 0
    cmp     bx, 0
    je      calc_failed
    idiv    bx
    mov     cx, ax
    mov     bx, [si+4]
    mov     ax, [si+6]
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
    mov     [si+8], cx
    popa
    ret
calc_failed:
    print   calc_fail_hint
    popa
    ret
calc_suggestion_level endp

return:
    popa
    ret
_TEXT ends
end