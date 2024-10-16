; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code
	
	xref RunMmd
	
; ------------------------------------------------------------------------------
; Run Special Stage 1 demo
; ------------------------------------------------------------------------------

	xdef SpecialStage1Demo
SpecialStage1Demo:
	move.b	#1-1,special_stage_id_cmd			; Stage 1
	move.b	#0,time_stones_cmd				; Reset time stones retrieved for this stage
	bset	#0,special_stage_flags				; Temporary mode
	
	moveq	#SYS_SPECIAL_STAGE,d0				; Run special stage
	bsr.w	RunMmd
	rts

; ------------------------------------------------------------------------------
; Run Special Stage 6 demo
; ------------------------------------------------------------------------------

	xdef SpecialStage6Demo
SpecialStage6Demo:
	move.b	#6-1,special_stage_id_cmd			; Stage 6
	move.b	#0,time_stones_cmd				; Reset time stones retrieved for this stage
	bset	#0,special_stage_flags				; Temporary mode
	
	moveq	#SYS_SPECIAL_STAGE,d0				; Run special stage
	bsr.w	RunMmd
	rts
	
; ------------------------------------------------------------------------------
