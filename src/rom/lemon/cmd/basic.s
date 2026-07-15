; ************************************************************************
; Project: Lemon
; Author: Bryce Simonds
; License: MIT
; File: lemon.s
; Description: Lemon Monitor BASIC command.
;
; Copyright (c) 2023-2026
; ************************************************************************

.include "../lemon.inc"
.include "../parse.inc"

;.export cmd_basic

.segment "BIOS"

; ************************************************************************
; Basic command
;

;.proc cmd_basic: near
;    zprint cmd_str
;    zprint basic_str
;    print_ln
;    rts
;.endproc

; ************************************************************************
