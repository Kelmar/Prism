; ************************************************************************
;
;  The WOZ Monitor for the Apple 1
;  Written by Steve Wozniak 1976
;
; ************************************************************************
; Modified for the Prism line of 65816 systems.
; ************************************************************************

.include "bios.inc"

.export monitor
.import empty_str

; ************************************************************************
;  Memory declaration
; ************************************************************************

; Page 0 Variables

.define XAML  $24      ; Last "opened" location LOW
.define XAMH  $25      ; Last "opened" location HIGH
.define STL   $26      ; Store address low
.define STH   $27      ; Store address high
.define L     $28      ; Hex value parsing Low
.define H     $29      ; Hex value parsing High
.define YSAV  $2A      ; Used to see if hex value is given
.define MODE  $2B      ; $00=XAM, $7F=STOR, $AE=BLOCK XAM

.define IN    $0200    ; Input buffer

; KBD b7..b0 are inputs, b6..b0 is ASCII input, b7 is constant high
;     Programmed to respond to low to high KBD strobe
; DSP b6..b0 are outputs, b7 is input
;     CB2 goes low when data is written, returns high when CB1 goes high
; Interrupts are enabled, though not used. KBD can be jumpered to IRQ,
; whereas DSP can be jumpered to NMI.

; ************************************************************************
;  Constants
; ************************************************************************

.define BS      $08     ; Backspace key, arrow left key
.define CR      $0D     ; Carriage return
.define ESC     $1B     ; ESC key
.define PROMPT  '\'     ; Prompt character

.segment "BIOS"

monitor:
    lda #0
    ldy #$7F

; Program falls through to the GETLINE routine to save some program bytes
; Please note that Y still holds $7F, which will cause an automatic Escape

; ************************************************************************
; The GETLINE process
; ************************************************************************

notcr:
    cmp #BS         ; Backspace key?
    beq backspace   ; Yes
    cmp #ESC        ; Escape?
    beq escape      ; Yes
    iny             ; Advance text index
    bpl nextchar    ; Auto esc if line longer than 127

escape:
    lda #PROMPT     ; Print prompt character
    jsr putch       ; Output

getline:
    lda #CR         ; Send CR
    jsr putch
    ldy #01         ; Initialize text index.

backspace:
    dey             ; Backup text index
    bmi getline     ; Oops, line's empty, reinitialize
    
nextchar:
    jsr getch       ; Read key from serial port
    sta IN, y       ; Add to text buffer
    jsr putch       ; Display character
    cmp #CR
    bne notcr       ; It's not CR!

; Line received, now let's parse it

    ldy #$FF        ; Reset text index
    lda #0          ; Default mode is XAM
    tax             ; X = 0

setstor:
    asl             ; Leaves $7B if setting STOR mode
    jmp setmode

setblock:
    lda #$AE

setmode:
    sta MODE        ; $00=XAM $7B=STOR $AE=BLOK XAM

skipchar:
    iny             ; Advance text index

nextitem:
    lda IN, y       ; Get character
    cmp #CR
    beq getline     ; We're done if it's CR!
    cmp #'.'
    bcc skipchar    ; Ignore everything below "."!
    beq setblock    ; Set BLOCK XAM mode ("." = $AE)
    cmp #':'
    beq setstor     ; Set STOR mode! $BA will become $7B
    cmp #'R'
    beq run         ; Run the program! Forget the rest
    stx L           ; Clear input value (X = 0)
    stx H
    sty YSAV        ; Save Y for comparison

; Here we're trying to parse a new hex value

nexthex:
    lda IN, y       ; Get character for hex test
    eor #$30        ; Map digits to 0-9
    cmp #$0A        ; Is it a decimal digit?
    bcc dig         ; Yes!
    adc #$88        ; Map letter "A"-"F" to $FA-FF
    cmp #$FA        ; Hex letter?
    bcc nothex      ; No! Character not hex

dig:
    asl
    asl             ; Hex digit to MSD of A
    asl
    asl

    ldx #4          ; Shift count

hexshift:
    asl             ; Hex digit left, MSB to carry
    rol L           ; Rotate into LSD
    rol H           ; Rotate into MSD's
    dex             ; Done 4 shifts?
    bne hexshift    ; No, loop
    iny             ; Advance text input
    bne nexthex     ; Always taken

nothex:
    cpy YSAV        ; Was at least 1 hex digit given?
    beq escape      ; No! Ignore all, start from scratch

    bit MODE        ; Test MODE byte
    bvc notstor     ; B6=0 is STOR, 1 is XAM or BLOCK XAM

    lda L           ; LSD's of hex data
    sta (STL, x)    ; Store current 'store index'.
    inc STL         ; Increment store index.
    bne nextitem    ; Get next item (no carry).
    inc STH         ; Add carry to 'store index' high order.

tonextitem:
    jmp nextitem    ; Get next command item.

; ************************************************************************
;  RUN user's program from last opened location
; ************************************************************************

run:
    ; JSR will push return to stack
    ; The called program is responsible for RTS to get back here.
    jsr run_ret 
    
    ; Print 'FIN' banner to let user know code is done.
    zprint_ln fin_label

    jmp monitor     ; "Restart" the monitor

run_ret:
    jmp (XAML)      ; Run user's program

notstor:
    bmi xamnext     ; B7 = 0 for XAM, 1 for BLOCK XAM

    ldx #2          ; Copy 2 bytes

setadr:
    lda L - 1, x    ; Copy hex data to
    sta STL - 1, x  ;  'store index'
    sta XAML - 1, x ;  and to 'XAM index'
    dex             ; Next of 2 bytes
    bne setadr      ; Loop unless X = 0

nxtprnt:
    bne prdata      ; NE means no address to print
    lda #CR         ; Print CR first
    jsr putch
    lda XAMH        ; Output high-order byte of address
    jsr prbyte
    lda XAML        ; Output low-order byte of address
    jsr prbyte
    lda #':'        ; Print colon
    jsr putch

prdata:
    lda #' '        ; Print space
    jsr putch
    lda (XAML, x)   ; Get data byte at 'examine index'.
    jsr prbyte      ; Output it in hex format

xamnext:
    stx MODE        ; 0 -> MODE (XAM mode).
    lda XAML
    cmp L           ; Compare 'examine index' to hex data.
    lda XAMH
    sbc H
    bcs tonextitem  ; Not less! No more data to output.

    inc XAML        
    bne mod8chk     ; Increment 'examine index'
    inc XAMH

mod8chk:
    lda XAML        ; If address MOD 8 = 0
    and #$07
    bpl nxtprnt     ; Always taken.

; ************************************************************************

.segment "RODATA"

fin_label: .byte LF, CR, "FIN", 0


