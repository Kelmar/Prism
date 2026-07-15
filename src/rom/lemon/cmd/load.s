; ************************************************************************
; Project: Lemon
; Author: Bryce Simonds
; License: MIT
; File: lemon.s
; Description: Lemon Monitor LOAD command.
;
; Copyright (c) 2023-2026
; ************************************************************************

.include "../lemon.inc"
.include "../parse.inc"

.export cmd_load

.segment "BIOS"

; ************************************************************************
; Load command
;

.proc cmd_load: near
    zprint cmd_str
    zprint load_str
    print_ln
    rts
.endproc

; ************************************************************************
