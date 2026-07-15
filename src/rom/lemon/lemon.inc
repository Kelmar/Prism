; ************************************************************************
; Project: Lemon
; Author: Bryce Simonds
; License: MIT
; File: lemon/lemon.inc
; Description: Lemon Monitor common includes
;
; Copyright (c) 2023-2026
; ************************************************************************

.include "../include/io.inc"
.include "../include/zp.inc"
.include "../include/str.inc"

.include "consts.inc"

; ************************************************************************
; Branch on end of string, load char if not at end of buffer.

.macro bra_eos end_label
    cpx #INPUT_LEN
    beq end_label ; Reached buffer size.

    lda input_buf, x
    beq end_label ; NULL character end of line.
.endmacro

; ************************************************************************
