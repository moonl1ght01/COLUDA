[BITS 16]
[ORG 0x7C00]

start:
    ; Messaggio di avvio del bootloader
    mov si, msg
.print:
    lodsb
    or al, al
    jz load_kernel
    mov ah, 0x0e
    int 0x10
    jmp .print

load_kernel:
    ; carica 15 settori (1 = boot, 2-16 = kernel)
    mov ah, 0x02        ; funzione BIOS: leggere settori
    mov al, 15          ; quanti settori leggere
    mov ch, 0           ; cilindro
    mov cl, 2           ; settore iniziale (2)
    mov dh, 0           ; testina
    mov dl, 0           ; drive (0 = floppy)
    mov bx, 0x1000      ; destinazione in RAM
    mov es, bx
    xor bx, bx          ; offset 0x0000
    int 0x13            ; BIOS: legge i settori

    jmp 0x1000:0x0000   ; salta all'inizio del kernel

msg: db "Bootloader OK. Avvio kernel...", 0

; Padding a 510 byte
times 510 - ($ - $$) db 0
dw 0xAA55
