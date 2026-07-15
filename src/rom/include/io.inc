; ************************************************************************
; Project: Prism
; Author: Bryce Simonds
; License: MIT
; File: io.inc
; Description: BIOS generic I/O functions common import
;
; Copyright (c) 2023-2025
; ************************************************************************

.ifndef MAIN_S
.import empty_str
.endif

; ************************************************************************
; Defined by UART driver
; ************************************************************************
; Initialize the serial driver.
;
; Parameters: (NONE)
.import init_serial

; ************************************************************************
; Process serial driver interrupt.
;
; Parameters: (NONE)
.import serial_irq

; ************************************************************************
; Read a single raw byte from the serial port.
;
; Parameters: (NONE)
;
; Returns:
;
.import read_byte

; ************************************************************************
; Read a single character from the serial port.
;
; Unlike read_byte, this function will attempt to process the incoming character
; stream for function keys, and other commands from the terminal.
;
; Parameters: (NONE)
;
; Returns:
;
.import read_char

; ************************************************************************
; Write a single raw byte to the serial port.
;
; Parameters:
;    A - The byte to write.
;
.import write_byte

; ************************************************************************
; Write a single character to the serial port.
;
; This function will attempt to perform any additional processing for escape
; sequences or other functions.
;
; Parameters:
;    A - The character to write.
;
.import print_char

; ************************************************************************
; Defined in io.s
; ************************************************************************

.ifndef IO_S

; ************************************************************************
; Clear's the terminal
;
; Parameters: (NONE)
;
.import clear

; ************************************************************************
; Print a C style null terminated string.
;
; Parameters:
;    A - Low byte of string pointer.
;    X - High byte of string pointer.
;
; Destroys: A, P, K0
; 
.import print_zstr

; ************************************************************************
; Print a C style null terminated string with newline.
;
; Parameters:
;   A - Low byte of string pointer.
;   X - High byte of string pointer.
;
; Destroys: A, P
;
.import print_zstrln

; ************************************************************************
; Prints the byte in A as a hexadecimal number.
;
; Parameters:
;   A - The hexadecimal byte to print.
;
; Destroys: P
;
.import print_hex

; ************************************************************************
; Handles line editing and display.
; 
; Supports backspace, return, escape.
;
; If the buffer overflows we return 0
;
; Arguments:
;   A - Low byte for buffer pointer
;   X - High byte for buffer pointer
;   Y - Buffer length in bytes
;
; Return:
;   Y - Length of string in characters
;
; Destroys: A, Y, P, K0, K1
;
.import edit_line

.endif

; ************************************************************************
; Convenience macros
; ************************************************************************

; Note that many of these macros will destroy various registers.

; ************************************************************************
; Print null terminated C string.
;
; Prints a C style null terminated string to the terminal.
;
; Example:
;   zprint my_str
;
; my_zstr: .word "Hi, there", 0
;
.macro zprint addr
    lda #<addr
    ldx #>addr
    jsr print_zstr
.endmacro

; ************************************************************************
; Print null terminated C string plus newline.
;
; Prints a C style null terminated string to the terminal followed by a
; new line.
;
; Example:
;     zprint_ln my_zstr
;
; my_zstr: .word "Hi there", 0
;
.macro zprint_ln addr
    lda #<addr
    ldx #>addr
    jsr print_zstrln
.endmacro

; ************************************************************************
; Print newline
;
; Prints a new line to the terminal.
;
; Example: print_ln
;
.macro print_ln
    lda #<empty_str
    ldx #>empty_str
    jsr print_zstrln
.endmacro

; ************************************************************************
; Print single character
;
; Prints the supplied character.
; 
; Example: print_chr 'A'
;
.macro print_chr chr
    lda #chr
    jsr print_char
.endmacro

; ************************************************************************
; Edit a line of text.
;
; This function will allow the user to edit a line of text with some basic
; line editing functionality.
;
; Example: 
; .define INPUT_LEN 64
;
; input_buf: .res INPUT_LEN
;
;    edit_ln input_buf, INPUT_LEN
;
.macro edit_ln addr, len
    lda #<addr
    ldx #>addr
    ldy #len
    jsr edit_line
.endmacro

; ************************************************************************
