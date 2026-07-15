; ************************************************************************
; Project: Prism
; Author: Bryce Simonds
; License: MIT
; File: str.inc
; Description: BIOS common string functions
;
; Copyright (c) 2023-2026
; ************************************************************************

; Defined in str.s
.ifndef STR_S
.import to_lower, to_upper
.import zstr_cmp, zstr_icmp
.endif

; ************************************************************************
