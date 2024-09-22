; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Palmtree Panic Bad Future palette cycle
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Handle palette cycling
; ------------------------------------------------------------------------------

PaletteCycle:
	lea	PalCycleData1,a0		; Prepare first palette data set
	subq.b	#1,palette_cycle_timers		; Decrement timer
	bpl.s	.SkipCycle1			; If this cycle's timer isn't done, branch
	move.b	#7,palette_cycle_timers		; Reset the timer

	moveq	#0,d0				; Get the current palette cycle frame
	move.b	palette_cycle_steps,d0
	cmpi.b	#2,d0				; Should we wrap it back to 0?
	bne.s	.IncCycle1			; If not, don't worry about it
	moveq	#0,d0				; If so, then do it
	bra.s	.ApplyCycle1

.IncCycle1:
	addq.b	#1,d0				; Increment the palette cycle frame

.ApplyCycle1:
	move.b	d0,palette_cycle_steps

	lsl.w	#3,d0				; Store the currnent palette cycle data in palette RAM
	lea	palette+$6A,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)

.SkipCycle1:
	adda.w	#PalCycleData2-PalCycleData1,a0	; Prepare second palette data set
	subq.b	#1,palette_cycle_timers+1	; Decrement timer
	bpl.s	.End				; If this cycle's timer isn't done, branch
	move.b	#5,palette_cycle_timers+1	; Reset the timer

	moveq	#0,d0				; Get the current palette cycle frame
	move.b	palette_cycle_steps+1,d0
	cmpi.b	#2,d0				; Should we wrap it back to 0?
	bne.s	.IncCycle2			; If not, don't worry about it
	moveq	#0,d0				; If so, then do it
	bra.s	.ApplyCycle2

.IncCycle2:
	addq.b	#1,d0				; Increment the palette cycle frame

.ApplyCycle2:
	move.b	d0,palette_cycle_steps+1

	andi.w	#3,d0				; Store the currnent palette cycle data in palette RAM
	lsl.w	#3,d0
	lea	palette+$58.w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)

.End:
	lea	palette_cycle_timers+2,a5	; Third palette cycle uses a script
	lea	palette_cycle_steps+2,a4

	lea	PalCycle3Script,a1
	lea	PalCycle3Colors,a2

; ------------------------------------------------------------------------------

	include	"Level/Palette Cycle Script.asm"

; ------------------------------------------------------------------------------
; Palette cycle data
; ------------------------------------------------------------------------------

PalCycleData1:
	dc.w	$888, $666, $888, $444
	dc.w	$444, $888, $666, $666
	dc.w	$666, $444, $444, $888

PalCycleData2:
	dc.w	$CAE, $C8C, $A44, $C6A
	dc.w	$C8C, $C6A, $A44, $CAE
	dc.w	$C6A, $CAE, $A44, $C8C

PalCycle3Script:
	dc.b	$22, 8
	dc.b	4, 0
	dc.b	4, 1
	dc.b	4, 2
	dc.b	4, 3
	dc.b	4, 4
	dc.b	4, 3
	dc.b	4, 2
	dc.b	4, 1
PalCycle3Colors:
	dc.w	$00E, $00C, $00A, $008, $006

; ------------------------------------------------------------------------------
