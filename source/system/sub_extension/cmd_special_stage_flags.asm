; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"
	include	"system_symbols.inc"
	include	"special_stage.inc"

	section code
	
	xref FinishCommand

; ------------------------------------------------------------------------------
; Reset special stage flags
; ------------------------------------------------------------------------------

	xdef ResetSpecialStageFlags
ResetSpecialStageFlags:
	moveq	#0,d0
	move.b	d0,time_stones_sub				; Reset time stones retrieved
	move.b	d0,special_stage_id				; Reset stage ID
	move.l	d0,special_stage_timer				; Reset timer
	move.w	d0,special_stage_rings				; Reset rings
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Initialize special stage flags
; ------------------------------------------------------------------------------

	xdef InitSpecialStageFlags
InitSpecialStageFlags:
	moveq	#0,d0
	move.b	d0,time_stones_sub				; Reset time stones retrieved
	move.b	d0,special_stage_id				; Reset stage ID
	move.l	d0,special_stage_timer				; Reset timer
	move.w	d0,special_stage_rings				; Reset rings
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
