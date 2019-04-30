.386

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

stack segment use16 stack
    db 500 dup(0)
stack ends

data segment use16
    item_number             equ 30
    username_hint           db  'Input your username:', 13, 10, '$'
    password_hint           db  'Input your password:', 13, 10, '$'
    succeeded_hint          db  'Login succeeded', 13, 10, '$'
    failed_hint             db  'Login failed', 13, 10, '$'
    not_found_hint          db  'Item not found, please input again', 13, 10, '$'
    item_hint               db  'Input item name:', 13, 10, '$'
    level_hint              db  'Suggestion level is:', 13, 10, '$'
    calc_fail_hint          db  'Error: Divide by zero!', 13, 10, '$'
    func1_hint              db  '1. Query Item', 13, 10, '$'
    func2_hint              db  '2. Modify Item', 13, 10, '$'
    func3_hint              db  '3. Calculate Suggestion Rate', 13, 10, '$'
    func4_hint              db  '4. Calculate Suggestion Rank', 13, 10, '$'
    func5_hint              db  '5. Print All Goods', 13, 10, '$'
    func6_hint              db  '6. Exit', 13, 10, '$'
    select_hint             db  'Please input your selection:', 13, 10, '$'
    select_error_hint       db  'Error: invalid selection!', 13, 10, '$'
    calced_all_hint         db  'Calced suggestion level of all items successfully!', 13, 10, '$'
    ranked_all_hint         db  'Ranked suggestion level of all items successfully!', 13, 10, '$'
    invalid_value_hint      db  'Invalid value! Input again.', 13, 10, '$'
    info_header_1           db  'name', 9, 'discnt', 9, 'price', 9, 'inNum', 9, 'outNum', 9, 'suggestion', 13, 10, '$'
    info_header_2           db  'name', 9, 'discnt', 9, 'inPrice', 9, 'price', 9, 'inNum', 9, 'outNum', 9, 'suggestion', 9, 'rank', 13, 10, '$'
    info_name               db  'name: ', '$'
    info_discount           db  'discount: ', '$'
    info_in_price           db  'inPrice: ', '$'
    info_price              db  'price: ', '$'
    info_in_num             db  'inNum: ', '$'
    info_out_num            db  'outNum: ', '$'
    fake_username           db  'username', 0
    fake_password           db  'password', 0
    fake_username_2         db  'trdso`ld', 0
    fake_password_2         db  'rcqqumpf', 0
    input_username          db  20
                            db  0
    input_username_value    db  20 dup(0)
    input_password          db  20
                            db  0
    input_password_value    db  20 dup(0)
    input_item              db  20
                            db  0
    input_item_value        db  20 dup(0)
    input_selection         db  2
                            db  0
    input_selection_value   db  2 dup(0)
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
    shop_name               db  'shop', 13, 10, '$'
    items                   db  item_number - 3 dup('temp', 0, '$', 4 dup(0), 8, 15 xor 30, 0, 30, 0, 30, 0, 2, 0, ?, ?)
                            db  'pen', 0, '$', 5 dup(0), 10
                            dw  35 xor 56, 56, 70, 25, ?
                            db  'book', 0, '$', 4 dup(0), 9
                            dw  12 xor 30, 30, 25, 5, ?
                            db  'bag', 0, '$', 5 dup(0), 9
                            dw  40 xor 100, 100, 45, 5, ?
    to_sort                 dw  item_number dup(0)
    rank                    db  item_number dup(0)
    auth                    db  0
    address0                dw  login
    address1                dw  verify_username
    address2                dw  verify_password
data ends

code segment use16
    assume cs:code,ds:data,ss:stack
start:
    mov     ax, data
    mov     ds, ax
    mov     dx, 0
    jmp     address0

login:
    cmp     dx, 3
    je      exit
    print   shop_name
    print   username_hint
    input   input_username
    mov     bx, offset input_username + 2
    cmp     byte ptr[bx], 'q'
    je      exit
    cmp     byte ptr[bx], 13
    je      shop_main
    print   password_hint
    input   input_password
    jmp     address1

login_failed:
    print   failed_hint
    inc     dx
    jmp     address0

verify_username:
    mov     si, offset fake_username
    mov     di, offset fake_username_2
    mov     bx, offset input_username_value
check_username:
    mov     al, [bx]
    mov     cl, byte ptr[si]
    xor     cl, byte ptr[di]
    cmp     cl, al
    jne     login_failed
    inc     si
    inc     di
    inc     bx
    cmp     byte ptr[bx], 13
    jne     check_username
    cmp     byte ptr[si], 0
    jne     check_username
    jmp     address2

verify_password:
    mov     si, offset fake_password
    mov     di, offset fake_password_2
    mov     bx, offset input_password_value
check_password:
    cli
    mov     ah, 2ch
    int     21h
    push    dx

    call    nothing

    mov     ah, 2ch
    int     21h
    sti
    sub     dx, [esp]
    cmp     dx, 1
    jg      exit
    pop     dx

    mov     al, [bx]
    mov     cl, byte ptr[si]
    call    nothing
    xor     cl, byte ptr[di]

    cmp     cl, al
    jne     login_failed
    inc     si
    inc     di
    inc     bx
    call    nothing    
    cmp     byte ptr[bx], 13
    jne     check_password
    cmp     byte ptr[si], 0
    jne     check_password
    jmp     login_succeed

login_succeed:
    print   succeeded_hint
    call    recover_value
    mov     auth, 1
    jmp     shop_main

shop_main:
    call    show_menu
    jmp     shop_main

nothing proc
    pusha
    mov     al, [bx]
    nop
    nop
    nop
    mov     cl, byte ptr[si]
    xor     cl, byte ptr[di]
nothing_label:
    add     dx, 21
    mov     si, dx
    nop
    nop
    nop
    mov     bx, offset input_item_value
    add     cx, 1
    cmp     cx, item_number
    nop
    nop
    nop
    jle     nothing_label
    cmp     cl, al
    jne     return
    cmp     byte ptr[bx], 13
    jne     return
    nop
    nop
    nop
    cmp     byte ptr[si], 0
    jne     return
    inc     si
    inc     di
    inc     bx
    nop
    nop
    nop
    jmp     return
nothing endp

show_menu proc
    cmp     auth, 1
    je      show_full_menu
    jmp     show_partial_menu
show_full_menu:
    print   func1_hint
    print   func2_hint
    print   func3_hint
    print   func4_hint
    print   func5_hint
    print   func6_hint
    print   select_hint
    input   input_selection
    cmp     input_selection_value, 31h
    je      call_func1
    cmp     input_selection_value, 32h
    je      call_func2
    cmp     input_selection_value, 33h
    je      call_func3
    cmp     input_selection_value, 34h
    je      call_func4
    cmp     input_selection_value, 35h
    je      call_func5
    cmp     input_selection_value, 36h
    je      call_func6
    print   select_error_hint
    ret
show_partial_menu:
    print   func1_hint
    print   func6_hint
    print   select_hint
    input   input_selection
    cmp     input_selection_value, 31h
    je      call_func1
    cmp     input_selection_value, 36h
    je      call_func6
    print   select_error_hint
    ret
call_func1:
    call    query_item
    ret
call_func2:
    call    set_item
    ret
call_func3:
    call    calc_all
    print   calced_all_hint
    ret
call_func4:
    call    calc_rank
    print   ranked_all_hint
    ret
call_func5:
    call    print_all
    ret
call_func6:
    call    exit
show_menu endp

recover_value proc
    pusha
    mov     bx, 0
    mov     si, offset items
loop_recover_value:
    mov     ax, [si + 11]
    xor     ax, [si + 13]
    mov     word ptr[si + 11], ax
    inc     bx
    add     si, 21
    cmp     bx, item_number
    je      return
    jmp     loop_recover_value
recover_value endp

find proc
    print   item_hint
    input   input_item
    mov     bx, offset input_item_value
    cmp     byte ptr[bx], 13
    je      return_enter
query:
    mov     si, offset items
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

query_item proc
    pusha
    call    find
    cmp     ax, 0
    je      return
    cmp     ax, 1
    je      item_found
    jmp     item_not_found
item_not_found:
    print   not_found_hint
    call    query_item
    jmp     return
item_found:
    call    calc_suggestion_level
    print   info_header_1
    mov     si, dx
    print_address si
    print_char 9
    movzx   ax, byte ptr[si + 10]
    call    print_number
    mov     ax, [si + 13]
    call    print_number
    mov     ax, [si + 15]
    call    print_number
    mov     ax, [si + 17]
    call    print_number
    mov     ax, [si + 19]
    call    print_number
    print_newline
    jmp     return
query_item endp

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
    jmp     return
print_number endp

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
    print_address si
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

calc_all proc
    pusha
    mov     dx, offset items
    mov     cx, item_number
loop_calc_all:
    call    calc_suggestion_level
    add     dx, 21
    loop    loop_calc_all
    jmp     return
calc_all endp

calc_rank proc
    pusha
    call    calc_all
    mov     bx, 0
    mov     si, offset items
    mov     di, offset to_sort
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
    mov     di, offset rank
    mov     si, offset items
    mov     bx, offset to_sort
    mov     dx, 0
loop_call_set_rank:
    call    set_rank_func
    inc     dx
    cmp     dx, item_number
    jne     loop_call_set_rank
    jmp     return
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
    mov     si, offset items
    mov     di, offset rank
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
    je      return
    jmp     loop_print_all
print_all endp

calc_suggestion_level proc
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
    jmp     return
calc_failed:
    print   calc_fail_hint
    jmp     return
calc_suggestion_level endp

exit proc
    mov     ah, 4ch
    int     21h
exit endp

return:
    popa
    ret
code ends
end start
