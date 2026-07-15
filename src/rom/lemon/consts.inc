; ************************************************************************
; Project: Lemon
; Author: Bryce Simonds
; License: MIT
; File: lemon.s
; Description: Lemon Monitor constants
;
; Copyright (c) 2023-2026
; ************************************************************************

.import fin_label ; Currently in Wozmon

.import prompt_str

.import error_str
.import not_found_str
.import cmd_str
.import no_addr_str
.import bad_range_str
;.import join_str

.define finish_str fin_label

.import asm_str
;.import basic_str
.import card_str
.import dis_str
.import dump_str
.import load_str
.import reset_str
.import run_str

.import cmd_list

; ************************************************************************

.define SP  $20
.define TAB $09

.define INPUT_LEN $40
.define OUTPUT_LEN $40

; ************************************************************************
