.386

code segment use16
    old     dw 2 dup(0)
new16h:
    cmp     ah, 00h
    jz      replace
    cmp     ah, 10h
    je      replace
    jmp     dword ptr old

replace:
    push    bp
    mov     bp, sp
    pushf
    call    dword ptr old
    cli

    cmp     al, 'A'
    jl      exit
    cmp     al, 'Z'
    jg      exit
    add     al, 32

exit:
    pop bp
    iret

start:
    xor     ax, ax
    mov     ds, ax

    mov     ax, ds:[16h * 4]
    mov     old, ax
	mov		fs:[200h * 4], ax

    mov     ax, ds:[16h * 4 + 2]
    mov     old + 2, ax
	mov		fs:[200h * 4 + 2], ax

    cli
    mov     word ptr ds:[16h * 4], offset new16h
    mov     ds:[16h * 4 + 2], cs
    sti

    mov     dx, offset start + 10h
    shr     dx, 4
    add     dx, 10h

    mov     al, 0
    mov     ah, 31h
    int     21h

code ends

stack segment use16 stack
    db 500 dup(0)
stack ends

end start
