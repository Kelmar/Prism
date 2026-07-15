; ************************************************************************
; Project: Lemon
; Author: Bryce Simonds
; License: MIT
; File: lemon.s
; Description: Lemon Monitor read only data.
;
; Copyright (c) 2023-2026
; ************************************************************************

.import cmd_asm
;.import cmd_basic
.import cmd_card
.import cmd_dis
.import cmd_dump
.import cmd_load
.import reset       ; Jumps straight to BIOS reset vector
.import cmd_run

; ************************************************************************

.export prompt_str

; Info strings
.export error_str
.export not_found_str
.export cmd_str
.export no_addr_str
.export bad_range_str
;.export join_str

; Command words
.export asm_str
;.export basic_str
.export card_str
.export dis_str
.export dump_str
.export load_str
.export reset_str
.export run_str

; List of pointers to commands
.export cmd_list

; ************************************************************************

.segment "RODATA"

; ************************************************************************
; Read only variables
;

prompt_str: .byte "] ", 0

; Info strings
error_str: .byte "ERROR: ", 0
not_found_str: .byte "Unknown command: ", 0
cmd_str: .byte "Command: ", 0
no_addr_str: .byte "No address", 0
bad_range_str: .byte "Bad range", 0
;join_str: .byte ", $", 0

; ************************************************************************
; Command words
asm_str:   .byte "ASM"  , 0 ; Start assembling
;basic_str: .byte "BASIC", 0 ; Start BASIC
card_str:  .byte "CARD" , 0 ; Send card command
dis_str:   .byte "DIS"  , 0 ; Disassemble
dump_str:  .byte "DUMP" , 0 ; Dump memory
load_str:  .byte "LOAD" , 0 ; Load binary
reset_str: .byte "RESET", 0 ; Reset system
run_str:   .byte "RUN"  , 0 ; Run binary

; Command list table
cmd_list:
    ;     str ptr  , func ptr
    .word asm_str  , cmd_asm
    ;.word basic_str, cmd_basic
    .word card_str , cmd_card
    .word dis_str  , cmd_dis
    .word dump_str , cmd_dump
    .word load_str , cmd_load
    .word reset_str, reset      ; Jumps straight to BIOS reset vector.
    .word run_str  , cmd_run
    .word 0        , 0          ; List terminator

; ************************************************************************
