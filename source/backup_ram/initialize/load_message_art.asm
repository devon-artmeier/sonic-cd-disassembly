; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"variables.inc"

	section code_2
	
	xref DecompressNemesisVdp, EggmanArt, MessageArt, MessageUsaArt

; ------------------------------------------------------------------------------
; Load message art
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Message art ID queue
; ------------------------------------------------------------------------------

	xdef LoadMessageArt
LoadMessageArt:
	lea	VDP_CTRL,a5					; VDP control port
	moveq	#4-1,d2						; Number of IDs to check

.QueueLoop:
	moveq	#0,d1						; Get ID from queue
	move.b	d0,d1
	beq.s	.Next						; If it's blank, branch

	lsl.w	#3,d1						; Get art metadata
	lea	.MessageArt(pc),a0

	move.l	-8(a0,d1.w),(a5)				; VDP command
	movea.l	-4(a0,d1.w),a0					; Art data
	jsr	DecompressNemesisVdp(pc)			; Decompress and load art

.Next:
	ror.l	#8,d0						; Shift queue
	dbf	d2,.QueueLoop					; Loop until queue is scanned
	rts

; ------------------------------------------------------------------------------

.MessageArt:
	vdpCmd dc.l,$20,VRAM,WRITE				; Eggman art
	dc.l	EggmanArt
	vdpCmd dc.l,$340,VRAM,WRITE				; Message art
	dc.l	MessageArt
	;if REGION=USA
		vdpCmd dc.l,$1C40,VRAM,WRITE			; Message art (extension)
		dc.l	MessageUsaArt
	;endif

; ------------------------------------------------------------------------------
