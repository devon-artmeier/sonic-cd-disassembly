; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"
	include	"system_symbols.inc"

	section code
	
	xref OpeningMainFile, WaitWordRamAccess, GiveWordRamAccess, OpeningSubFile
	xref EndingMainFile, BadEndingSubFile, GoodEndingSubFile

; ------------------------------------------------------------------------------
; Load opening FMV
; ------------------------------------------------------------------------------

	xdef LoadOpening
LoadOpening:
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	lea	OpeningMainFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	OpeningSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$30000,a1
	jsr	LoadFile

	jsr	PRG_RAM+$30000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	andi.b	#~(MCDR_RET|MCDR_MODE),MCD_MEM_MODE		; Set to 2M mode
	move.b	#MCDR_SUB_READ,MCD_CDC_DEVICE			; Set CDC device to "Sub CPU"
	move.l	#0,cur_pcm_driver				; Reset current PCM driver
	rts

; ------------------------------------------------------------------------------
; Load bad ending FMV
; ------------------------------------------------------------------------------

	xdef LoadBadEnding
LoadBadEnding:
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	lea	EndingMainFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	BadEndingSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$30000,a1				; GOODEND.BIN loads BADEND.STM. Seriously.
	jsr	LoadFile

	jsr	PRG_RAM+$30000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	andi.b	#~(MCDR_RET|MCDR_MODE),MCD_MEM_MODE		; Set to 2M mode
	move.b	#MCDR_SUB_READ,MCD_CDC_DEVICE			; Set CDC device to "Sub CPU"
	move.l	#0,cur_pcm_driver				; Reset current PCM driver
	rts

; ------------------------------------------------------------------------------
; Load good ending FMV
; ------------------------------------------------------------------------------

	xdef LoadGoodEnding
LoadGoodEnding:
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	lea	EndingMainFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	GoodEndingSubFile(pc),a0			; Load Sub CPU file
	lea	PRG_RAM+$30000,a1				; BADEND.BIN loads GOODEND.STM. Seriously.
	jsr	LoadFile

	jsr	PRG_RAM+$30000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	andi.b	#~(MCDR_RET|MCDR_MODE),MCD_MEM_MODE		; Set to 2M mode
	move.b	#MCDR_SUB_READ,MCD_CDC_DEVICE			; Set CDC device to "Sub CPU"
	move.l	#0,cur_pcm_driver				; Reset current PCM driver
	rts

; ------------------------------------------------------------------------------
