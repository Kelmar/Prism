; ************************************************************************
; Project: Prism
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: prism1.s
; Description: Platform initialization for the Kowalski simulator.
;
; Copyright (c) 2023-2024
; ************************************************************************

.export platform_init

; ************************************************************************

.segment "BIOS"

.proc platform_init: near
    rts
.endproc

; ************************************************************************
