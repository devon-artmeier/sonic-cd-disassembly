; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code
	
	xref screen_disabled
	
; ------------------------------------------------------------------------------
; V-BLANK interrupt handler
; ------------------------------------------------------------------------------

	xdef VBlankIrq
VBlankIrq:
	bset	#MCDR_IFL2_BIT,MCD_IRQ2				; Trigger IRQ2 on Sub CPU
	
	bclr	#0,ipx_vsync					; Clear VSync flag
	bclr	#0,screen_disabled				; Clear screen disable flag
	beq.s	HBlankIrq					; If it wasn't set branch
	
	move.w	#$8134,VDP_CTRL					; If it was set, disable the screen

	xdef HBlankIrq
HBlankIrq:
	rte
	
; ------------------------------------------------------------------------------
