; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code
	
	xref RunMmd
	xref mmd_return_code

; ------------------------------------------------------------------------------
; Visual Mode
; ------------------------------------------------------------------------------

	xdef VisualMode
VisualMode:
	move.w	#SYS_VISUAL_MODE,d0				; Run Visual Mode
	bsr.w	RunMmd

	add.w	d0,d0						; Play FMV
	move.w	.FMVs(pc,d0.w),d0
	jmp	.FMVs(pc,d0.w)

; ------------------------------------------------------------------------------

.FMVs:
	dc.w	ExitVisualMode-.FMVs				; Exit Visual Mode
	dc.w	VisualModeOpening-.FMVs				; Opening
	dc.w	VisualModeGoodEnding-.FMVs			; Good ending
	dc.w	VisualModeBadEnding-.FMVs			; Bad ending
	dc.w	VisualModePencilTest-.FMVs			; Pencil test

; ------------------------------------------------------------------------------
; Play opening FMV
; ------------------------------------------------------------------------------

VisualModeOpening:
	move.w	#SYS_OPENING,d0					; Run opening
	bsr.w	RunMmd
	
	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	VisualModeOpening				; If so, loop

	bra.s	VisualMode					; Go back to menu

; ------------------------------------------------------------------------------
; Exit Visual Mode
; ------------------------------------------------------------------------------

ExitVisualMode:
	rts

; ------------------------------------------------------------------------------
; Play pencil test FMV
; ------------------------------------------------------------------------------

VisualModePencilTest:
	move.w	#SYS_PENCIL_TEST,d0				; Run pencil test
	bsr.w	RunMmd
	
	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	VisualModePencilTest				; If so, loop

	bra.s	VisualMode					; Go back to menu

; ------------------------------------------------------------------------------
; Play good ending FMV
; ------------------------------------------------------------------------------

VisualModeGoodEnding:
	move.b	#$7F,ending_id					; Set ending ID to good ending
	
	move.w	#SYS_GOOD_END,d0				; Run good ending
	bsr.w	RunMmd
	
	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	VisualModeGoodEnding				; If so, loop
	
	move.w	#SYS_THANKS,d0					; Run "Thank You" screen
	bsr.w	RunMmd

	bra.s	VisualMode					; Go back to menu

; ------------------------------------------------------------------------------
; Play bad ending FMV
; ------------------------------------------------------------------------------

VisualModeBadEnding:
	move.b	#0,ending_id					; Set ending ID to bad ending
	
	move.w	#SYS_BAD_END,d0					; Run bad ending
	bsr.w	RunMmd
	
	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	VisualModeBadEnding				; If so, loop

	bra.s	VisualMode					; Go back to menu
	
; ------------------------------------------------------------------------------
