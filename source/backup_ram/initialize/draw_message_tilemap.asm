; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"variables.inc"

	section code_2
	
	xref DecompressEnigma, EggmanTilemap, DataCorruptTilemap, UnformattedTilemap
	xref UnformattedUsaTilemap, CartUnformattedTilemap, BuramFullTilemap

; ------------------------------------------------------------------------------
; Draw message tilemap
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - Tilemap ID
; ------------------------------------------------------------------------------

	xdef DrawMessageTilemap
DrawMessageTilemap:
	andi.l	#$FFFF,d0					; Get mappings metadata
	mulu.w	#14,d0
	lea	.Tilemaps,a1
	adda.w	d0,a1

	movea.l	(a1)+,a0					; Mappings data
	move.w	(a1)+,d0					; Base tile attributes

	move.l	a1,-(sp)					; Decompress mappings
	lea	decomp_buffer,a1
	bsr.w	DecompressEnigma
	movea.l	(sp)+,a1

	move.w	(a1)+,d3					; Width
	move.w	(a1)+,d2					; Height
	move.l	(a1),d0						; VDP command
	
	lea	decomp_buffer,a0				; Load mappings into VRAM
	movea.l	#VDP_DATA,a1					; VDP data port

.Row:
	move.l	d0,VDP_CTRL					; Set VDP command
	move.w	d3,d1						; Get width

.Tile:
	move.w	(a0)+,(a1)					; Copy tile
	dbf	d1,.Tile					; Loop until row is copied
	addi.l	#$800000,d0					; Next row
	dbf	d2,.Row						; Loop until map is copied
	rts

; ------------------------------------------------------------------------------

.Tilemaps:
	; Backup RAM data corrupted
	dc.l	EggmanTilemap
	dc.w	1
	dc.w	$A-1, 6-1
	vdpCmd dc.l,$C31E,VRAM,WRITE

	dc.l	DataCorruptTilemap
	dc.w	$201A
	;if REGION=JAPAN
	;	dc.w	$24-1, 6-1
	;	vdpCmd dc.l,$E584,VRAM,WRITE
	;else
		dc.w	$1D-1, 6-1
		vdpCmd dc.l,$E58A,VRAM,WRITE
	;endif
	
	; Internal Backup RAM unformatted
	dc.l	EggmanTilemap
	dc.w	1
	dc.w	$A-1, 6-1
	vdpCmd dc.l,$C31E,VRAM,WRITE

	;if REGION=JAPAN
	;	dc.l	UnformattedTilemap
	;	dc.w	$201A
	;	dc.w	$24-1, 6-1
	;	vdpCmd dc.l,$E584,VRAM,WRITE
	;elseif REGION=USA
		dc.l	UnformattedUsaTilemap
		dc.w	$20E2
		dc.w	$1D-1, 8-1
		vdpCmd dc.l,$E58A,VRAM,WRITE
	;else
	;	dc.l	UnformattedTilemap
	;	dc.w	$201A
	;	dc.w	$1D-1, 6-1
	;	vdpCmd dc.l,$E58A,VRAM,WRITE
	;endif
	
	; Cartridge Backup RAM unformatted
	dc.l	EggmanTilemap
	dc.w	1
	dc.w	9, 5
	;if REGION=JAPAN
	;	vdpCmd dc.l,$C21E,VRAM,WRITE
	;else
		vdpCmd dc.l,$C29E,VRAM,WRITE
	;endif

	dc.l	CartUnformattedTilemap
	dc.w	$201A
	;if REGION=JAPAN
	;	dc.w	$24-1, $A-1
	;	vdpCmd dc.l,$E484,VRAM,WRITE
	;else
		dc.w	$1D-1, 8-1
		vdpCmd dc.l,$E50A,VRAM,WRITE
	;endif
	
	; Backup RAM full
	dc.l	EggmanTilemap
	dc.w	1
	dc.w	9, 5
	;if REGION=JAPAN
	;	vdpCmd dc.l,$C29E,VRAM,WRITE
	;else
		vdpCmd dc.l,$C31E,VRAM,WRITE
	;endif

	dc.l	BuramFullTilemap
	dc.w	$201A
	;if REGION=JAPAN
	;	dc.w	$24-1, 8-1
	;	vdpCmd dc.l,$E504,VRAM,WRITE
	;else
		dc.w	$1D-1, 6-1
		vdpCmd dc.l,$E58A,VRAM,WRITE
	;endif

; ------------------------------------------------------------------------------
