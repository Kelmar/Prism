; ************************************************************************
; Project: Prism
; Author: Bryce Simonds
; License: MIT
; File: prism1.s
; Description: Initialization functions for the Prism1 development platform
;
; Copyright (c) 2023-2024
; ************************************************************************

.include "util.inc"
;.include "serial.inc"

.export platform_init

.import init_rtc
.import init_serial

; ************************************************************************

.segment "BIOS"

; Initialize the Prism1 development platform.
.proc platform_init: near
    ;jsr init_rtc
    jsr init_serial
    rts
.endproc

; ************************************************************************
