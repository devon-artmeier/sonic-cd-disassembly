; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"variables.inc"

	section code
	
	xref StopZ80, StartZ80, ReadController

; ------------------------------------------------------------------------------
; V-BLANK interrupt
; ------------------------------------------------------------------------------

	xdef VBlankIrq
VBlankIrq:
	movem.l	d0-a6,-(sp)					; Save registers

	move.b	#1,MCD_IRQ2					; Trigger IRQ2 on Sub CPU
	tst.b	vsync_flag					; Are we lagging?
	beq.w	.Lag						; If so, branch
	move.b	#0,vsync_flag					; Clear VSync flag

	lea	VDP_CTRL,a1					; VDP control port
	lea	VDP_DATA,a2					; VDP data port
	move.w	(a1),d0						; Reset V-BLANK6 occurance flag
	
	jsr	StopZ80(pc)					; Stop the Z80

	move.w	vblank_routine,d0				; Run routine
	add.w	d0,d0
	move.w	.Routines(pc,d0.w),d0
	jmp	.Routines(pc,d0.w)

; ------------------------------------------------------------------------------

.Routines:
	dc.w	.Main-.Routines

; ------------------------------------------------------------------------------
; Main V-BLANK routine
; ------------------------------------------------------------------------------

.Main:
	bra.w	.Main2						; ?

.Main2:
	bsr.w	StartZ80					; Start the Z80
	
	tst.w	timer						; Is the timer active?
	beq.s	.NoTimer					; If not, branch
	subq.w	#1,timer					; Decrement timer

.NoTimer:
	addq.w	#1,frame_count					; Increment counter
	jsr	ReadController(pc)				; Read controller data

	movem.l	(sp)+,d0-a6					; Restore registers
	rte

; ------------------------------------------------------------------------------
; Lag V-BLANK routine
; ------------------------------------------------------------------------------

.Lag:
	addq.l	#1,lag_count					; Increment lag counter
	move.b	vblank_routine+1,lag_count			; Set highest byte to V-BLANK routine ID
	jsr	ReadController(pc)				; Read controller data

	movem.l	(sp)+,d0-a6					; Restore registers
	rte

; ------------------------------------------------------------------------------
