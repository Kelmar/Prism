; ************************************************************************
; Project: Prism
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: prism1.s
; Description: Utilties for working with 65816 assembly.
;
; Copyright (c) 2023-2024
; ************************************************************************

.smart -

.macro MODE16
    rep #%00110000
    .A16
    .I16
.endmacro

.macro MODE8
    rep #%00110000
    .A8
    .I8
.endmacro

.macro ACC16
    rep #%00100000
    .A16
.endmacro

.macro ACC8
    sep #%00100000
    .A8
.endmacro

.macro IDX16
    rep #%00010000
    .I16
.endmacro

.macro IDX8
    sep #%00010000
    .I8
.endmacro
