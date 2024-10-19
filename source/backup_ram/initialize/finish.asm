; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"variables.inc"

	section code
	
	xref GiveWordRamAccess

; ------------------------------------------------------------------------------
; Finish operations
; ------------------------------------------------------------------------------

	xdef Finish
Finish:
	nop							; Tell Sub CPU we are done
	bset	#7,MCD_MAIN_FLAG

.WaitSubCpu:
	bsr.w	GiveWordRamAccess				; Give Sub CPU Word RAM access
	btst	#7,MCD_SUB_FLAG					; Is the Sub CPU done?
	beq.s	.WaitSubCpu

	moveq	#0,d0						; Clear communication registers
	move.l	d0,MCD_MAIN_COMM_0
	move.l	d0,MCD_MAIN_COMM_4
	move.l	d0,MCD_MAIN_COMM_8
	move.l	d0,MCD_MAIN_COMM_12
	move.b	d0,MCD_MAIN_FLAG
	rts

; ------------------------------------------------------------------------------
