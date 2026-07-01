; ************************************************************************
; Project: Prism
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: prism1.s
; Description: Main entry point for BIOS after reset.
;
; Copyright (c) 2023-2025
; ************************************************************************

.include "util.inc"
.include "bios.inc"

.import platform_init
.import monitor

.import _api_done

.import serial_putch
;.import ksim_putch

.import io_init, io_cls, print

.export reset
.export abi_test, brk_service, abort_service, nmi_service, irq_service

.export empty_str

; ************************************************************************

.segment "BIOS"

.proc reset: near
    ; Get some critical CPU stuff into a known state.
    ;sei ; Not needed for 65C02 or 65C816
    ;cld ; Not needed for 65C02 or 65C816

    ; Go into native mode
    clc
    xce

    ; Initialize the stack to 65C02 location
    ACC16
    lda #$01FF
    tcs

    ; Call platform specific initialization
    jsr platform_init

    ; Initialize the display and print the standard greeting.
    jsr io_init

    zprint_ln banner1
    zprint_ln banner2

    ; Return to 8bit mode for WozMon
    MODE8
    ;sec
    ;xce

@bios_loop:
    ; Start the monitor
    jmp monitor

    ; Shouldn't be possible to get here, but if we do, just restart the monitor.
    bra @bios_loop
.endproc

; Test system call
abi_test:
    ACC8
    lda #'T'
    jsr serial_putch
    lda #$D
    jsr serial_putch
    jmp _api_done

brk_service:
irq_service:
    .A8
    rti

abort_service:
nmi_service:
    .A8
    ; For now we do nothing, but in the future we should start the debugger.
    rti

;-------------------------------------------------------------------------

.segment "RODATA"

banner1: .byte "Prism BIOS v0.3.0", 0
banner2: .byte "Copyright (c) 2025"
empty_str: .byte 0
