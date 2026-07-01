; ************************************************************************
; Project: Prism
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: prism1.s
; Description: Driver for Kowalski simulator in/out
;
; Copyright (c) 2023-2024
; ************************************************************************

.export ksim_putch
.export ksim_getch

.define IO_BASE $7F00

.define IO_TX IO_BASE + $2
.define IO_RX IO_BASE + $4

; ************************************************************************

.segment "BIOS"

.proc ksim_putch: near
    php
    ACC8
    sta IO_TX
    cmp #$D
    bne @done
    lda #$A
    sta IO_TX
@done:
    plp
    rts
.endproc

; ************************************************************************

.proc ksim_getch: near
    php
    ACC8
@gc_loop:
    lda IO_RX
    beq @gc_loop
    plp
    rts
.endproc

; ************************************************************************
