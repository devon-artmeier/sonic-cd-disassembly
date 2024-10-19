; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_sub.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Unknown decompression routine
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to compressed data
;	a1.l - Pointer to destination buffer
; ------------------------------------------------------------------------------

	xdef UnkDecomp
UnkDecomp:
	movem.l	d0-a2,-(sp)					; Save registers

	lea	decomp_window,a2				; Decompression sliding window
	move.w	(a0)+,d7					; Get size of uncompressed data
	subq.w	#1,d7						; Subtract 1 for loop
	move.w	#(-$12)&$FFF,d2					; Set window position
	
	move.b	(a0)+,d1					; Get first description field
	move.w	#$FFF,d6					; Set window position mask
	moveq	#8,d0						; Number of bits in description field

.MainLoop:
	dbf	d0,.NextDescBit					; Loop until all flags have been scanned
	moveq	#8-1,d0						; Prepare next description field
	move.b	(a0)+,d1

.NextDescBit:
	lsr.b	#1,d1						; Get next description field bit
	bcc.s	.CopyFromWindow					; 0 | If we are copying from the window, branch

.CopyNextByte:
	move.b	(a0),(a1)+					; 1 | Copy next byte from archive
	move.b	(a0)+,(a2,d2.w)					; Store in window
	addq.w	#1,d2						; Advance window position
	and.w	d6,d2
	dbf	d7,.MainLoop					; Loop until all of the data is decompressed
	bra.s	.End						; Exit out

.CopyFromWindow:
	moveq	#0,d3
	move.b	(a0)+,d3					; Get low byte of window position
	move.b	(a0)+,d4					; Get high bits of window position and length
	
	move.w	d4,d5						; Combine window position bits
	andi.w	#$F0,d5
	lsl.w	#4,d5
	or.w	d5,d3

	andi.w	#$F,d4						; Isolate length
	addq.w	#3-1,d4						; Copy at least 3 bytes from window

.CopyWindowLoop:
	move.b	(a2,d3.w),d5					; Get byte from window
	move.b	d5,(a1)+					; Store in decompressed data buffer
	subq.w	#1,d7						; Decrement bytes left to decompress
	move.b	d5,(a2,d2.w)					; Store in window
	
	addq.w	#1,d3						; Advance copy position
	and.w	d6,d3
	addq.w	#1,d2						; Advance window position
	and.w	d6,d2

	dbf	d4,.CopyWindowLoop				; Loop until all bytes are copied
	tst.w	d7						; Are there any bytes left to decompress?
	bpl.s	.MainLoop					; If so, branch

.End:
	movem.l	(sp)+,d0-a2					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Mass copy
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Pointer to source data
;	a2.l - Pointer to destination buffer
; ------------------------------------------------------------------------------

	xdef Copy128
Copy128:
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	rts

; ------------------------------------------------------------------------------
; Wait for the graphics interrupt handler to run
; ------------------------------------------------------------------------------

	xdef WaitGraphicsIrq
WaitGraphicsIrq:
	move.b	#1,irq1_flag					; Set IRQ1 flag
	move	#$2000,sr					; Enable interrupts

.Wait:
	tst.b	irq1_flag					; Has the interrupt handler been run?
	bne.s	.Wait						; If not, wait
	rts

; ------------------------------------------------------------------------------
; Sync with Main CPU
; ------------------------------------------------------------------------------

	xdef SyncWithMainCpu
SyncWithMainCpu:
	tst.w	MCD_MAIN_COMM_2					; Are we synced with the Main CPU?
	bne.s	SyncWithMainCpu					; If not, wait
	rts

; ------------------------------------------------------------------------------
; Give Main CPU Word RAM access
; ------------------------------------------------------------------------------

	xdef GiveWordRamAccess
GiveWordRamAccess:
	bset	#MCDR_RET_BIT,MCD_MEM_MODE			; Give Main CPU Word RAM access
	btst	#MCDR_RET_BIT,MCD_MEM_MODE			; Has it been given?
	beq.s	GiveWordRamAccess				; If not, wait
	rts

; ------------------------------------------------------------------------------
; Wait for Word RAM access
; ------------------------------------------------------------------------------

	xdef WaitWordRamAccess
WaitWordRamAccess:
	btst	#MCDR_DMNA_BIT,MCD_MEM_MODE			; Do we have Word RAM access?
	beq.s	WaitWordRamAccess				; If not, wait
	rts

; ------------------------------------------------------------------------------
; Load source image map
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Pointer to source data
;	a2.l - Pointer to destination buffer
;	d1.w - Width (minus 1)
;	d2.w - Height (minus 1)
; ------------------------------------------------------------------------------

	xdef LoadSourceImageMap
LoadSourceImageMap:
	move.l	#$100,d4					; Stride

.SetupRow:
	movea.l	d0,a2						; Set row pointer
	move.w	d1,d3						; Set row width

.RowLoop:
	move.w	(a1)+,d5					; Get data
	lsl.w	#2,d5
	move.w	d5,(a2)+					; Store it
	dbf	d3,.RowLoop					; Loop until row is written
	add.l	d4,d0						; Next row
	dbf	d2,.SetupRow					; Loop until all data is written
	rts

; ------------------------------------------------------------------------------
