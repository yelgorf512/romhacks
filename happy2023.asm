;
; happy2023.asm - FOR ATARI 2600 - HACK OF hello.asm BY YELGORF
; See bottom of this file for details on the original version by
; Carlos Duarte do Nascimento (Chester)
;
; INSTEAD OF HELLO WORLD IT SAYS HAPPY 2023
; ALSO MODIFIED TO HAVE COLOR SHIFT AND REFLECTION WOW!
;
; This is free software (see license below). Build it with DASM
; (http://dasm-dillon.sourceforge.net/), by running:
;
;   dasm happy2023.asm -ohello.bin -f3
;

    processor 6502
    
    ;Default 2600 Constants set up by dissasembler..                                                                   
VSYNC   =  $00                                                                                                     
VBLANK  =  $01                                                                                                     
WSYNC   =  $02                                                                                                     
RSYNC   =  $03                                                                                                     
NUSIZ0  =  $04                                                                                                     
NUSIZ1  =  $05                                                                                                     
COLUP0  =  $06                                                                                                     
COLUP1  =  $07                                                                                                     
COLUPF  =  $08                                                                                                     
COLUBK  =  $09                                                                                                     
CTRLPF  =  $0A                                                                                                     
PF0     =  $0D                                                                                                     
PF1     =  $0E                                                                                                     
PF2     =  $0F                                                                                                     
RESP0   =  $10                                                                                                     
AUDC0   =  $15                                                                                                     
AUDF0   =  $17                                                                                                     
AUDV0   =  $19                                                                                                     
AUDV1   =  $1A                                                                                                     
GRP0    =  $1B                                                                                                     
GRP1    =  $1C                                                                                                     
ENAM0   =  $1D                                                                                                     
ENAM1   =  $1E                                                                                                     
ENABL   =  $1F                                                                                                     
HMP0    =  $20                                                                                                     
VDEL01  =  $26                                                                                                     
HMOVE   =  $2A                                                                                                     
HMCLR   =  $2B                                                                                                     
CXCLR   =  $2C                                                                                                     
CXP0FB  =  $32                                                                                                     
CXP1FB  =  $33                                                                                                     
CXM0FB  =  $34                                                                                                     
CXM1FB  =  $35                                                                                                     
CXBLPF  =  $36                                                                                                     
CXPPMM  =  $37                                                                                                     
INPT4   =  $3C                                                                                                     
SWCHA   =  $0280                                                                                                   
SWCHB   =  $0282                                                                                                   
INTIM   =  $0284                                                                                                   
TIM64T  =  $0296         

    ORG $F000       ; Start of "cart area" (see Atari memory map)

StartFrame:
    lda #%00000010  ; Vertical sync is signaled by VSYNC's bit 1...
    sta VSYNC
    REPEAT 3        ; ...and lasts 3 scanlines
        sta WSYNC   ; (WSYNC write => wait for end of scanline)
    REPEND
    lda #0
    sta VSYNC       ; Signal vertical sync by clearing the bit

PreparePlayfield:   ; We'll use the first VBLANK scanline for setup
    lda #$00        ; (could have done it before, just once)
    sta ENABL       ; Turn off ball, missiles and players
    sta ENAM0
    sta ENAM1
    sta GRP0
    sta GRP1
    sta COLUBK      ; Background color (black)
    sta PF0         ; PF0 and PF2 will be "off" (we'll focus on PF1)...
    sta PF2
    lda #$88        ; Playfield collor (yellow-ish)
    sta COLUPF
    lda #$01        ; Ensure we will duplicate (and not reflect) PF
    sta CTRLPF
    ldx #0          ; X will count visible scanlines, let's reset it
    REPEAT 37       ; Wait until this (and the other 36) vertical blank
        sta WSYNC   ; scanlines are finished
    REPEND
    lda #0          ; Vertical blank is done, we can "turn on" the beam
    sta VBLANK

Scanline:
    cpx #174        ; "HELLO WORLD" = (11 chars x 8 lines - 1) x 2 scanlines =
    bcs ScanlineEnd ;   174 (0 to 173). After that, skip drawing code
    txa             ; We want each byte of the hello world phrase on 2 scanlines,
    lsr             ;   which means Y (bitmap counter) = X (scanline counter) / 2.
    tay             ;   For division by two we use (A-only) right-shift
    lda Phrase,y    ; "Phrase,Y" = mem(Phrase+Y) (Y-th address after Phrase)
    sta PF1         ; Put the value on PF bits 4-11 (0-3 is PF0, 12-15 is PF2)
ScanlineEnd:
    sta WSYNC       ; Wait for scanline end
    inx             ; Increase counter; repeat untill we got all kernel scanlines
    ;cpx #90        ; is this scanline 90?
    jsr SwitchColor ;   if so switch the color
    cpx #191
    bne Scanline


Overscan:
    lda #%01000010  ; "turn off" the beam again...
    sta VBLANK      ;
    REPEAT 30       ; ...for 30 overscan scanlines...
        sta WSYNC
    REPEND
    jmp StartFrame  ; ...and start it over!

SwitchColor:
    ;lda #$55       ; New playfield color
    txa
    sta COLUPF
    rts

Phrase:
    .BYTE %00000000 ; H
    .BYTE %01001000
    .BYTE %01001000
    .BYTE %01001000
    .BYTE %01111000
    .BYTE %01001000
    .BYTE %01001000
    .BYTE %00000000
    .BYTE %00110000 ; A
    .BYTE %01001000
    .BYTE %01001000
    .BYTE %01001000
    .BYTE %01111000
    .BYTE %01001000
    .BYTE %01001000
    .BYTE %00000000 ; P
    .BYTE %01110000
    .BYTE %01001000
    .BYTE %01001000
    .BYTE %01001000
    .BYTE %01110000
    .BYTE %01000000
    .BYTE %01000000
    .BYTE %00000000 ; P
    .BYTE %01110000
    .BYTE %01001000
    .BYTE %01001000
    .BYTE %01001000
    .BYTE %01110000
    .BYTE %01000000
    .BYTE %01000000
    .BYTE %00000000 ; Y
    .BYTE %01001000
    .BYTE %01001000
    .BYTE %01001000
    .BYTE %01111000
    .BYTE %00001000
    .BYTE %00001000
    .BYTE %01110000
    .BYTE %00000000
    .BYTE %00000000 ; white space
    .BYTE %00000000
    .BYTE %00000000
    .BYTE %00000000
    .BYTE %00000000
    .BYTE %00000000
    .BYTE %00000000
    .BYTE %00000000
    .BYTE %00000000 ; 2
    .BYTE %00110000
    .BYTE %01001000
    .BYTE %00001000
    .BYTE %00110000
    .BYTE %01000000
    .BYTE %01000000
    .BYTE %01111000
    .BYTE %00000000 ; O
    .BYTE %00110000
    .BYTE %01001000
    .BYTE %01001000
    .BYTE %01001000
    .BYTE %01001000
    .BYTE %00110000
    .BYTE %00000000
    .BYTE %00000000 ; 2
    .BYTE %00110000
    .BYTE %01001000
    .BYTE %00001000
    .BYTE %00110000
    .BYTE %01000000
    .BYTE %01000000
    .BYTE %01111000
    .BYTE %00000000 ; 3
    .BYTE %00110000
    .BYTE %01001000
    .BYTE %00001000
    .BYTE %00110000
    .BYTE %00001000
    .BYTE %01001000
    .BYTE %00110000
    .BYTE %00000000
    .BYTE %00000000
    .BYTE %00000000
    .BYTE %00000000
    .BYTE %00000000
    .BYTE %00000000
    .BYTE %00000000
    .BYTE %00000000 ; Last byte written to PF1 (important, ensures lower tip
                    ;                           of letter "D" won't "bleeed")

    ORG $FFFA             ; Cart config (so 6502 can start it up)

    .WORD StartFrame      ;     NMI
    .WORD StartFrame      ;     RESET
    .WORD StartFrame      ;     IRQ

    END

;
; Copyright 2011-2013 Carlos Duarte do Nascimento (Chester). All rights reserved.
;
; Redistribution and use in source and binary forms, with or without modification, are
; permitted provided that the following conditions are met:
;
;    1. Redistributions of source code must retain the above copyright notice, this list of
;       conditions and the following disclaimer.
;
;    2. Redistributions in binary form must reproduce the above copyright notice, this list
;       of conditions and the following disclaimer in the documentation and/or other materials
;       provided with the distribution.
;
; THIS SOFTWARE IS PROVIDED BY CHESTER ''AS IS'' AND ANY EXPRESS OR IMPLIED
; WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
; FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> OR
; CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
; SERVICES;  LOSS OF USE, DATA, OR PROFITS;  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
; ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
; NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
; ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;
; The views and conclusions contained in the software and documentation are those of the
; authors and should not be interpreted as representing official policies, either expressed
; or implied, of Chester.
;

