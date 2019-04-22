.386

stack segment use16 stack
    db 500 dup(0)
stack ends

code segment use16
start:
    cli
    xor     ax, ax
    mov     ds, ax

    mov     ax, fs:[200h * 4]
    cmp     ax, 0
    je      exit
    mov     ds:[16h * 4], ax

    mov     ax, fs:[200h * 4 + 2]
    mov     ds:[16h * 4 + 2], ax
    sti
exit:
    mov     ah, 4ch
    int     21h
code ends

end start

