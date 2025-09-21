# COLUDA OS 
> Progetto creato per imparare a fare un sistema operativo nel chill

Utilizzero il progetto probabilmente come Capolavoro dell studente da pubblicare nella piattaforma [FUTURA](https://pnrr.istruzione.it/) 


## Giorno 1 
> Ricerca di risorse per poter imparare 

L'obiettivo che mi sono prefissato è semplice: Fare un sistema opeartivo utilizzando le mie abilità, evitando l'utilizzo dell'IA per creare direttamente codice (in quanto penso che rovini spesso e volentieri l'abilità logica dei programmatori)

Ho trovato una risorsa interessante: https://github.com/cfenollosa/os-tutorial Proverò ad iniziare sfruttando questo corso

ho trovato anche questa risorsa interessante: https://medium.com/%40nozerochathura/how-i-built-a-simple-operating-system-from-scratch-1df2e92fb61b

La prima cosa che viene fatta è, naturalmente, il setup dell'ambiente di lavoro, verrano utilizzati due tool:

1) QEMU (serve per fare macchine virtuali)
2) NASM (serve per compilare il linguaggio ASM)


Si fa così:
> https://www.qemu.org/download/
```sh
wget https://download.qemu.org/qemu-10.1.0.tar.xz
tar xvJf qemu-10.1.0.tar.xz
cd qemu-10.1.0
./configure
make
```

Dopo aver fatto ciò viene subito restituita una nozione interessante
> EN: When the computer boots, the BIOS doesn't know how to load the OS, so it delegates that task to the boot sector

> IT: Quando si avvia il computer, il BIOS non sa come caricare un sistema operativo, di conseguenza affida il compito ad un BOOT SELECTOR

questo ci fa capire che necessitiamo di un boot selector (ovvero un interfaccia che ci permette di selezionare l'os che vogliamo avviare)

il codice usato è:

```asm
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

```

e per provarlo dobbiamo fare i seguenti step (si fa in generale ogni volta che si compila qualcosa in ASM)

```sh
nasm -f bin <nomefile>.asm -o <nomefile>.bin
```
Poi otterremo il nostro file .bin che potremmo aprire grazie a qemu:

```sh
qemu-system-i386 -drive format=raw,file=boot.bin,if=floppy -nographic
```

per comodità ho deciso di fare un file bash che esegue tutto in automatico 

```sħ
#!/bin/bash

nasm -f bin boot.asm -o boot.bin
qemu-system-i386 -drive format=raw,file=boot.bin,if=floppy -nographic
```

E' molto facile e funzionale

però dato che voglio imparare Makefile, proverò a crearlo usando makefile, utilizzerò per imparare: https://makefiletutorial.com/

sono riuscito ad ottenere questo:

```makefile
NASM = nasm
NASM_FLAGS = -f bin

BOOT_SECTOR = boot.asm
BOOT_BIN = boot.bin

all: $(BOOT_BIN)

$(BOOT_BIN): $(BOOT_SECTOR)
	$(NASM) -f bin $(NASM_FLAGS) $(BOOT_SECTOR) -o $(BOOT_BIN)

clean:
	rm -f *.bin *.o *.elf

run: $(BOOT_BIN)
	qemu-system-i386 -drive format=raw,file=$(BOOT_BIN),if=floppy -nographic
```

Funziona Alla perfezione!


nel frattempo ho trovato una versione migliore per il nostro bootloander

```sh
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
```

direi che è arrivato il momento di creare un kernel

facendo zapping mi sono ritrovato in questo tutorial: https://wiki.osdev.org/Bare_Bones

Per iniziare ha consigliato di creare alcuni file

- boot.s
- kernel.c
- linkder.ld

mi sono imbattuto in un nuovo codice per il boot, lo proveremo e vedremo i risultati che otterremo.

la prima cosa che necessitiamo è **i686-elf-as** per compilare da ora in poi il nostro OS 

si può installare eseguendo

```sh
git clone https://github.com/lordmilko/i686-elf-tools.git
cd i686-elf-tools
chmod +x i686-elf-tools.sh
./i686-elf-tools.sh
```

di conseguenza cambieremo anche il nostro make

ed otterremo:

```makefile

i686 = i686-elf-as

BOOT_SECTOR = boot.asm
BOOT_BIN = boot.bin

all: $(BOOT_BIN)

$(BOOT_BIN): $(BOOT_SECTOR)
	$(i686) $(BOOT_SECTOR) -o $(BOOT_BIN)

clean:
	rm -f *.bin *.o *.elf

run: $(BOOT_BIN)
	qemu-system-i386 -drive format=raw,file=$(BOOT_BIN),if=floppy -nographic
```