; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Section art load functions
; ------------------------------------------------------------------------------

LoadSectionArt:
	lea	SectionRanges(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	move.w	camera_fg_x,d0

.Loop:
	cmp.w	(a1)+,d0
	bcs.s	.LoadPLC
	addq.b	#2,d1
	bra.s	.Loop

.LoadPLC:
	move.b	d1,section_id
	move.w	SectionInitPLCs(pc,d1.w),d0
	jmp	LoadPLC

; ------------------------------------------------------------------------------

UpdateSectionArt:
	lea	SectionRanges(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	move.w	camera_fg_x,d0

.Loop:
	cmp.w	(a1)+,d0
	bcs.s	.FoundRange
	addq.b	#2,d1
	bra.s	.Loop

.FoundRange:
	cmp.b	section_id,d1
	bne.s	.LoadPLC
	rts

.LoadPLC:
	move.b	d1,section_id
	move.w	SectionUpdatePLCs(pc,d1.w),d0
	jmp	InitPLC

; ------------------------------------------------------------------------------
