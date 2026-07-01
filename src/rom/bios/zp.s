; ************************************************************************
; Project: Prism
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: zp.s
; Description: Zero page declarations
;
; Copyright (c) 2023-2024
; ************************************************************************

.export TMP_A
.export TMP_B
.export TMP_X
.export TMP_Y

.segment "ZEROPAGE"

; ************************************************************************

; Scratch space for preserving A(C) register
TMP_A: .res 1

; Scratch space for preserving B register
TMP_B: .res 1

; Scratch space for preserving X register
TMP_X: .res 2

; Scratch space for preserving Y register
TMP_Y: .res 2

; ************************************************************************
