; ************************************************************************
; Project: Prism
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: prism1.s
; Description: IO subsystem for BIOS
;
; Copyright (c) 2023-2024
; ************************************************************************

.include "util.inc"

.import serial_putch
.import serial_getch

.export io_init, io_cls, print

.import greeting

; ************************************************************************

.segment "BIOS"

.proc io_init: near
    php
    MODE16
    lda reset_code
    jsr print
    jsr io_cls
    plp
    rts
.endproc

.proc io_cls: near
    php
    MODE16
    lda clear_code
    jsr print
    plp
    rts
.endproc

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
    jsr serial_putch
    iny
    dex
    bne @pr_loop
    ply
    plp
    rts
.endproc

; ************************************************************************

.segment "RODATA"
reset_code: .byte 2, $1B, "c"
clear_code: .byte 4, $1B, "[2j"

; ************************************************************************

