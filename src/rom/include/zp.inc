; ************************************************************************
; Project: Prism
; Author: Bryce Simonds
; License: MIT
; File: zp.inc
; Description: Zero page system variables include
;
; Copyright (c) 2023-2025
; ************************************************************************

; ************************************************************************
; Parameter registers
;
; Used for when 6502 registers aren't sufficient for passing parameters to
; functions. 
; 

; 8-bit parameter
.define R0 $02

; 8-bit parameter
.define R1 $03

; 8-bit parameter
.define R2 $04

; 8-bit parameter
.define R3 $05

; 16-bit parameter
.define W0 $06

; 16-bit parameter
.define W1 $08

; 16-bit parameter
.define W2 $0A

; 16-bit parameter
.define W3 $0C

; 32-bit parameter
.define Q0 $0E

; 32-bit parameter
.define Q1 $12

; 32-bit - System tick counter.
.define SYS_TICKS $16

; ************************************************************************

.importzp TMP_A ; Scratch space for saving A
.importzp TMP_Y ; Scratch space for saving Y
.importzp TMP_X ; Scratch space for saving X

.importzp K0 ; Kernel 16-bit working register
.importzp K1 ; Kernel 16-bit working register

; ************************************************************************
