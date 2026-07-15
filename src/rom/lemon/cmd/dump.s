; ************************************************************************
; Project: Lemon
; Author: Bryce Simonds
; License: MIT
; File: lemon.s
; Description: Lemon Monitor DUMP command.
;
; Copyright (c) 2023-2026
; ************************************************************************

.include "../lemon.inc"
.include "../parse.inc"

.export cmd_dump

.import input_buf

; ************************************************************************

.segment "KVARS"

; Output buffer
output_buf: .res OUTPUT_LEN

dump_ptr: .res 2

; ************************************************************************

.segment "BIOS"

; ************************************************************************
; Dump command
;

.proc cmd_dump: near
    jsr parse_16bit
    bcc @addr1_ok
    zprint    error_str
    zprint_ln no_addr_str
    rts

@addr1_ok:
    ldx arg_offset
    
    bra_eos @dump_single

    ; Request to dump range of addresses?
    cmp '.'
    bne @bad_cmd

    ; Consume period
    inx

    ; Transfer W0 to W1
    lda W0
    sta W1
    lda W0 + 1
    sta W1 + 1

    jsr parse_16bit
    bcs @bad_cmd

@bad_cmd:
    zprint    error_str
    zprint_ln bad_range_str
    rts

@dump_range:
    ; Dump range from W1 to W0
    lda W1 + 1
    cmp W0 + 1
    bcc @range_ok
    lda W1
    cmp W0
    bcc @range_ok

    ; Swap the W1 and W0 pointers
    ldx W0
    sta W0
    stx W1

    lda W1 + 1
    ldx W0 + 1
    sta W0 + 1
    stx W1 + 1

@range_ok:
    ; Dump first line
    lda W1

    and #$07
    clc
    sbc #8
    ora %10000000
    tay

@dump_loop:
    lda W1

    ldx W1 + 1
    jsr dump_memory

    tya
    clc
    adc W1
    sta W1
    bcc @no_high_inc

    lda W1
    inc
    sta W1 + 1
    cmp W0 + 1
    ; BRANCH HERE TO END IF EQUAL OR GREATER THAN W0

@no_high_inc:
    

    ldy #8
    bra @dump_loop

@dump_single:

    lda W0 + 1
    jsr print_hex
    lda W0
    jsr print_hex

    print_chr ':'
    print_chr ' '

    lda (W0)
    jsr print_hex
    print_ln

    ;cpy_word K1, dump_start

    ;zprint cmd_str
    ;zprint dump_str
    ;print_ln

    ;print_chr '$'
    ;lda dump_start + 1
    ;jsr print_hex
    ;lda dump_start
    ;jsr print_hex
    ;print_ln

    rts
.endproc

; ************************************************************************
; Dump memory
;
; Dumps up to 8 bytes of memory.
;
; Note this does not add labels, so we can reuse this for dumping the contents
; of disk when we need to.
;
; Parameters:
;   A - Low byte of start address
;   X - High byte of start address
;   Y - Number of bytes to dump (1 to 8), high bit indicates right alignment.
;

.proc dump_memory: near
    phy

    sta dump_ptr
    stx dump_ptr + 1

    tya
    and %10000000
    bne @no_pad

    ; Clear high bit for our count
    tya
    ora %01111111
    tay

    sec
    sbc #8
    sta R0
    beq @no_pad ; Doing 8 bytes, no padding needed

    ; Multiply by 3 to get number of spaces
    sta TMP_A
    asl
    clc
    adc TMP_A
    inc ; Add one for null char

    tax

    stz output_buf, x
    dex

@sp_loop:
    lda #' '
    sta output_buf, x
    dex
    bne @sp_loop

    ; Print the padding
    zprint output_buf

    ; Generate the padding for interpreted characters
    ldx #0

@sp_loop2:
    lda #' '
    sta output_buf + 2, x ; Accounts for separator
    inx
    cpx R0
    bne @sp_loop2

@no_pad:
    ; Write separator
    lda #'|'
    sta output_buf, x
    lda #' '
    sta output_buf + 1, x

    ldx #0
@dump_loop:
    lda dump_ptr, x
    print_hex

    cmp #32
    bcc @write_dot
    cmp #127
    bcc @write_char

@write_dot:
    lda #'.' ; Replace non-printing char with a dot

@write_char:
    sta output_buf + 2, x ; Store parsed character for display after hex digits

    print_chr ' '
    inx
    dey
    bne @dump_loop

    ; Display separator and interpreted characters.
    stz output_buf, x
    zprint_ln output_buf

    ply
    rts
.endproc

; ************************************************************************
