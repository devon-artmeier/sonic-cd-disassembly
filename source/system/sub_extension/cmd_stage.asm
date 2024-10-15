; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"
	include	"system_symbols.inc"
	include	"pcm_driver.inc"

	section code
	
	xref WaitWordRamAccess, ResetCddaVolume, GiveWordRamAccess
	xref Round11AFile, Round11BFile, Round11CFile, Round11DFile
	xref Round12AFile, Round12BFile, Round12CFile, Round12DFile
	xref Round13CFile, Round13DFile, Demo11AFile, PcmDriverR1BFile
	xref Round31AFile, Round31BFile, Round31CFile, Round31DFile
	xref Round32AFile, Round32BFile, Round32CFile, Round32DFile
	xref Round33CFile, Round33DFile, PcmDriverR3BFile
	xref Round41AFile, Round41BFile, Round41CFile, Round41DFile
	xref Round42AFile, Round42BFile, Round42CFile, Round42DFile
	xref Round43CFile, Round43DFile, Demo43CFile, PcmDriverR4BFile
	xref Round51AFile, Round51BFile, Round51CFile, Round51DFile
	xref Round52AFile, Round52BFile, Round52CFile, Round52DFile
	xref Round53CFile, Round53DFile, PcmDriverR5BFile
	xref Round61AFile, Round61BFile, Round61CFile, Round61DFile
	xref Round62AFile, Round62BFile, Round62CFile, Round62DFile
	xref Round63CFile, Round63DFile, PcmDriverR6BFile
	xref Round71AFile, Round71BFile, Round71CFile, Round71DFile
	xref Round72AFile, Round72BFile, Round72CFile, Round72DFile
	xref Round73CFile, Round73DFile, PcmDriverR7BFile
	xref Round81AFile, Round81BFile, Round81CFile, Round81DFile
	xref Round82AFile, Round82BFile, Round82CFile, Round82DFile
	xref Round83CFile, Round83DFile, Demo82AFile, PcmDriverR8BFile
	xref PcmDriverBoss

; ------------------------------------------------------------------------------
; Load stage
; ------------------------------------------------------------------------------

	xdef LoadStage
LoadStage:
	add.w	d1,d1						; Get stage file based on command ID
	lea	.StageFiles(pc),a1
	move.w	(a1,d1.w),d2
	lea	(a1,d2.w),a0
	move.l	d1,-(sp)

	bsr.w	WaitWordRamAccess				; Load stage file
	lea	WORD_RAM_2M,a1
	jsr	LoadFile

	bsr.w	ResetCddaVolume					; Reset CD audio volume
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	move.l	(sp)+,d1					; Get PCM driver file based on command ID
	add.w	d1,d1
	lea	.PcmDrivers(pc),a1
	move.l	cur_pcm_driver,d0
	cmp.l	(a1,d1.w),d0					; Is this PCM driver already loaded?
	beq.s	.Done						; If so, branch

	movea.l	(a1,d1.w),a0					; If not, load it
	move.l	a0,cur_pcm_driver
	lea	PcmDriver,a1
	jsr	LoadFile

.Done:
	bset	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Enable timer interrupt
	bra.w	GiveWordRamAccess				; Give Main CPU Word RAM access

; ------------------------------------------------------------------------------
; Stage files
; ------------------------------------------------------------------------------

.StageFiles:
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Palmtree Panic Act 1 Present
	dc.w	Round11BFile-.StageFiles			; Palmtree Panic Act 1 Past
	dc.w	Round11CFile-.StageFiles			; Palmtree Panic Act 1 Good Future
	dc.w	Round11DFile-.StageFiles			; Palmtree Panic Act 1 Bad Future
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round12AFile-.StageFiles			; Palmtree Panic Act 2 Present
	dc.w	Round12BFile-.StageFiles			; Palmtree Panic Act 2 Past
	dc.w	Round12CFile-.StageFiles			; Palmtree Panic Act 2 Good Future
	dc.w	Round12DFile-.StageFiles			; Palmtree Panic Act 2 Bad Future
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Demo43CFile-.StageFiles				; Tidal Tempest Act 3 Good Future demo
	dc.w	Demo82AFile-.StageFiles				; Metallic Madness Act 2 Present demo
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round31AFile-.StageFiles			; Collision Chaos Act 1 Present
	dc.w	Round31BFile-.StageFiles			; Collision Chaos Act 1 Past
	dc.w	Round31CFile-.StageFiles			; Collision Chaos Act 1 Good Future
	dc.w	Round31DFile-.StageFiles			; Collision Chaos Act 1 Bad Future
	dc.w	Round32AFile-.StageFiles			; Collision Chaos Act 2 Present 
	dc.w	Round32BFile-.StageFiles			; Collision Chaos Act 2 Past 
	dc.w	Round32CFile-.StageFiles			; Collision Chaos Act 2 Good Future 
	dc.w	Round32DFile-.StageFiles			; Collision Chaos Act 2 Bad Future 
	dc.w	Round33CFile-.StageFiles			; Collision Chaos Act 3 Good Future 
	dc.w	Round33DFile-.StageFiles			; Collision Chaos Act 3 Bad Future 
	dc.w	Round13CFile-.StageFiles			; Palmtree Panic Act 3 Good Future
	dc.w	Round13DFile-.StageFiles			; Palmtree Panic Act 3 Bad Future 
	dc.w	Round41AFile-.StageFiles			; Tidal Tempest Act 1 Present
	dc.w	Round41BFile-.StageFiles			; Tidal Tempest Act 1 Past
	dc.w	Round41CFile-.StageFiles			; Tidal Tempest Act 1 Good Future
	dc.w	Round41DFile-.StageFiles			; Tidal Tempest Act 1 Bad Future
	dc.w	Round42AFile-.StageFiles			; Tidal Tempest Act 2 Present 
	dc.w	Round42BFile-.StageFiles			; Tidal Tempest Act 2 Past 
	dc.w	Round42CFile-.StageFiles			; Tidal Tempest Act 2 Good Future 
	dc.w	Round42DFile-.StageFiles			; Tidal Tempest Act 2 Bad Future 
	dc.w	Round43CFile-.StageFiles			; Tidal Tempest Act 3 Good Future 
	dc.w	Round43DFile-.StageFiles			; Tidal Tempest Act 3 Bad Future 
	dc.w	Round51AFile-.StageFiles			; Quartz Quadrant Act 1 Present
	dc.w	Round51BFile-.StageFiles			; Quartz Quadrant Act 1 Past
	dc.w	Round51CFile-.StageFiles			; Quartz Quadrant Act 1 Good Future
	dc.w	Round51DFile-.StageFiles			; Quartz Quadrant Act 1 Bad Future
	dc.w	Round52AFile-.StageFiles			; Quartz Quadrant Act 2 Present 
	dc.w	Round52BFile-.StageFiles			; Quartz Quadrant Act 2 Past 
	dc.w	Round52CFile-.StageFiles			; Quartz Quadrant Act 2 Good Future 
	dc.w	Round52DFile-.StageFiles			; Quartz Quadrant Act 2 Bad Future 
	dc.w	Round53CFile-.StageFiles			; Quartz Quadrant Act 3 Good Future 
	dc.w	Round53DFile-.StageFiles			; Quartz Quadrant Act 3 Bad Future 
	dc.w	Round61AFile-.StageFiles			; Wacky Workbench Act 1 Present
	dc.w	Round61BFile-.StageFiles			; Wacky Workbench Act 1 Past
	dc.w	Round61CFile-.StageFiles			; Wacky Workbench Act 1 Good Future
	dc.w	Round61DFile-.StageFiles			; Wacky Workbench Act 1 Bad Future
	dc.w	Round62AFile-.StageFiles			; Wacky Workbench Act 2 Present 
	dc.w	Round62BFile-.StageFiles			; Wacky Workbench Act 2 Past 
	dc.w	Round62CFile-.StageFiles			; Wacky Workbench Act 2 Good Future 
	dc.w	Round62DFile-.StageFiles			; Wacky Workbench Act 2 Bad Future 
	dc.w	Round63CFile-.StageFiles			; Wacky Workbench Act 3 Good Future 
	dc.w	Round63DFile-.StageFiles			; Wacky Workbench Act 3 Bad Future 
	dc.w	Round71AFile-.StageFiles			; Stardust Speedway Act 1 Present
	dc.w	Round71BFile-.StageFiles			; Stardust Speedway Act 1 Past
	dc.w	Round71CFile-.StageFiles			; Stardust Speedway Act 1 Good Future
	dc.w	Round71DFile-.StageFiles			; Stardust Speedway Act 1 Bad Future
	dc.w	Round72AFile-.StageFiles			; Stardust Speedway Act 2 Present 
	dc.w	Round72BFile-.StageFiles			; Stardust Speedway Act 2 Past 
	dc.w	Round72CFile-.StageFiles			; Stardust Speedway Act 2 Good Future 
	dc.w	Round72DFile-.StageFiles			; Stardust Speedway Act 2 Bad Future 
	dc.w	Round73CFile-.StageFiles			; Stardust Speedway Act 3 Good Future 
	dc.w	Round73DFile-.StageFiles			; Stardust Speedway Act 3 Bad Future 
	dc.w	Round81AFile-.StageFiles			; Metallic Madness Act 1 Present
	dc.w	Round81BFile-.StageFiles			; Metallic Madness Act 1 Past
	dc.w	Round81CFile-.StageFiles			; Metallic Madness Act 1 Good Future
	dc.w	Round81DFile-.StageFiles			; Metallic Madness Act 1 Bad Future
	dc.w	Round82AFile-.StageFiles			; Metallic Madness Act 2 Present 
	dc.w	Round82BFile-.StageFiles			; Metallic Madness Act 2 Past 
	dc.w	Round82CFile-.StageFiles			; Metallic Madness Act 2 Good Future 
	dc.w	Round82DFile-.StageFiles			; Metallic Madness Act 2 Bad Future 
	dc.w	Round83CFile-.StageFiles			; Metallic Madness Act 3 Good Future 
	dc.w	Round83DFile-.StageFiles			; Metallic Madness Act 3 Bad Future 
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Demo11AFile-.StageFiles				; Palmtree Panic Act 1 Present demo
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid

; ------------------------------------------------------------------------------
; PCM drivers
; ------------------------------------------------------------------------------

.PcmDrivers:
	dc.l	Round11AFile					; Invalid
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 1 Present
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 1 Past
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 1 Good Future
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 1 Bad Future
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 2 Present
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 2 Past
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 2 Good Future
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 2 Bad Future
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	PcmDriverBoss					; Tidal Tempest Act 3 Good Future demo
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 2 Present demo
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 1 Present
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 1 Past
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 1 Good Future
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 1 Bad Future
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 2 Present 
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 2 Past 
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 2 Good Future 
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 2 Bad Future 
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 3 Good Future 
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 3 Bad Future 
	dc.l	PcmDriverBoss					; Palmtree Panic Act 3 Good Future
	dc.l	PcmDriverBoss					; Palmtree Panic Act 3 Bad Future 
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 1 Present
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 1 Past
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 1 Good Future
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 1 Bad Future
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 2 Present 
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 2 Past 
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 2 Good Future 
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 2 Bad Future 
	dc.l	PcmDriverBoss					; Tidal Tempest Act 3 Good Future 
	dc.l	PcmDriverBoss					; Tidal Tempest Act 3 Bad Future 
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 1 Present
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 1 Past
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 1 Good Future
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 1 Bad Future
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 2 Present 
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 2 Past 
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 2 Good Future 
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 2 Bad Future 
	dc.l	PcmDriverBoss					; Quartz Quadrant Act 3 Good Future 
	dc.l	PcmDriverBoss					; Quartz Quadrant Act 3 Bad Future 
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 1 Present
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 1 Past
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 1 Good Future
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 1 Bad Future
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 2 Present 
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 2 Past 
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 2 Good Future 
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 2 Bad Future 
	dc.l	PcmDriverBoss					; Wacky Workbench Act 3 Good Future 
	dc.l	PcmDriverBoss					; Wacky Workbench Act 3 Bad Future 
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 1 Present
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 1 Past
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 1 Good Future
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 1 Bad Future
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 2 Present 
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 2 Past 
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 2 Good Future 
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 2 Bad Future 
	dc.l	PcmDriverBoss					; Stardust Speedway Act 3 Good Future 
	dc.l	PcmDriverBoss					; Stardust Speedway Act 3 Bad Future 
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 1 Present
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 1 Past
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 1 Good Future
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 1 Bad Future
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 2 Present 
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 2 Past 
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 2 Good Future 
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 2 Bad Future 
	dc.l	PcmDriverBoss					; Metallic Madness Act 3 Good Future 
	dc.l	PcmDriverBoss					; Metallic Madness Act 3 Bad Future 
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 1 Present demo
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid

; ------------------------------------------------------------------------------
