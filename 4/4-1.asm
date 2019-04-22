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

print_char macro char
    push    ax
    push    dx
    mov     ah, 02h
    mov     dl, char
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

stack segment use16 stack
    db 500 dup(0)
stack ends

code segment use16
    assume cs:code, ss:stack
start:

    ; address in TD:
    ; 0008:0070
    ; 1140:f000
    ; use the system call
    mov     ah, 35h
    mov     al, 01h
    int     21h

    mov     ax, bx
    call    print_number

    mov     ax, es
    call    print_number

    mov     ah, 35h
    mov     al, 13h
    int     21h

    mov     ax, bx
    call    print_number

    mov     ax, es
    call    print_number

    ; read directly
    mov     eax, fs:[4h]
    call    print_number
    shr     eax, 16
    call    print_number

    mov     eax, fs:[4ch]
    call    print_number
    shr     eax, 16
    call    print_number

    mov     ah, 4ch
    int     21h

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
    print_newline
    popa
    ret
print_number endp

code ends
end start
