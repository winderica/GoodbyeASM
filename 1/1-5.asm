.386
stack segment use16 stack
    db 500 dup(0)
stack ends

data segment use16
    item_number     equ 30
    username_hint   db  'Input your username:', 13, 10, '$'
    password_hint   db  'Input your password:', 13, 10, '$'
    succeeded_hint  db  'Login succeeded', 13, 10, '$'
    failed_hint     db  'Login failed, please input again', 13, 10, '$'
    not_found_hint  db  'Item not found, please input again', 13, 10, '$'
    item_hint       db  'Input item name:', 13, 10, '$'
    level_hint      db  'Suggestion level is:', 13, 10, '$'
    calc_fail_hint  db  'Error: Divide by zero!', 13, 10, '$'
    boss_username   db  'zhangchengru', 0
    boss_password   db  'test', 0, 0
    input_username  db  20
                    db  21 dup(0)
    input_password  db  20
                    db  21 dup(0)
    input_item      db  20
                    db  21 dup(0)
    shop_name       db  'shop', 13, 10, '$'
    item_1          db  'pen', 7 dup(0), 10
                    dw  35, 56, 70, 25, ?
    item_2          db  'book', 6 dup(0), 9
                    dw  12, 30, 25, 5, ?
    item_temp       db  item_number - 2 dup('item_temp', 0, 8, 15, 0, 20, 0, 30, 0, 2, 0, ?, ?)
    auth            db  0
data ends

code segment use16
    assume cs:code,ds:data,ss:stack
start:
    mov     ax, data
    mov     ds, ax
    jmp     login

login:
    mov     dx, offset shop_name
    mov     ah, 09h
    int     21h
    mov     dx, offset username_hint
    mov     ah, 09h
    int     21h
    mov     ah, 0Ah
    mov     dx, offset input_username
    int     21h
    call    print_newline
    mov     bx, offset input_username + 2
    cmp     byte ptr[bx], 'q'
    je      exit
    cmp     byte ptr[bx], 13
    je      query_item
    mov     dx, offset password_hint
    mov     ah, 09h
    int     21h
    mov     ah, 0Ah
    mov     dx, offset input_password
    int     21h
    call    print_newline
    jmp     verify_username

print_newline proc
    mov     ah, 02h
    mov     dl, 13
    int     21h
    mov     ah, 02h
    mov     dl, 10
    int     21h
    ret
print_newline endp

login_failed:
    mov     dx, offset failed_hint
    mov     ah, 09h
    int     21h
    jmp     login

verify_username:
    mov     si, offset boss_username
    mov     bx, offset input_username + 2
check_username:
    mov     al, [bx]
    cmp     byte ptr[si], al
    jne     login_failed
    inc     si
    inc     bx
    cmp     byte ptr[bx], 13
    je      verify_password
    jmp     check_username

verify_password:
    mov     si, offset boss_password
    mov     bx, offset input_password + 2
check_password:
    mov     al, [bx]
    cmp     byte ptr[si], al
    jne     login_failed
    inc     si
    inc     bx
    cmp     byte ptr[bx], 13
    je      login_succeed
    jmp     check_password

login_succeed:
    mov     dx, offset succeeded_hint
    mov     ah, 09h
    int     21h
    mov     auth, 1
    jmp     query_item

query_item:
    mov     dx, offset item_hint
    mov     ah, 09h
    int     21h
    mov     ah, 0Ah
    mov     dx, offset input_item
    int     21h
    call    print_newline
    mov     bx, offset input_item + 2
    cmp     byte ptr[bx], 13
    je      login
query:
    mov     si, offset item_1
    mov     bx, offset input_item + 2
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
    je      item_found
    jmp     check_item
next_item:
    add     dx, 21
    mov     si, dx
    mov     bx, offset input_item + 2
    add     cx, 1
    cmp     cx, item_number
    je      item_not_found
    jmp     loop_item
item_found:
    cmp     auth, 1
    je      show_name
    jmp     calc_suggestion_level
item_not_found:
    mov     dx, offset not_found_hint
    mov     ah, 09h
    int     21h
    jmp     query_item
show_name:
    mov     byte ptr[bx], '$'
    mov     dx, offset input_item + 2
    mov     ah, 09h
    int     21h
    call    print_newline
    mov     auth, 0
    jmp     login
calc_suggestion_level:
get_discount:
    inc     si
    cmp     byte ptr[si], 0
    jne     calc_price
    jmp     get_discount
calc_failed:
    mov     dx, offset calc_fail_hint
    mov     ah, 09h
    int     21h
    jmp     query_item
calc_price:
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
    mov     dx, offset level_hint
    mov     ah, 09h
    int     21h
    cmp     cx, 100
    jg      show_a
    cmp     cx, 50
    jg      show_b
    cmp     cx, 10
    jg      show_c
    jmp     show_f
show_a:
    mov     ah, 02h
    mov     dl, 'A'
    int     21h
    call    print_newline
    jmp     login
show_b:
    mov     ah, 02h
    mov     dl, 'B'
    int     21h
    call    print_newline
    jmp     login
show_c:
    mov     ah, 02h
    mov     dl, 'C'
    int     21h
    call    print_newline
    jmp     login
show_f:
    mov     ah, 02h
    mov     dl, 'F'
    int     21h
    call    print_newline
    jmp     login
exit:
    mov     ah, 4ch
    int     21h

code ends
end start
