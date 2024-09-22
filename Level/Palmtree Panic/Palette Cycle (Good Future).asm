; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Palmtree Panic Good Future palette cycle
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
	lea	palette+$58,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)

.End:
	rts

; ------------------------------------------------------------------------------
; Palette cycle data
; ------------------------------------------------------------------------------

PalCycleData1:
	dc.w	$ECC, $ECA, $EEE, $EA8
	dc.w	$EA8, $ECC, $ECC, $ECA
	dc.w	$ECA, $EA8, $ECA, $ECC

PalCycleData2:
	dc.w	$ECA, $EA8, $C60, $E86
	dc.w	$EA8, $E86, $C60, $ECA
	dc.w	$E86, $ECA, $C60, $EA8

; ------------------------------------------------------------------------------
