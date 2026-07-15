; ************************************************************************
; Project: Lemon
; Author: Bryce Simonds
; License: MIT
; File: lemon.s
; Description: Lemon Monitor ASM command.
;
; Copyright (c) 2023-2026
; ************************************************************************

.include "../lemon.inc"
.include "../parse.inc"

.export cmd_asm

.segment "BIOS"

; ************************************************************************
; Asm command
;

.proc cmd_asm: near
    zprint cmd_str
    zprint asm_str
    print_ln
    rts
.endproc

; ************************************************************************
