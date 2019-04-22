.386

print macro string
    push    ax
    push    dx
    mov     dx, offset string
    mov     ah, 09h
    int     21h
    pop     dx
    pop     ax
endm

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

atoi macro addr
local return, convert
    push    eax
    push    eax
    push    ebx
    push    ecx
    mov     eax, 00h
    mov     ecx, 00h
    mov     cx, addr
convert:
    cmp     [ecx], byte ptr 0dh
    je      return

    mov     ebx, 0ah
    mul     ebx
    mov     bl,    [ecx]
    add     eax, ebx
    sub     eax, 30h
    inc     cx

    jmp     convert
return:
    mov     [esp+0ch], eax
    pop     ecx
    pop     ebx
    pop     eax
endm

itoa macro addr, reg
local pushloop, poploop, letter, set_value
    push    reg
    push    ax
    push    bx
    push    cx
    push    dx
    mov     ax, reg
    mov     bx, 16
    mov     cx, 0
pushloop:
    mov     dx, 0
    div     bx
    cmp     dx, 9
    jg      letter
    add     dl, 48
    jmp     push_value
letter:
    add     dl, 87
push_value:
    push    dx
    inc     cx
    cmp     ax, 0
    jnz     pushloop

    mov     bx, addr
poploop:
    pop     dx

    mov     [bx], dl
    inc     bx
    loop    poploop

    mov     [bx], byte ptr '$'
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    pop     reg
endm

data segment use16
    hint            db  'Please input the address of CMOS:', 13, 10, '$'
    address         db  20
                    db  0
    address_value   db  20 dup(0)
data ends

stack segment use16 stack
    db 500 dup(0)
stack ends

code segment use16
    assume cs:code, ds:data, ss:stack
start:
    mov     ax, data
    mov     ds, ax
read_input:
    print   hint
    input   address
    cmp     address + 1, 0
    je      read_input

    atoi    <offset address_value>
    pop     ax

    out     70h, al
    mov     ax, 0
    in      al, 71h

    itoa    <offset address_value>, ax
    print   address_value

    mov     ah, 4ch
    int     21h

code ends
end start
