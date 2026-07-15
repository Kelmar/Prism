; ************************************************************************
; Project: Prism
; Author: Bryce Simonds
; License: MIT
; File: u26C92.s
; Description: Driver for S26C92 Dual UART
;
; Copyright (c) 2023-2024
; ************************************************************************

.include "util.inc"

.export init_serial
.export serial_putch
.export serial_getch

; ************************************************************************

.define SERIAL_BASE $8400

; Mode register A (r/w)
.define SERIAL_MRA  SERIAL_BASE + 0

; Port A status (read)
.define SERIAL_SRA  SERIAL_BASE + 1

; Port A clock select (write)
.define SERIAL_CSRA SERIAL_BASE + 1

; Port A command register (write only)
.define SERIAL_CRA  SERIAL_BASE + 2

; Port A TRX (r/w)
.define SERIAL_TRXA SERIAL_BASE + 3

; Input port change register (read)
.define SERIAL_ICPR SERIAL_BASE + 4

; Aux. control register (write)
.define SERIAL_ACR  SERIAL_BASE + 4

; Interrupt status register (read)
.define SERIAL_ISR  SERIAL_BASE + 5

; Interrupt mask regster (write)
.define SERIAL_IMR  SERIAL_BASE + 5

; Counter upper value (read)
.define SERIAL_CTU  SERIAL_BASE + 6

; Counter upper value preset (write)
.define SERIAL_CTPU SERIAL_BASE + 6

; Counter lower value (read)
.define SERIAL_CTL  SERIAL_BASE + 7

; Counter lower value preset (write)
.define SERIAL_CTPL SERIAL_BASE + 7

; Mode register B (r/w)
.define SERIAL_MRB  SERIAL_BASE + 8

; Port B status (read)
.define SERIAL_SRB  SERIAL_BASE + 9

; Port B clock select (write)
.define SERIAL_CSRB SERIAL_BASE + 9

; Port B command register (write only)
.define SERIAL_CRB  SERIAL_BASE + 10

; Port B TRX (r/w)
.define SERIAL_TRXB SERIAL_BASE + 11

; User/Status flags (r/w)
.define SERIAL_FLAG SERIAL_BASE + 12

; Read input ports (read)
.define SERIAL_INP  SERIAL_BASE + 13

; Output port configuration (write)
.define SERIAL_OPCR SERIAL_BASE + 13

; Start counter command (read)
.define SERIAL_START SERIAL_BASE + 14

; Set output ports (write)
.define SERIAL_OUT  SERIAL_BASE + 14

; Stop counter command (read)
.define SERIAL_STOP SERIAL_BASE + 15

; Reset output ports (write)
.define SERIAL_ROUT SERIAL_BASE + 15

; ************************************************************************

.segment "BIOS"

; Serial initialization
.proc init_serial: near
    php
    ACC8

    ; Set MRA to register 0
    lda #%10110000
    sta SERIAL_CRA

    ; Clear MR0 register to defaults
    stz SERIAL_MRA

    ; Set MRA to register 1
    lda #%00010000
    sta SERIAL_CRA

    ; Disable RX control, character mode, with parity, odd parity, 8 bits per char
    lda #%00000111
    sta SERIAL_MRA

    ; reg 2 follows reg 1
    ; normal mode, disable TX control, disable CTS, 1 stop bit
    lda #%00000100
    sta SERIAL_MRA

    ; Set control by external xtal / 16
    lda #%00110000
    sta SERIAL_ACR

    ; Set buad rate to 1200 (using 1.83 clock)
    lda #%10001000
    sta SERIAL_CSRA

    ; Enable transmitter & receiver
    lda #%00000101
    sta SERIAL_CRA

    plp
    rts
.endproc

; ************************************************************************

; Serial send character
.proc serial_putch: near
    php
    ACC8
    pha
    ; Wait for the serial port to become ready before sending next character.
    lda #%00000100
@wait:
    bit SERIAL_SRA
    beq @wait

    pla
    sta SERIAL_TRXA ; Send character
    plp
    rts
.endproc

; ************************************************************************

; Serial get character
.proc serial_getch: near
    php
    ACC8
    ; Wait for character to be available
    lda #%00000001
@wait:
    bit SERIAL_SRA
    beq @wait

    lda SERIAL_TRXA
    plp
    rts
.endproc

; ************************************************************************
