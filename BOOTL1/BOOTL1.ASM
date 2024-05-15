org 0x7C00
bits 16

; === FAT 16 HEADER === ;
bpb:
	.ign:
		jmp _start
		nop
	.oem: db "AOSD0_00" ; AmethystOS Drive Internal ID=0
	.bps: dw 512
	.spc: db 0   ; Not true
	.rsc: dw 1
	.fat: db 2
	.ent: dw 512
	.tsc: dw 0x8000
	.mdt: db 0   ; Not true, but don't care
	.spf: dw 2
	.spt: dw 0   ; Not true
	.mhc: dw 0   ; Not true
	.hsc: dd 0
	.lsc: dd 0
ebr:
	.did: db 0   ; Not true, but don't care
	.flg: db 0   ; Only if Windows NT
	.sig: db 0x28
	.vid: dd 0xA05D0000 ; Same as bpb.oem
	.lbl: db "AOS INSTALL"
	.sis: db "AMETHYST"

;; === CODE === ;;
_start:
    ; Setup segments
    xor ax, 0x07c0
    mov ds, ax
    mov es, ax
    xor ax, ax 
    ; Setup stack
    mov ss, ax
    mov sp, 0x8000
    ; Print hello message
    mov ah, 0xE
    mov al, 'H'
    mov bh, 0,
    int 0x10
    mov al, 'e'
    int 0x10
    mov al, 'l'
    int 0x10
    mov al, 'l'
    int 0x10
    mov al, 'o'
    int 0x10


	cli
	hlt

hello: db "Hello, world", 0xA, 0xD

;; === BOOTLOADER SIG == ;;
times 510 - ($ - $$) db 0
dw 0xAA55
