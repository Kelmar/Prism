; ************************************************************************
; Project: Lemon
; Author: Bryce Simonds
; License: MIT
; File: lemon.s
; Description: Lemon Monitor DIS command.
;
; Copyright (c) 2023-2026
; ************************************************************************

.include "../lemon.inc"
.include "../parse.inc"

.export cmd_dis

.segment "BIOS"

; ************************************************************************
; Dis command
;

.proc cmd_dis: near
    zprint cmd_str
    zprint dis_str
    print_ln
    rts
.endproc

; ************************************************************************
