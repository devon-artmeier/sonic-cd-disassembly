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
; Decompress Enigma tilemap data into RAM
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to Enigma data
;	a1.l - Pointer to destination buffer
;	d0.w - Base tile attributes
; ------------------------------------------------------------------------------

	xdef DecompressEnigma
DecompressEnigma:
	movem.l	d0-d7/a1-a5,-(sp)				; Save registers
	
	movea.w	d0,a3						; Get base tile
	
	move.b	(a0)+,d0					; Get size of inline copy value
	ext.w	d0
	movea.w	d0,a5

	move.b	(a0)+,d4					; Get tile flags
	lsl.b	#3,d4

	movea.w	(a0)+,a2					; Get incremental copy word
	adda.w	a3,a2
	
	movea.w	(a0)+,a4					; Get static copy word
	adda.w	a3,a4

	move.b	(a0)+,d5					; Get read first word
	asl.w	#8,d5
	move.b	(a0)+,d5
	moveq	#16,d6						; Initial shift value

GetEnigmaCode:
	moveq	#7,d0						; Assume a code entry is 7 bits
	move.w	d6,d7
	sub.w	d0,d7
	
	move.w	d5,d1						; Get code entry
	lsr.w	d7,d1
	andi.w	#$7F,d1
	move.w	d1,d2

	cmpi.w	#$40,d1						; Is this code entry actually 6 bits long?
	bcc.s	.GotCode					; If not, branch
	
	moveq	#6,d0						; Code entry is actually 6 bits
	lsr.w	#1,d2

.GotCode:
	bsr.w	AdvanceEnigmaBitstream				; Advance bitstream
	
	andi.w	#$F,d2						; Handle code
	lsr.w	#4,d1
	add.w	d1,d1
	jmp	HandleEnigmaCode(pc,d1.w)

; ------------------------------------------------------------------------------

EnigmaCopyInc:
	move.w	a2,(a1)+					; Copy incremental copy word
	addq.w	#1,a2						; Increment it
	dbf	d2,EnigmaCopyInc				; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyStatic:
	move.w	a4,(a1)+					; Copy static copy word
	dbf	d2,EnigmaCopyStatic				; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyInline:
	bsr.w	ReadInlineEnigmaData				; Read inline data	

.Loop:
	move.w	d1,(a1)+					; Copy inline value
	dbf	d2,.Loop					; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyInlineInc:
	bsr.w	ReadInlineEnigmaData				; Read inline data

.Loop:
	move.w	d1,(a1)+					; Copy inline value
	addq.w	#1,d1						; Increment it
	dbf	d2,.Loop					; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyInlineDec:
	bsr.w	ReadInlineEnigmaData				; Read inline data

.Loop:
	move.w	d1,(a1)+					; Copy inline value
	subq.w	#1,d1						; Decrement it
	dbf	d2,.Loop					; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyInlineMult:
	cmpi.w	#$F,d2						; Are we done?
	beq.s	EnigmaDone					; If so, branch

.Loop4:
	bsr.w	ReadInlineEnigmaData				; Read inline data
	move.w	d1,(a1)+					; Copy it
	dbf	d2,.Loop4					; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

HandleEnigmaCode:
	bra.s	EnigmaCopyInc
	bra.s	EnigmaCopyInc
	bra.s	EnigmaCopyStatic
	bra.s	EnigmaCopyStatic
	bra.s	EnigmaCopyInline
	bra.s	EnigmaCopyInlineInc
	bra.s	EnigmaCopyInlineDec
	bra.s	EnigmaCopyInlineMult

; ------------------------------------------------------------------------------

EnigmaDone:
	subq.w	#1,a0						; Go back by one byte
	cmpi.w	#16,d6						; Were we going to start a completely new byte?
	bne.s	.NotNewByte					; If not, branch
	subq.w	#1,a0						; Go back another

.NotNewByte:
	move.w	a0,d0						; Are we on an odd byte?
	lsr.w	#1,d0
	bcc.s	.Even						; If not, branch
	addq.w	#1,a0						; Ensure we're on an even byte

.Even:
	movem.l	(sp)+,d0-d7/a1-a5				; Restore registers
	rts

; ------------------------------------------------------------------------------

ReadInlineEnigmaData:
	move.w	a3,d3						; Copy base tile
	move.b	d4,d1						; Copy tile flags
	
	add.b	d1,d1						; Is the priority bit set?
	bcc.s	.NoPriority					; If not, branch
	
	subq.w	#1,d6						; Is the priority bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoPriority					; If not, branch
	
	ori.w	#$8000,d3					; Set priority bit in the base tile

.NoPriority:
	add.b	d1,d1						; Is the high palette line bit set?
	bcc.s	.NoPal1						; If not, branch
	
	subq.w	#1,d6						; Is the high palette bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoPal1						; If not, branch
	
	addi.w	#$4000,d3					; Set high palette bit

.NoPal1:
	add.b	d1,d1						; Is the low palette line bit set?
	bcc.s	.NoPal0						; If not, branch
	
	subq.w	#1,d6						; Is the low palette bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoPal0						; If not, branch
	
	addi.w	#$2000,d3					; Set low palette bit

.NoPal0:
	add.b	d1,d1						; Is the Y flip bit set?
	bcc.s	.NoYFlip					; If not, branch
	
	subq.w	#1,d6						; Is the Y flip bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoYFlip					; If not, branch
	
	ori.w	#$1000,d3					; Set Y flip bit

.NoYFlip:
	add.b	d1,d1						; Is the X flip bit set?
	bcc.s	.NoXFlip					; If not, branch
	
	subq.w	#1,d6						; Is the X flip bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoXFlip					; If not, branch
	
	ori.w	#$800,d3					; Set X flip bit

.NoXFlip:
	move.w	d5,d1						; Prepare to advance bitstream to tile ID
	move.w	d6,d7
	sub.w	a5,d7
	bcc.s	.GotEnoughBits					; If we don't need a new word, branch
	
	move.w	d7,d6						; Make space for the rest of the tile ID
	addi.w	#16,d6
	neg.w	d7
	lsl.w	d7,d1
	
	move.b	(a0),d5						; Add in the rest of the tile ID
	rol.b	d7,d5
	add.w	d7,d7
	and.w	EnigmaInlineMasks-2(pc,d7.w),d5
	add.w	d5,d1

.CombineBits:
	move.w	a5,d0						; Mask out garbage
	add.w	d0,d0
	and.w	EnigmaInlineMasks-2(pc,d0.w),d1

	add.w	d3,d1						; Add base tile
	
	move.b	(a0)+,d5					; Read another word from the bitstream
	lsl.w	#8,d5
	move.b	(a0)+,d5
	rts

.GotEnoughBits:
	beq.s	.JustEnough					; If the word has been exactly exhausted, branch
	
	lsr.w	d7,d1						; Shift tile data down
	
	move.w	a5,d0						; Mask out garbage
	add.w	d0,d0
	and.w	EnigmaInlineMasks-2(pc,d0.w),d1	
	
	add.w	d3,d1						; Add base tile

	move.w	a5,d0						; Advance bitstream
	bra.s	AdvanceEnigmaBitstream

.JustEnough:
	moveq	#16,d6						; Reset shift value
	bra.s	.CombineBits

; ------------------------------------------------------------------------------

EnigmaInlineMasks:
	dc.w	%0000000000000001
	dc.w	%0000000000000011
	dc.w	%0000000000000111
	dc.w	%0000000000001111
	dc.w	%0000000000011111
	dc.w	%0000000000111111
	dc.w	%0000000001111111
	dc.w	%0000000011111111
	dc.w	%0000000111111111
	dc.w	%0000001111111111
	dc.w	%0000011111111111
	dc.w	%0000111111111111
	dc.w	%0001111111111111
	dc.w	%0011111111111111
	dc.w	%0111111111111111
	dc.w	%1111111111111111

; ------------------------------------------------------------------------------

AdvanceEnigmaBitstream:
	sub.w	d0,d6						; Advance bitstream
	advanceBitstream
	rts

; ------------------------------------------------------------------------------
