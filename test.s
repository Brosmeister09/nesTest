.segment "HEADER"
    .byte "NES"
    .byte $1a
    .byte $02 ; 2 * 16KB PRG ROM
    .byte $01 ; 1 * 8KB CHR ROM
    .byte %00000000 ;  mapper and mirroring
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $00,$00,$00,$00,$00 ; filler bytes

.segment "ZEROPAGE"
.segment "STARTUP"
RESET:
  SEI ; Disable Interupts
  CLD ; Disable decimal mode (becouse nes doesnt have that)

  ; Disables Sound IRQ
  LDX #$40
  STX $4017

  ; Initalize Stack register
  LDX #$FF  ; Stack beginns with FF and goes down from there
  TXS

  INX ; #$FF + 1 = 0

  ; Zero out PPU (Picture Processing unit) registers
  STX $2000
  STX $2001

  ; Disable PCM Channels
  STX $4010

; Wir warten hier bist der NES mindestens einmal den Bildschirm gezeichnet hat
: ;anonymes label
  BIT $2002 ; stores bit 7 as the signed bit (and alot more)
  BPL :- ; springt zum letzten anonymen label

  TXA 

Clearmem:
  STA $0000, x ; $0000 => $00FF
  STA $0100, x ; $0100 => $01FF
  STA $0300, x ; $0300 => $03FF
  STA $0400, x ; $0400 => $04FF
  STA $0500, x ; $0500 => $05FF
  STA $0600, x ; $0600 => $06FF
  STA $0700, x ; $0700 => $07FF

  LDA #$FF
  STA $0200, x ; $0200 => $02FF Sprite memory in RAM
  LDA #$00
  INX
  BNE Clearmem ; wenn der wert FF inkrementiert wird wird das 0 flag auf 1 gesetzt das kann für BNE benutzt wird


; wait for vblank again
: ;anonymes label
  BIT $2002 ; stores bit 7 as the signed bit (and alot more)
  BPL :- ; springt zum letzten anonymen label

  LDA #$02 ; Wo die ppu sprite mem lesen soll in unserem fall bei $0200 => $02FF
  STA $4014
  NOP ; Wait a bit (No operation)

  ; $3F00
  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006

  LDX #$00

LoadPallets:
  LDA PalletData, x
  STA $2007
  INX
  CPX #$20
  BNE LoadPallets

  LDX #$00
LoadSprites:
  LDA SpriteData, x
  STA $0200, x
  INX
  CPX #$24
  BNE LoadSprites

; Enable interupts
  CLI

  LDA #%10010000 ;  enable NMI change background to use second chr set of tiles ($1000)
  STA $2000
  ; Enable sprites and background for the leftmost 8 pixels
  ; Enable spritest and background
  LDA #%00011110
  STA $2001

  LDX #$0
  TXS ; Transfer x to stack

Loop:

LDX #$0

incYandX:
  
  INC $0200,x
  INC $0203,x

  INX
  INX
  INX
  INX

  CPX #$24
  BNE incYandX

  TSX ; transfer value on stack to x

  lda #$01	; square 1
  sta $4015
  lda periodTableLo, x	; period low
  sta $4002
  lda periodTableHi, x	; period high
  sta $4003
  lda #$bf	; volume
  sta $4000

  INX

  CPX #$93
  BNE :+
  LDX #$F
:
  TXS

LDX #$0
LDY #$0

waitloop1:
  INY
waitloop2: 
  INX
  CPX #$0
  BNE waitloop2 
  CPY #$20
  BNE waitloop1
  JMP Loop

VBLANK:
  LDA #$02 ; Wo die ppu sprite mem lesen soll in unserem fall bei $0200 => $02FF
  STA $4014

  RTI ; Return from interrupt;:

; sound stuff
periodTableLo:
  .byt $f1,$7f,$13,$ad,$4d,$f3,$9d,$4c,$00,$b8,$74,$34
  .byt $f8,$bf,$89,$56,$26,$f9,$ce,$a6,$80,$5c,$3a,$1a
  .byt $fb,$df,$c4,$ab,$93,$7c,$67,$52,$3f,$2d,$1c,$0c
  .byt $fd,$ef,$e1,$d5,$c9,$bd,$b3,$a9,$9f,$96,$8e,$86
  .byt $7e,$77,$70,$6a,$64,$5e,$59,$54,$4f,$4b,$46,$42
  .byt $3f,$3b,$38,$34,$31,$2f,$2c,$29,$27,$25,$23,$21
  .byt $1f,$1d,$1b,$1a,$18,$17,$15,$14
  .byt $14,$15,$17,$18,$1a,$1b,$1d,$1f
  .byt $21,$23,$25,$27,$29,$2c,$2f,$31,$34,$38,$3b,$3f
  .byt $42,$46,$4b,$4f,$54,$59,$5e,$64,$6a,$70,$77,$7e
  .byt $86,$8e,$96,$9f,$a9,$b3,$bd,$c9,$d5,$e1,$ef,$fd
  .byt $0c,$1c,$2d,$3f,$52,$67,$7c,$93,$ab,$c4,$df,$fb
  .byt $1a,$3a,$5c,$80,$a6,$ce,$f9,$26,$56,$89,$bf,$f8
  .byt $34,$74,$b8,$00,$4c,$9d,$f3,$4d,$ad,$13,$7f,$f1
periodTableHi:
  .byt $07,$07,$07,$06,$06,$05,$05,$05,$05,$04,$04,$04
  .byt $03,$03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$02
  .byt $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
  .byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byt $00,$00,$00,$00,$00,$00,$00,$00
  .byt $00,$00,$00,$00,$00,$00,$00,$00
  .byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byt $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
  .byt $02,$02,$02,$02,$02,$02,$02,$03,$03,$03,$03,$03
  .byt $04,$04,$04,$05,$05,$05,$05,$06,$06,$07,$07,$07

PalletData:
  .byte $0F,$1C,$2B,$39,$0F,$1C,$2B,$39,$0F,$1C,$2B,$39,$0F,$1C,$2B,$39 ;background pallet data
  .byte $0F,$FC,$2B,$39,$0F,$1C,$2B,$39,$0F,$1C,$2B,$39,$0F,$1C,$2B,$39 ;spritepallet data

SpriteData:
  .byte $08, $07, $00, $00
  .byte $08, $00, $00, $08
  .byte $08, $0B, $00, $0F
  .byte $08, $0B, $00, $18
  .byte $08, $0E, $00, $1F
  .byte $10, $16, $00, $00
  .byte $10, $04, $00, $08
  .byte $10, $0B, $00, $0F
  .byte $10, $13, $00, $18

.segment "VECTORS"
    .word VBLANK
    .word RESET
    .word 0

.segment "CHARS"  
  .incbin "alphabet.chr"