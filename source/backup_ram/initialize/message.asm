; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"variables.inc"

	section code
	
	xref Finish, InitMegaDrive, LoadMessageArt, DrawMessageTilemap

; ------------------------------------------------------------------------------
; Backup RAM corrupted error
; ------------------------------------------------------------------------------

	xdef BuramCorrupted
BuramCorrupted:
	moveq	#0,d0						; Show message
	bsr.w	ShowMessage
	bra.w	ErrorLoop					; Enter infinite loop

; ------------------------------------------------------------------------------
; Unformatted internal Backup RAM error
; ------------------------------------------------------------------------------

	xdef Unformatted
Unformatted:
	moveq	#1,d0						; Show message
	bsr.w	ShowMessage
	bra.w	ErrorLoop					; Enter infinite loop

; ------------------------------------------------------------------------------
; Unformatted RAM cartridge error
; ------------------------------------------------------------------------------

	xdef CartUnformatted
CartUnformatted:
	moveq	#2,d0						; Show message
	bsr.w	ShowMessage
	bra.w	ErrorLoop					; Enter infinite loop

; ------------------------------------------------------------------------------
; Backup RAM full warning
; ------------------------------------------------------------------------------

	xdef BuramFull
BuramFull:
	moveq	#3,d0						; Show message
	bsr.w	ShowMessage

.WaitUser:
	move.b	ctrl_tap,d0					; Get tapped buttons
	andi.b	#$F0,ctrl_tap					; Were A, B, C, or start pressed?
	beq.s	.WaitUser					; If not, wait

	bsr.w	Finish						; Finish operations
	moveq	#1,d0						; Mark as failed
	rts

; ------------------------------------------------------------------------------
; Fatal error infinite loop
; ------------------------------------------------------------------------------

ErrorLoop:
	bra.w	*

; ------------------------------------------------------------------------------
; Show a message
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - Message ID
;	       0 = Backup RAM corrupted
;	       1 = Internal Backup RAM unformatted
;	       2 = RAM cartridge unformatted
;	       3 = Backup RAM full
; ------------------------------------------------------------------------------

ShowMessage:
	move.l	d0,-(sp)					; Save message ID

	bsr.w	InitMegaDrive					; Initialize Mega Drive hardware
	bclr	#6,ipx_vdp_reg_81+1				; Disable display
	move.w	ipx_vdp_reg_81,VDP_CTRL

	vdpCmd move.l,$BC00,VRAM,WRITE,VDP_CTRL			; Disable sprites
	lea	VDP_DATA,a6
	moveq	#0,d0
	move.l	d0,(a6)
	move.l	d0,(a6)

	;if REGION=USA						; Load art
		move.l	#$00010203,d0
	;else
	;	move.l	#$00000102,d0
	;endif
	jsr	LoadMessageArt

	move.l	(sp)+,d0					; Restore message ID
	add.w	d0,d0

	move.l	d0,-(sp)					; Draw first tilemap
	jsr	DrawMessageTilemap
	move.l	(sp)+,d0

	addq.w	#1,d0						; Draw second tilemap
	jsr	DrawMessageTilemap
	
	bset	#6,ipx_vdp_reg_81+1				; Enable display
	move.w	ipx_vdp_reg_81,VDP_CTRL
	rts

; ------------------------------------------------------------------------------
