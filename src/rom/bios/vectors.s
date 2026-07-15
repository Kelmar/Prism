; ************************************************************************
; Project: Prism
; Author: Bryce Simonds
; License: MIT
; File: prism1.s
; Description: BIOS vector tables
;
; Copyright (c) 2023-2024
; ************************************************************************

.import reset
.import cop_service, brk_service, abort_service, nmi_service, irq_service

.import serial_getch, serial_putch
;.import ksim_getch, ksim_putch

.import print
.import abi_test

.export BIOSTAB

; BIOS Jump Table (new)
.segment "BIOSTAB"
BIOSTAB:
.word abi_test ; 0
.word print    ; 1

; BIOS Jump Table
.segment "BIOSJMP"
;jmp ksim_getch    ; $FD00
;jmp ksim_putch    ; $FD03
jmp serial_getch   ; $FD00
jmp serial_putch   ; $FD03
jmp print          ; $FD06

; Native mode vectors
.segment "N_VECTORS"
.word 0 ; Reserved
.word 0 ; Reserved
.word cop_service
.word brk_service
.word abort_service
.word nmi_service
.word 0 ; Reserved
.word irq_service

; Emulation mode vectors
.segment "E_VECTORS"
.word 0 ; Reserved
.word 0 ; Reserved
.word cop_service
.word 0 ; Reserved
.word abort_service
.word nmi_service
.word reset
.word irq_service
