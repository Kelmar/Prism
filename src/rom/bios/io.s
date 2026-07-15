; ************************************************************************
; Project: Prism
; Author: Bryce Simonds
; License: MIT
; File: prism1.s
; Description: IO subsystem for BIOS
;
; Copyright (c) 2023-2024
; ************************************************************************

IO_S = 1

.include "../include/io.inc"
.include "../include/zp.inc"

.export clear
.export print_zstr
.export print_zstrln
.export print_hex

.export edit_line

.import print_char

; ************************************************************************
; Common character codes

.define BS      $08 ; Backspace
.define DEL     $7F ; Delete (often used as backspace in some terminals)
.define LF      $0A ; Line feed
.define CR      $0D ; Carriage return
.define ESC     $1B ; Escape

; ************************************************************************

.segment "BIOS"

.proc io_init: near
    php
    MODE16
    lda reset_code
    jsr print
    jsr clear
    plp
    rts
.endproc

; ************************************************************************
; Clear's the terminal and returns the cursor to the home position.
;
; Arguments: (NONE)
;
.proc clear: near
    php
    MODE16
    lda clear_code
    jsr print
    plp
    rts
.endproc

; ************************************************************************

; Print pascal string pointed to in the C register.
.proc print: near
    php
    phy
    sta 0
    ldy #0
    lda b, #0

    ;and #$00FF
    ACC8
    lda (0), y
    tax
    iny
@pr_loop:
    lda (0), y
    jsr write_char
    iny
    dex
    bne @pr_loop
    ply
    plp
    rts
.endproc

; ************************************************************************
; Handles line editing and display.
;
; Supports backspace, return, escape.
;
; If the buffer overflows we return 0
;
; Arguments:
;   A - Low byte for buffer pointer
;   X - High byte for buffer pointer
;   Y - Buffer length in bytes
;
; Return:
;   Y - Length of string in characters
;
; Destroys: A, Y, P, K0, K1
;

.proc edit_line: near
    php

    sta K0
    stx K0 + 1

    sty K1

    ldy #0

@el_loop:
    jsr read_char

    cmp #BS
    beq @el_backspace
    cmp #DEL
    beq @el_backspace

    cmp #LF
    beq @el_return
    cmp #CR
    beq @el_return

    cmp #ESC
    beq @el_escape

    sta (K0), y
    jsr print_char

    iny
    cpy K1
    beq @el_escape ; Overflow
    bra @el_loop

@el_backspace:
    cpy #0
    beq @el_loop ; Nothing to backspace

    ; Erase the character
    lda #BS
    jsr print_char
    lda #' '
    jsr print_char
    lda #BS
    jsr print_char

    dey

    bra @el_loop

    sta (K0), y

    bra @el_loop

@el_escape:
    ; Return empty string
    ldy #0

@el_return:
    lda #0
    sta (K0), y

@el_done:
    lda #CR
    jsr print_char
    lda #LF
    jsr print_char

    plp
    rts
.endproc

; ************************************************************************

.segment "RODATA"

reset_str: .byte 2, $1B, "c"
clear_str: .byte "\033[H\033[2J", 0

; ************************************************************************
