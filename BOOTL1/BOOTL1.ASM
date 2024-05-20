bits 16

%macro print_c_str 1
    push word %1
    call _print_c_str
    add sp, 2
%endmacro

%macro print_hex 1
    push word %1
    call _print_hex
    add sp, 2
%endmacro

%macro print_err 1
    push %1
    call _print_c_str
    push ax
    call _print_hex
    add sp, 4
%endmacro

; === FAT 16 HEADER === ;
bpb:
	.ign:
		jmp _start
		nop
	.oem: db "AOSD0_00" ; AmethystOS Drive Internal ID=0
	.bps: dw 512
	.spc: db 0   ; Not true
	.rsc: dw 2
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
	.did: db 0   ; Will be changed later...
	.flg: db 0   ; Only if Windows NT
	.sig: db 0x28
	.vid: dd 0xA05D0000 ; Same as bpb.oem
	.lbl: db "AOS INSTALL"
	.sis: db "AMETHYST"

;; === CODE === ;;

; Call standard
; Stack = [RETURN] [ARG1] [ARG2] [ARG3]
;
; PUSH BP
; MOV BP, SP
; ; ARGS ARE AT [BP-2..]
; PUSH <local vars>
; MOV SP, BP
; POP BP
; MOV AX, <return value>
; RET
;
; Byte arguments are aligned to word. 

tmp: db "AH", 0

_start:
    ; Setup segments
    mov ax, 0x07C0
    mov ds, ax
    xor ax, ax 
    mov es, ax
    mov ss, ax
    jmp 0x7C0:.next

.next:
    ; Setup stack
    mov sp, 0x9000
    mov bp, sp

    ; Save drive number
    mov [ebr.did], dl
    xor ah, ah
    push ax

    call _reset_disk
    pop ax
    jnc .load_reserved

    print_err error.reset
    cli
    hlt

.load_reserved:
    mov [dap.sze], word 1
    mov [dap.adr.seg], word 0x07C0
    mov [dap.adr.off], word reserved
    mov [dap.lba.hi], dword 0
    mov [dap.lba.lo], dword 1
    push word dap

    mov al, byte [ebr.did]
    xor ah, ah
    push ax

    call _disk_read
    pop ax
    pop ax
    jnc .print_hello

    print_err error.read
    cli
    hlt

.print_hello:
    print_c_str tmp
    print_c_str new_hello
	cli
	hlt

; Load from disk
; Arg1: WORD = DAP Ptr
; Arg2: BYTE = Drive ID
; Return: CF set on failure
_disk_read:
    push bp
    mov bp, sp
    
    ; Local AH = BIOS Func
    push ax 
    mov ah, 0x42
    ; Local DL = Drive ID
    push dx
    mov dl, [bp+4]
    ; Local SI = DAP Ptr
    push si
    mov si, [bp+6]
    
    print_hex si
    print_hex dx

    int 0x13

    pop si
    pop dx
    pop ax

    mov sp, bp
    pop bp
    ret

; Reset disk controller
; Arg1: BYTE = Drive ID
; Return: CF set on failure
_reset_disk:
    push bp
    mov bp, sp

    ; local DL = Drive ID
    push dx
    mov dl, [bp+4]

    ; Execute Disk System Reset
    xor ah, ah 
    int 0x13
    ; CF will be set automaticly
    ; Restore DL
    pop dx

    mov sp, bp
    pop bp
    ret

; Print a C-string
; Arg1: WORD = Ptr
_print_c_str:
    push bp
    mov bp, sp
    
    ; Local regs
    push ax ; Local AL = Character
    mov  ah, 0xE  ; AH = BIOS Func
    push bx ; Local BH = Page number
    xor  bh, bh
    push si ; Local SI = Pointer
    mov  si, [bp+4]

.loop:
    ; Iterate SI 
    lodsb
    or al, al
    jz .end
    int 0x10 ; Print
    jmp .loop
    
.end:
    ; Restore local vars
    pop si
    pop bx
    pop ax

    mov sp, bp
    pop bp
    ret

; Print an hexadecimal word
; Arg1: WORD = Value
_print_hex:
    push bp
    mov bp, sp

    push ax
    mov ax, [bp+4]
    
    push bx
    mov bx, ax

    push cx
    mov cx, 4

.next:
    mov ax, bx
    rol bx, 4
    shr ax, 12
    cmp ax, 10
    jl .skip
    add ax, 7

.skip:
    add ax, 48
    push bx
    push ax
    mov ah, 0xE
    mov bl, 0
    int 0x10
    pop ax
    pop bx
    loop .next

    pop cx
    pop bx
    pop ax

    mov sp, bp
    pop bp
    ret

dap:
    .ign1: db 0x10
    .ign2: db 0
    .sze: dw 0 ; TO SET
    .adr:
    .adr.off: dw 0 ; TO SET
    .adr.seg: dw 0 ; TO SET
    .lba:
    .lba.lo:  dw 0 ; TO SET
    .lba.hi:  dw 0 ; TO SET
error:
    .reset: db "RESET DEVICE FAILURE ", 0
    .read: db "READ DEVICE FAILURE ", 0
;; === BOOTLOADER SIG == ;;
times 510 - ($ - $$) db 0
dw 0xAA55

;; === ADDITIONNAL CODE === ;;
reserved:

new_hello: db "Hello, world!", 0xA, 0xD, 0

;; FILL BINARY
times 1024 - ($ - $$) db 0

