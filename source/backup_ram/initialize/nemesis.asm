; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"variables.inc"

	section code_2
	
; ------------------------------------------------------------------------------
; Advance data bitstream
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - Branch to take if no new byte is needed (optional)
; ------------------------------------------------------------------------------

advanceBitstream macro
	cmpi.w	#9,d6						; Does a new byte need to be read?
	ifgt \#							; If not, branch
		bcc.s	\1
	else
		bcc.s	.NoNewByte\@
	endif
	
	addq.w	#8,d6						; Read next byte from bitstream
	asl.w	#8,d5
	move.b	(a0)+,d5

.NoNewByte\@:
	endm

; ------------------------------------------------------------------------------
; Decompress Nemesis art into VRAM (Note: VDP write command must be
; set beforehand)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Nemesis art pointer
; ------------------------------------------------------------------------------

	xdef DecompressNemesisVdp
DecompressNemesisVdp:
	movem.l	d0-a1/a3-a5,-(sp)				; Save registers
	lea	WriteNemesisRowVdp,a3				; Write all data to the same location
	lea	VDP_DATA,a4					; VDP data port
	bra.s	DecompressNemesisMain

; ------------------------------------------------------------------------------
; Decompress Nemesis data into RAM
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Nemesis data pointer
;	a4.l - Destination buffer pointer
; ------------------------------------------------------------------------------

	xdef DecompressNemesis
DecompressNemesis:
	movem.l	d0-a1/a3-a5,-(sp)				; Save registers
	lea	WriteNemesisRow,a3				; Advance to the next location after each write

; ------------------------------------------------------------------------------

DecompressNemesisMain:
	lea	nem_code_table,a1				; Prepare decompression buffer
	
	move.w	(a0)+,d2					; Get number of tiles
	lsl.w	#1,d2						; Should we use XOR mode?
	bcc.s	.GetRows					; If not, branch
	adda.w	#WriteNemesisRowVdpXor-WriteNemesisRowVdp,a3	; Use XOR mode

.GetRows:
	lsl.w	#2,d2						; Get number of rows
	movea.w	d2,a5
	moveq	#8,d3						; 8 pixels per row
	moveq	#0,d2						; XOR row buffer
	moveq	#0,d4						; Row buffer
	
	jsr	BuildNemesisCodeTable(pc)			; Build code table
	
	move.b	(a0)+,d5					; Get first word of compressed data
	asl.w	#8,d5
	move.b	(a0)+,d5
	move.w	#16,d6						; Set bitstream read data position
	
	bsr.s	GetNemesisCode					; Decompress data
	
	nop
	nop
	nop
	nop
	
	movem.l	(sp)+,d0-a1/a3-a5				; Restore registers
	rts

; ------------------------------------------------------------------------------

GetNemesisCode:
	move.w	d6,d7						; Peek 8 bits from bitstream
	subq.w	#8,d7
	move.w	d5,d1
	lsr.w	d7,d1
	cmpi.b	#%11111100,d1					; Should we read inline data?
	bcc.s	ReadInlineNemesisData				; If so, branch
	
	andi.w	#$FF,d1						; Get code length
	add.w	d1,d1
	move.b	(a1,d1.w),d0
	ext.w	d0
	
	sub.w	d0,d6						; Advance bitstream read data position
	advanceBitstream

	move.b	1(a1,d1.w),d1					; Get palette index
	move.w	d1,d0
	andi.w	#$F,d1
	andi.w	#$F0,d0						; Get repeat count

GetNemesisCodeLength:
	lsr.w	#4,d0						; Isolate repeat count

WriteNemesisPixel:
	lsl.l	#4,d4						; Shift up by a nibble
	or.b	d1,d4						; Write pixel
	subq.w	#1,d3						; Has an entire 8-pixel row been written?
	bne.s	NextNemesisPixel				; If not, loop
	jmp	(a3)						; Otherwise, write the row to its destination

; ------------------------------------------------------------------------------

ResetNemesisRow:
	moveq	#0,d4						; Reset row
	moveq	#8,d3						; Reset nibble counter

NextNemesisPixel:
	dbf	d0,WriteNemesisPixel				; Loop until finished
	bra.s	GetNemesisCode					; Read next code

; ------------------------------------------------------------------------------

ReadInlineNemesisData:
	subq.w	#6,d6						; Advance bitstream read data position
	advanceBitstream

	subq.w	#7,d6						; Read inline data
	move.w	d5,d1
	lsr.w	d6,d1
	move.w	d1,d0
	andi.w	#$F,d1						; Get palette index
	andi.w	#$70,d0						; Get repeat count
	
	advanceBitstream GetNemesisCodeLength			; Advance bitstream read data position
	bra.s	GetNemesisCodeLength

; ------------------------------------------------------------------------------

WriteNemesisRowVdp:
	move.l	d4,(a4)						; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemesisRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

WriteNemesisRowVdpXor:
	eor.l	d4,d2						; XOR the previous row with the current row
	move.l	d2,(a4)						; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemesisRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

WriteNemesisRow:
	move.l	d4,(a4)+					; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemesisRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

WriteNemesisRowXor:
	eor.l	d4,d2						; XOR the previous row with the current row
	move.l	d2,(a4)+					; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemesisRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

BuildNemesisCodeTable:
	move.b	(a0)+,d0					; Read first byte

.CheckEnd:
	cmpi.b	#$FF,d0						; Has the end of the code table been reached?
	bne.s	.NewPaletteIndex				; If not, branch
	rts

.NewPaletteIndex:
	move.w	d0,d7						; Set palette index

.Loop:
	move.b	(a0)+,d0					; Read next byte
	cmpi.b	#$80,d0						; Should we set a new palette index?
	bcc.s	.CheckEnd					; If so, branch

	move.b	d0,d1						; Copy repeat count
	andi.w	#$F,d7						; Get palette index
	andi.w	#$70,d1						; Get repeat count
	or.w	d1,d7						; Combine them
	
	andi.w	#$F,d0						; Get code length
	move.b	d0,d1
	lsl.w	#8,d1
	or.w	d1,d7						; Combine with palette index and repeat count
	
	moveq	#8,d1						; Is the code length 8 bits in size?
	sub.w	d0,d1
	bne.s	.ShortCode					; If not, branch
	
	move.b	(a0)+,d0					; Store code entry
	add.w	d0,d0
	move.w	d7,(a1,d0.w)
	bra.s	.Loop

.ShortCode:
	move.b	(a0)+,d0					; Get index
	lsl.w	d1,d0
	add.w	d0,d0
	
	moveq	#1,d5						; Get number of entries
	lsl.w	d1,d5
	subq.w	#1,d5

.ShortCode_Loop:
	move.w	d7,(a1,d0.w)					; Store code entry
	addq.w	#2,d0						; Increment index
	dbf	d5,.ShortCode_Loop				; Loop until finished
	bra.s	.Loop

; ------------------------------------------------------------------------------
