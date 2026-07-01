; ************************************************************************
; Project: Prism
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: prism1.s
; Description: Driver for DS1511 Real Time Clock
;
; Copyright (c) 2023-2024
; ************************************************************************

.include "util.inc"

; ************************************************************************

.define RTC_BASE $8C00

; Note that RTC values in the DS1511 are stored in BCD

; =========================
; Time registers
; =========================

.define RTC_SECONDS RTC_BASE + $00
.define RTC_MINUTES RTC_BASE + $01
.define RTC_HOURS   RTC_BASE + $02
.define RTC_DOW     RTC_BASE + $03
.define RTC_DATE    RTC_BASE + $04

; Oscillator start/stop bit (low is active)
.define RTC_FLAG_EOSC  %10000000

; Enable 32.768kHz output (low is active)
.define RTC_FLAG_E32K  %01000000

; Battery Backup 32kHz enable (high is active)
.define RTC_FLAG_BB32  %00100000

; Mask to get month value from bit flags
.define RTC_MASK_MONTH %00011111

; Also includes EOSC/, E32K/ and BB32 flags
.define RTC_MONTH   RTC_BASE + $05
.define RTC_YEAR    RTC_BASE + $06
.define RTC_CENTURY RTC_BASE + $07

; =========================
; Alarm registers
; =========================

; Alarm 1 enable bit
.define AM_FLAG_AM1 %10000000
.define AM_MASK_SECONDS %01111111
.define AM_SECONDS  RTC_BASE + $08

; Alarm 2 enable bit
.define AM_FLAG_AM2 %10000000
.define AM_MASK_MINUTES %01111111
.define AM_MINUTES  RTC_BASE + $09

; Alarm 3 enable bit
.define AM_FLAG_AM3 %10000000
.define AM_MASK_HOUR %01111111
.define AM_HOUR     RTC_BASE + $0A

; Alarm 4 enable bit
.define AM_FLAG_AM4 %10000000

; Alarm day or date/ bit
.define AM_FLAG_DY_DT %01000000

; Day/Date mask
.define AM_MASK_DATE %00111111
.define AM_DATE     RTC_BASE + $0B

; =========================
; Watchdog timer registers
; =========================

; Holds .1 sec and .01 sec
.define WD_SUB_SEC RTC_BASE + $0C

.define WD_SECONDS RTC_BASE + $0D

; =========================
; Control registers
; =========================

; Battery status bit1
.define RTC_CTLA_BLF1 %10000000
; Battery status bit2
.define RTC_CTLA_BLF2 %01000000

; Reset select bit
.define RTC_CTLA_PRS  %00100000

; Power Active (low is active)
.define RTC_CTLA_PAB  %00010000

; Time of day/date alarm flag
.define RTC_CTLA_TDF  %00001000

; Kickstart flag
.define RTC_CTLA_KSF  %00000100

; Watchdog flag
.define RTC_CTLA_WDF  %00000010

; Interrupt Request flag
.define RTC_CTLA_IRQF %00000001
.define RTC_CTRL_A RTC_BASE + $0E

; Transfer enable (active low)
; (set to low to disable clock while setting, set to high to resume clock function)
.define RTC_CTLB_TE   %10000000

; Crystal select bit
.define RTC_CTLB_CS   %01000000

; Burst-mode bit
.define RTC_CTLB_BME  %00100000

; Time of day/dat alarm power enable bit
.define RTC_CTLB_TPE  %00010000

; Time of day/date alarm interrupt-enable bit
.define RTC_CTLB_TIE  %00001000

; Kickstart enable interrupt bit
.define RTC_CTLB_KIE  %00000100

; Watchdog enable bit
.define RTC_CTLB_WDE  %00000010

; Watchdog steering bit
.define RTC_CTLB_WDS  %00000001
.define RTC_CTRL_B RTC_BASE + $0F

; =========================
; NV-RAM registers
; =========================

; Ram address control byte
.define RTC_RAM_ADDR RTC_BASE + $10

; Ram data value
.define RTC_RAM_DATA RTC_BASE + $13

; All other values are reserved in the data sheet.

; ************************************************************************

.segment "BIOS"

; Initializes the RTC
;
; In reality this reads the battery backed NV-RAM so the rest of the BIOS
; can initialize the hardware and boot per previously stored settings.
.proc init_rtc: near
    php
    ACC8

    ; Start at the begining
    stz RTC_RAM_ADDR

    ; Setup for burst mode reading of extended RAM
    lda #RTC_CTLB_BME
    tsb RTC_CTRL_B

    ; Start by checking to see if first two bytes are our 'PB' signature
    ; PB = Prism Bios
    lda RTC_RAM_DATA
    cmp #'P'
    bne @rtc_not_set
    lda RTC_RAM_DATA
    cmp #'B'
    bne @rtc_not_set

    ; Read boot order byte
    lda RTC_RAM_DATA
    ; Byte is divied into 2 (4-bit) values, MSB being first try boot, LSB being the last try boot
    ; 0 - Boot to Monitor ROM
    ; 1 - Boot to BASIC ROM
    ; 2 - Boot from removable media
    ; >3 - Reserved

    ; Read serial bit control
    ; xxSSCCPP
    ; x - Don't care
    ; S - Stop bit count (0, 1 or 2)
    ; C - Character bit count (0 = 6, 1 = 7, or 2 = 8)
    ; P - Parity (0 = none, 1 = odd, 2 = even)
    lda RTC_RAM_DATA

    ; Read serial clock divisor MSB
    lda RTC_RAM_DATA

    ; Read serial clock divisor LSB
    lda RTC_RAM_DATA

@rtc_not_set:

@rtc_init_done:
    ; Turn off burst mode
    lda #RTC_CTLB_BME
    trb RTC_CTRL_B

    plp
    rts
.endproc

; ************************************************************************
