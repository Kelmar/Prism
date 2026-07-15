; ************************************************************************
; Project: Lemon
; Author: Bryce Simonds
; License: MIT
; File: lemon/parse.s
; Description: Lemon Monitor parsing functions
;
; Copyright (c) 2023-2026
; ************************************************************************

.include "lemon.inc"

.import input_buf

.export cmd_offset, arg_offset
.export dump_start, dump_end

.export skip_ws, parse_cmd
.export parse_prefix, parse_8bit, parse_16bit

; ************************************************************************

.segment "KVARS"

; ************************************************************************
; Lemon parsing variables
;

cmd_offset: .res 1 ; Offset in input_buf to start of command
arg_offset: .res 1 ; Offset in input_buf to start of first parameter

dump_start: .res 2 ; Start address for dump
dump_end:   .res 2 ; End address for dump

; ************************************************************************

.segment "BIOS"

; ************************************************************************
; Skips white space in input_buf
;
; Input:
;   X - Starting position to check for whitespace.
;
; Result:
;   X - Index of first nonwhite space character.
;

.proc skip_ws: near
    bra_eos @ws_done

    cmp #SP
    beq @next_ws

    cmp #TAB
    beq @next_ws

@ws_done:
    rts

@next_ws:
    inx
    bra skip_ws

.endproc

; ************************************************************************
; Parse command in input buffer
;
; Parses a command for the command line.
;
; This is the starting function to call to initialize a new parse.
;
; Input:
;  input_buf - String entered by user.
;
; Result:
;   cmd_offset - Start of the first non-whitespace character parsed.
;   arg_offset - Start of the first argument to the command, or at null-char if no arguments.
;
; Destroys: A, X, P
;

.proc parse_cmd: near
    ldx #0

    jsr skip_ws

    ; Preserve start of command
    stx cmd_offset

@parse_cmd:
    bra_eos @parse_done

    ; Did we get whitespace?
    cmp #SP
    beq @cmd_done

    cmp #TAB
    beq @cmd_done

    inx
    bra @parse_cmd

@cmd_done:
    lda #0
    sta input_buf, x    ; Mark end of command
    inx
    jsr skip_ws

@parse_done:
    stx arg_offset

    rts
.endproc

; ************************************************************************
; Parse a number prefix.
;
; Parses a number prefix for hex or binary numbers:
;   $ - Hex prefix
;   % - Binary prefix
;
; Input:
;   arg_offset - Offset into input_buf to start checking for prefix.
;
; Result:
;   A - 0 no prefix, 1 hex, 2 binary
;   P - Zero flag set for no prefix (or end of string), clear for prefix
;
;   arg_offset - New offset if prefix found.
;   

.proc parse_prefix: near
    ldx arg_offset

    bra_eos @not_found

    cmp #'$'
    bne @check_bin      ; Not $, check for hex digit
    lda #1
    bne @found          ; Always taken

@check_bin:
    cmp #'%'
    beq @bin_found

@not_found:
    lda #0
    rts

@bin_found:
    lda #2

@found:
    inx
    stx arg_offset
    rts

.endproc

; ************************************************************************
; Parse 8-bit number
;
; Parses an 8-bit number in input_buf.
;
; Does not look for $ prefix.
; Does not skip trailing whitespace.
;
; Result:
;    P - Carry flag as error indicator, zero for no error, set for error.
;    A - The number parsed.
;
.proc parse_8bit: near
    ; Clear out temp register encase we don't get a full result.
    stz TMP_A

    ldx arg_offset
    ldy #2 ; Parsing 2 digits

@next_digit:
    bra_eos @parse_eos

    ; Did we get whitespace?
    cmp #SP
    beq @parse_eos

    cmp #TAB
    beq @parse_eos

@parse_hex:
    eor #$30            ; Possible decimal to value
    cmp #$0A            ; Is decimal digit?
    bcc @store_digit    ; Yes
    ora #$20            ; Convert case
    adc #$88            ; Convert value
    cmp #$FA            ; Hex letter?
    bcs @store_digit    ; Yes

@parse_not_hex:         ; Invalid character
    sec
    rts

@store_digit:
    inx                 ; Character is valid, advance the cursor.

    ; Move digit into upper nybble
    asl
    asl
    asl
    asl
    
    ; Shift into TMP_A
    phy
    ldy #4
@shift_loop:
    asl                 ; MSB into carry
    rol TMP_A           ; Shift into TMP_A
    dey
    bne @shift_loop
    ply

    dey
    bne @next_digit     ; More digits to parse

    ; Read all needed digits
@parse_ok:
    stx arg_offset      ; Advance argument offset
    lda TMP_A           ; Load result
    clc                 ; Indicate OK
    rts

@parse_eos:
    cpx arg_offset
    bne @parse_ok       ; Parsed at least one digit
    sec                 ; ERROR, no digits parsed
    rts

.endproc

; ************************************************************************
; Parse 16-bit address
;
; Parses a 16-bit address in input_buf and leaves it in W0
;
; Result:
;    P - Carry flag as error indicator, zero for no error, set for error.
;   W0 - Value parsed
;

.proc parse_16bit: near
    ; Clear result encase we get fewer than 4 characters
    jsr parse_prefix ; Eat leading token if there

    jsr parse_8bit   ; parse high byte
    bcc @save_high
    rts

@save_high:
    sta W0 + 1       ; Save high byte

    jsr parse_8bit   ; parse low byte
    bcs @one_byte
    sta W0           ; Save low byte
    rts

@one_byte:
    ; Got only one byte, convert high to low
    lda W0 + 1
    sta W0
    stz W0 + 1
    clc              ; Indicate success
    rts
.endproc
