; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code
	
	xref RunMmd, SubCpuCommand, SpecialStage1Demo, SpecialStage6Demo
	xref mmd_return_code

; ------------------------------------------------------------------------------
; Demo mode
; ------------------------------------------------------------------------------

	xdef Demo
Demo:
	moveq	#(.DemosEnd-.Demos)/2-1,d1			; Maximum demo ID
	
	lea	demo_id,a6					; Get current demo ID
	moveq	#0,d0
	move.b	(a6),d0

	addq.b	#1,(a6)						; Advance demo ID
	cmp.b	(a6),d1						; Are we past the max ID?
	bcc.s	.RunDemo					; If not, branch
	move.b	#0,(a6)						; Wrap demo ID

.RunDemo:
	add.w	d0,d0						; Run demo
	move.w	.Demos(pc,d0.w),d0
	jmp	.Demos(pc,d0.w)

; ------------------------------------------------------------------------------

.Demos:
	dc.w	RunOpeningDemo-.Demos
	dc.w	RunDemo11A-.Demos
	dc.w	RunSpecialDemo1-.Demos
	dc.w	RunDemo43C-.Demos
	dc.w	RunSpecialDemo6-.Demos
	dc.w	RunDemo82A-.Demos
.DemosEnd:

; ------------------------------------------------------------------------------
; Palmtree Panic Act 1 Present demo
; ------------------------------------------------------------------------------

RunDemo11A:
	move.b	#0,nemesis_queue_flags				; Reset Nemesis queue flags
	move.w	#$000,zone_act					; Set stage to Palmtree Panic Act 1
	move.b	#TIME_PRESENT,time_zone				; Set time zone to present
	move.b	#0,good_future					; Reset good future flag
	
	move.w	#SYS_DEMO_11A,d0				; Run demo file
	bsr.w	RunMmd
	move.w	#0,demo_mode					; Reset demo mode flag
	rts

; ------------------------------------------------------------------------------
; Tidal Tempest Act 3 Good Future
; ------------------------------------------------------------------------------

RunDemo43C:
	move.b	#0,nemesis_queue_flags				; Reset Nemesis queue flags
	move.w	#$202,zone_act					; Set stage to Tidal Tempest Act 3
	move.b	#TIME_FUTURE,time_zone				; Set time zone to present
	move.b	#1,good_future					; Set good future flag
	
	move.w	#SYS_DEMO_43C,d0				; Run demo file
	bsr.w	RunMmd
	move.w	#0,demo_mode					; Reset demo mode flag
	rts

; ------------------------------------------------------------------------------
; Metallic Madness Act 2 Present
; ------------------------------------------------------------------------------

RunDemo82A:
	move.b	#0,nemesis_queue_flags				; Reset Nemesis queue flags
	move.w	#$601,zone_act					; Set stage to Metallic Madness Act 2
	move.b	#TIME_PRESENT,time_zone				; Set time zone to present
	move.b	#0,good_future					; Reset good future flag
	
	move.w	#SYS_DEMO_82A,d0				; Run demo file
	bsr.w	RunMmd
	move.w	#0,demo_mode					; Reset demo mode flag
	rts

; ------------------------------------------------------------------------------
; Special Stage 1 demo
; ------------------------------------------------------------------------------

RunSpecialDemo1:
	move.w	#SYS_SPECIAL_RESET,d0				; Reset special stage flags
	bsr.w	SubCpuCommand
	bra.w	SpecialStage1Demo				; Run demo file

; ------------------------------------------------------------------------------
; Special Stage 6 demo
; ------------------------------------------------------------------------------

RunSpecialDemo6:
	move.w	#SYS_SPECIAL_RESET,d0				; Reset special stage flags
	bsr.w	SubCpuCommand
	bra.w	SpecialStage6Demo				; Run demo file

; ------------------------------------------------------------------------------
; Opening FMV
; ------------------------------------------------------------------------------

RunOpeningDemo:
	move.w	#SYS_OPENING,d0					; Run opening FMV
	bsr.w	RunMmd

	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	RunOpeningDemo					; If so, loop
	rts
	
; ------------------------------------------------------------------------------
