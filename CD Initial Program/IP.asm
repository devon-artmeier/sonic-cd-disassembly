; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Initial program
; ------------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Main CPU.i"
	include	"_Include/System.i"
	include	"_Include/MMD.i"
	include	"CD System Program/Command IDs.i"

; ------------------------------------------------------------------------------
; Security block
; ------------------------------------------------------------------------------

	org	WORK_RAM

	if REGION=JAPAN
		incbin	"CD Initial Program/Security/Japan.bin"
	elseif REGION=USA
		incbin	"CD Initial Program/Security/USA.bin"
	else
		incbin	"CD Initial Program/Security/Europe.bin"
	endif

; ------------------------------------------------------------------------------
; Program
; ------------------------------------------------------------------------------

	move.l	#VBlankIrq,_LEVEL6+2				; Set V-BLANK interrupt address
	move.w	#_LEVEL4,MCD_USER_HBLANK			; Set H-BLANK interrupt address
	move.l	#HBlankIrq,_LEVEL4+2

.GiveWordRamAccess:
	bset	#1,MCD_MEM_MODE					; Give Word RAM access to the Sub CPU
	beq.s	.GiveWordRamAccess

	lea	MCD_MAIN_COMMS,a0				; Clear communication registers
	moveq	#0,d0
	move.b	d0,MCD_MAIN_FLAG-MCD_MAIN_COMMS(a0)
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+

	lea	LoadIpx(pc),a0					; Copy main program loader
	lea	WORK_RAM+$1000,a1
	move.w	#LoadIpxEnd-LoadIpx-1,d7

.CopyIpxLoader:
	move.b	(a0)+,(a1)+
	dbf	d7,.CopyIpxLoader

	jmp	WORK_RAM+$1000					; Go to main program loader

; ------------------------------------------------------------------------------
; IPX loader
; ------------------------------------------------------------------------------

LoadIpx:
	obj	WORK_RAM+$1000

	moveq	#SCMD_IPX,d0					; Load IPX file
	jsr	SubCpuCommand

	movea.l	WORD_RAM_2M+mmd.entry,a0			; Get entry address
	
	move.l	WORD_RAM_2M+mmd.origin,d0			; Get origin address
	beq.s	.GetHInt					; If it's not set, branch
	
	movea.l	d0,a2						; Copy file to origin address
	lea	WORD_RAM_2M+mmd.file,a1
	move.w	WORD_RAM_2M+mmd.size,d7

.CopyFile:
	move.l	(a1)+,(a2)+
	dbf	d7,.CopyFile

.GetHInt:
	move.l	WORD_RAM_2M+mmd.hblank,d0			; Get H-BLANK interrupt address
	beq.s	.GetVInt					; If it's not set, branch
	move.l	d0,_LEVEL4+2					; Set H-BLANK interrupt address

.GetVInt:
	move.l	WORD_RAM_2M+mmd.vblank,d0			; Get V-BLANK interrupt address
	beq.s	.GiveWordRamAccess				; If it's blank, branch
	move.l	d0,_LEVEL6+2					; Set V-BLANK interrupt address

.GiveWordRamAccess:
	bset	#1,MCD_MEM_MODE					; Give Word RAM access to the Sub CPU
	beq.s	.GiveWordRamAccess

	jmp	(a0)						; Go to main program

	objend
LoadIpxEnd:

; ------------------------------------------------------------------------------
; Send Sub CPU command
; ------------------------------------------------------------------------------

SubCpuCommand:
	move.w	d0,MCD_MAIN_COMM_0				; Set command ID

.WaitAck:
	tst.w	MCD_SUB_COMM_0					; Has the Sub CPU received the command?
	beq.s	.WaitAck					; If not, wait
	
	move.w	#0,MCD_MAIN_COMM_0				; Mark as ready to send commands again

.WaitDone:
	tst.w	MCD_SUB_COMM_0					; Is the Sub CPU done processing the command?
	bne.s	.WaitDone					; If not, wait
	rts

; ------------------------------------------------------------------------------
; V-INT
; ------------------------------------------------------------------------------

VBlankIrq:
	bset	#0,MCD_IRQ2					; Trigger Sub CPU IRQ2

HBlankIrq:
	rte

; ------------------------------------------------------------------------------
