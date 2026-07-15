; ************************************************************************
; Project: Lemon
; Author: Bryce Simonds
; License: MIT
; File: lemon.s
; Description: Lemon 6502 monitor program.
;
; Copyright (c) 2023-2026
; ************************************************************************

.include "lemon.inc"
.include "parse.inc"

.import empty_str

.export lemon

.export input_buf

; ************************************************************************

.segment "KVARS"

; ************************************************************************
; Lemon parsing variables
;

; Input buffer
input_buf: .res INPUT_LEN

; ************************************************************************

.segment "BIOS"

; ************************************************************************
; Lemon main entry point
;

lemon:
    zprint prompt_str
    edit_ln input_buf, INPUT_LEN

    jsr parse_cmd
    jsr dispatch_cmd

    ;jsr print_cmd
    ;print_ln

    bra lemon

; ************************************************************************

.proc dispatch_cmd: near
    ; Check to see if we have a command at all.
    cpx cmd_offset
    bne @disp_continue
    rts ; X == cmd_offset, no command

@disp_continue:
    ldx #$FF ; Will roll over to 0 for first check.

@cmd_check:
    inx ; Increment to next possible index

    ; Compute index in our command list.
    txa 
    asl
    asl
    tay

    ; Store pointer to command string
    lda cmd_list, y
    beq @cmd_not_found ; Zero is terminator

    sta W0
    iny
    lda cmd_list, y
    sta W0 + 1

    lda #<input_buf
    clc
    adc cmd_offset ; Adjust for offset
    sta W1
    lda #>input_buf
    sta W1 + 1

    jsr zstr_icmp
    bne @cmd_check ; Strings don't equal, check next one.
    
@cmd_found:
    ; Load pointer of function to call
    txa
    asl
    asl
    clc
    adc #2
    tax
    
    ; Call our command, it will handle clean up and return.
    jmp (cmd_list, x)

@cmd_not_found:
    zprint not_found_str

    ; Print the command that the user typed in.
    ldx #>input_buf
    lda #<input_buf

    clc
    adc cmd_offset ; Adjust for offset

    jsr print_zstr

    print_chr '.'
    print_ln
    rts
.endproc

; ************************************************************************
