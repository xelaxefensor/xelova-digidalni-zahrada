section .data
a dq 0 ; proměnná a (64 bitů)
b dq 0 ; proměnná b (64 bitů)
c dq 0 ; proměnná c (64 bitů)

section .text
global _start

_start:
    ; Načtení proměnné a do registru rax
    mov rax, [a]           ; rax = a
    imul rax, 11           ; rax = 11 * a
    mov rbx, 8             ; rbx = 8 (dělenec)
    cqo                    ; rozšíření rax do rdx:rax pro dělení
    idiv rbx               ; rax = rax / 8 (výsledek dělení)

    ; Uložení mezivýsledku do registru rcx
    mov rcx, rax           ; rcx = 11 * a / 8

    ; Načtení proměnné b do registru rax
    mov rax, [b]           ; rax = b
    imul rax, 5            ; rax = 5 * b

    ; Odečtení 5 * b od mezivýsledku
    sub rcx, rax           ; rcx = rcx - rax (11 * a / 8 - 5 * b)

    ; Uložení výsledku do proměnné c
    mov [c], rcx           ; c = rcx

    ; Ukončení programu
    mov rax, 60            ; syscall číslo 60 (exit)
    xor rdi, rdi           ; návratový kód 0
    syscall
