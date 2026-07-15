; ************************************************************************
; Project: Lemon
; Author: Bryce Simonds
; License: MIT
; File: lemon.s
; Description: Lemon Monitor RUN command.
;
; Copyright (c) 2023-2026
; ************************************************************************

.include "../lemon.inc"
.include "../parse.inc"

.export cmd_run

.segment "BIOS"

; ************************************************************************
; Run command
;

.proc cmd_run: near
    jsr parse_16bit
    bcs @addr_error

    ; Setup stack for return
    jsr @addr_ok

@prog_done:
    zprint_ln finish_str
    rts

@addr_error:
    zprint error_str
    zprint no_addr_str
    print_ln
    rts

@addr_ok:
    ldx #0
    jmp (W0, x) ; Program's RTS will return to @prog_done

.endproc

; ************************************************************************
