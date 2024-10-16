; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code
	
	xref RunMmd

; ------------------------------------------------------------------------------
; Sound test
; ------------------------------------------------------------------------------

	xdef SoundTest
SoundTest:
	moveq	#SYS_SOUND_TEST,d0				; Run sound test
	bsr.w	RunMmd

	add.w	d0,d0						; Exit sound test
	move.w	.Exits(pc,d0.w),d0
	jmp	.Exits(pc,d0.w)

; ------------------------------------------------------------------------------

.Exits:
	dc.w	ExitSoundTest-.Exits				; Exit sound test
	dc.w	RunSpecialStage8-.Exits				; Special Stage 8
	dc.w	RunFunIsInfinite-.Exits				; Fun is infinite
	dc.w	RunMcSonic-.Exits				; M.C. Sonic
	dc.w	RunTails-.Exits					; Tails
	dc.w	RunBatman-.Exits				; Batman Sonic
	dc.w	RunCuteSonic-.Exits				; Cute Sonic

; ------------------------------------------------------------------------------
; Exit sound test
; ------------------------------------------------------------------------------

ExitSoundTest:
	rts

; ------------------------------------------------------------------------------
; Special Stage 8
; ------------------------------------------------------------------------------

RunSpecialStage8:
	move.b	#8-1,special_stage_id_cmd			; Stage 8
	move.b	#0,time_stones_cmd				; Reset time stones retrieved
	bset	#0,special_stage_flags				; Temporary mode
	bset	#2,special_stage_flags				; Secret mode
	
	moveq	#SYS_SPECIAL_STAGE,d0				; Run special stage
	bsr.w	RunMmd
	
	tst.b	special_stage_lost				; Was the stage beaten?
	bne.s	.End						; If not, branch
	
	move.w	#SYS_SPECIAL_8_END,d0				; If so, run credits
	bsr.w	RunMmd

.End:
	rts

; ------------------------------------------------------------------------------
; "Fun is infinite" easter egg
; ------------------------------------------------------------------------------

RunFunIsInfinite:
	move.w	#SYS_FUN_IS_INFINITE,d0			; Run easter egg
	bra.w	RunMmd

; ------------------------------------------------------------------------------
; M.C. Sonic easter egg
; ------------------------------------------------------------------------------

RunMcSonic:
	move.w	#SYS_MC_SONIC,d0				; Run easter egg
	bra.w	RunMmd

; ------------------------------------------------------------------------------
; Tails easter egg
; ------------------------------------------------------------------------------

RunTails:
	move.w	#SYS_TAILS,d0					; Run easter egg
	bra.w	RunMmd

; ------------------------------------------------------------------------------
; Batman Sonic easter egg
; ------------------------------------------------------------------------------

RunBatman:
	move.w	#SYS_BATMAN,d0					; Run easter egg
	bra.w	RunMmd

; ------------------------------------------------------------------------------
; Cute Sonic easter egg
; ------------------------------------------------------------------------------

RunCuteSonic:
	move.w	#SYS_CUTE_SONIC,d0				; Run easter egg
	bra.w	RunMmd
	
; ------------------------------------------------------------------------------
