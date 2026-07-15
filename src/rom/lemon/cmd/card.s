; ************************************************************************
; Project: Lemon
; Author: Bryce Simonds
; License: MIT
; File: lemon.s
; Description: Lemon Monitor CARD command.
;
; Copyright (c) 2023-2026
; ************************************************************************

.include "../lemon.inc"
.include "../parse.inc"

.export cmd_card

.segment "BIOS"

; ************************************************************************

.proc cmd_card: near
    zprint cmd_str
    zprint dis_str
    print_ln
    rts
.endproc

; ************************************************************************
