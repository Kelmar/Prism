; ************************************************************************
; Project: Prism
; Author: Bryce Simonds
; License: MIT
; File: prism1.s
; Description: System call entry point
;
; Copyright (c) 2023-2024
; ************************************************************************

.include "util.inc"

.import BIOSTAB

.export cop_service, _api_done

; ************************************************************************

.segment "BIOS"

cop_service:
    MODE16 ; Mode will get restored when the function returns
    pha
    phx
    phy

    ; Re-enable interrupts
    ;cli

    and #$00FF

    ; Validate range of call
    ;cmp #maxapi
    ;bcs _bad_api

    ; Adjust to table index
    asl
    tax

    ; Jump to API
    jmp (BIOSTAB, x)

_bad_api:
    ; TODO: Handle bad API request.

_api_done:
    MODE16
    ply
    plx
    pla
    rti
