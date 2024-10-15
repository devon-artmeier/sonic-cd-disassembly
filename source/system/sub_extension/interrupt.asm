; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"
	include	"system_symbols.inc"
	include	"pcm_driver.inc"

	section code

; ------------------------------------------------------------------------------
; Null graphics interrupt
; ------------------------------------------------------------------------------

	xdef NullGraphicsIrq
NullGraphicsIrq:
	rte

; ------------------------------------------------------------------------------
; Run PCM driver (timer interrupt)
; ------------------------------------------------------------------------------

	xdef TimerIrq
TimerIrq:
	bchg	#0,pcm_driver_flags				; Should we run the driver on this interrupt?
	beq.s	.End						; If not, branch

	movem.l	d0-a6,-(sp)					; Run the driver
	jsr	RunPcmDriver
	movem.l	(sp)+,d0-a6

.End:
	rte

; ------------------------------------------------------------------------------
