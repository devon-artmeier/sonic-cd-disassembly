; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Main CPU Backup RAM functions
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Run Backup Backup RAM cartridge command
; ------------------------------------------------------------------------------

CartBuramCommand:
	moveq	#0,d0						; Get command ID
	move.b	buram_command,d0
	beq.s	.End						; If it's zero, branch
	
	subq.w	#1,d0						; Make command ID zero based
	cmpi.w	#(.CommandsEnd-.Commands)/2,d0			; Is it too large?
	bcc.s	.Error						; If so, branch

	add.w	d0,d0						; Run command
	lea	.Commands,a0
	move.w	(a0,d0.w),d0
	moveq	#0,d1
	jsr	(a0,d0.w)
	bcs.s	.Error						; If an error occured, branch

	move.b	#0,buram_status					; Mark as a success
	bra.s	.GetReturnVals

.Error:
	move.b	#-1,buram_status				; Mark as a failure

.GetReturnVals:
	move.w	d0,buram_d0					; Store return values
	move.w	d1,buram_d1
	
	clr.b	buram_command					; Mark command as completed

.End:
	rts

; ------------------------------------------------------------------------------

.Commands:
	dc.w	InitCartBuram-.Commands	
	dc.w	GetCartBuramStatus-.Commands
	dc.w	SearchCartBuram-.Commands
	dc.w	ReadCartBuram-.Commands	
	dc.w	WriteCartBuram-.Commands
	dc.w	DeleteCartBuram-.Commands
	dc.w	FormatCartBuram-.Commands
	dc.w	GetCartBuramDirectory-.Commands
	dc.w	VerifyCartBuram-.Commands
	; Missing save data read command
	; Missing save data write command
.CommandsEnd:

; ------------------------------------------------------------------------------
; Initialize cartridge Backup RAM interaction
; ------------------------------------------------------------------------------

InitCartBuram:
	lea	CartBuramScratch,a0				; Initialize Backup RAM
	lea	CartBuramStrings,a1
	moveq	#BRMINIT,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Get cartridge Backup RAM status	
; ------------------------------------------------------------------------------

GetCartBuramStatus:
	moveq	#BRMSTAT,d0					; Get Backup RAM status
	movea.l	#CartBuramStrings,a1
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Search cartridge Backup RAM
; ------------------------------------------------------------------------------

SearchCartBuram:
	movea.l	#buram_params,a0				; Search Backup RAM
	move.b	#0,buram_param.misc(a0)
	move.l	#0,buram_param.misc+1(a0)
	moveq	#BRMSERCH,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Read from cartridge Backup RAM
; ------------------------------------------------------------------------------

ReadCartBuram:
	movea.l	#buram_params,a0				; Read Backup RAM
	move.b	#0,buram_param.misc(a0)
	move.l	#0,buram_param.misc+1(a0)
	movea.l	#buram_data,a1
	moveq	#BRMREAD,d0
	jsr	_BURAM
	rts

; ------------------------------------------------------------------------------
; Write to cartridge Backup RAM
; ------------------------------------------------------------------------------

WriteCartBuram:
	movea.l	#buram_params,a0				; Write Backup RAM
	move.b	buram_write_flag,buram_param.flag(a0)
	move.w	buram_block_size,buram_param.block_size(a0)
	movea.l	#buram_data,a1
	moveq	#BRMWRITE,d0
	jsr	_BURAM
	rts

; ------------------------------------------------------------------------------
; Delete cartridge Backup RAM
; ------------------------------------------------------------------------------

DeleteCartBuram:
	movea.l	#buram_params,a0				; Delete Backup RAM
	move.b	#0,buram_param.misc(a0)
	move.l	#0,buram_param.misc+1(a0)
	moveq	#BRMDEL,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Format cartridge Backup RAM
; ------------------------------------------------------------------------------

FormatCartBuram:
	moveq	#BRMFORMAT,d0					; Format Backup RAM
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Get cartridge Backup RAM directory
; ------------------------------------------------------------------------------

GetCartBuramDirectory:
	movea.l	#buram_params,a0				; Get Backup RAM directory
	move.b	#0,buram_param.misc(a0)
	move.l	#0,buram_param.misc+1(a0)
	movea.l	#buram_data+4,a1
	move.l	buram_data,d1
	moveq	#BRMDIR,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Verify cartridge Backup RAM
; ------------------------------------------------------------------------------

VerifyCartBuram:
	movea.l	#buram_params,a0				; Verify Backup RAM
	move.b	buram_write_flag,buram_param.flag(a0)
	move.w	buram_block_size,buram_param.block_size(a0)
	movea.l	#buram_data,a1
	moveq	#BRMVERIFY,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Backup RAM data
; ------------------------------------------------------------------------------

CartBuramScratch:
	dcb.b	$640*2, 0					; Cartridge scratch RAM

CartBuramStrings:	
	dcb.b	$C, 0						; Cartridge display strings

	include	"Backup RAM/Initial Data.asm"			; Initial data

; ------------------------------------------------------------------------------
; Get type of Backup RAM to use
; ------------------------------------------------------------------------------

GetBuramType:
	bsr.w	CheckBuramCartridge				; Check if a Backup RAM cartridge was found
	bne.s	.SetType					; If so, branch
	clr.b	d0						; Use internal Backup RAM

.SetType:
	move.b	d0,buram_type					; Set type
	rts

; ------------------------------------------------------------------------------
; Check which kind of Backup RAM is being used
; ------------------------------------------------------------------------------

CheckBuramType:
	tst.b	buram_type					; Check Backup RAM type
	rts

; ------------------------------------------------------------------------------
; Check if a Backup RAM cartridge was found
; ------------------------------------------------------------------------------

CheckBuramCartridge:
	tst.b	buram_cart_found				; Check if RAM cartride was found
	rts

; ------------------------------------------------------------------------------
; Initialize and read save data
; ------------------------------------------------------------------------------

InitReadSaveData:
	bsr.w	InitBuram					; Initialize Backup RAM interaction
	bsr.w	InitBuramParams					; Set up parameters
	bsr.w	CallReadSaveData				; Read save data
	rts

; ------------------------------------------------------------------------------
; Write save data
; ------------------------------------------------------------------------------

CallWriteSaveData:
	bra.w	WriteSaveData					; Write save data

; ------------------------------------------------------------------------------
; Read save data
; ------------------------------------------------------------------------------

CallReadSaveData:
	bra.w	ReadSaveData					; Read save data

; ------------------------------------------------------------------------------
; Initialize save data
; ------------------------------------------------------------------------------

InitSaveData:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	
	lea	SaveDataTimeAttack,a0				; Setup time attack save data
	lea	buram_data,a1
	move.w	#save.attack_struct_size/4-1,d0

.SetupTimeAttackData:
	move.l	(a0)+,(a1)+
	dbf	d0,.SetupTimeAttackData

	lea	SaveDataMain,a0					; Setup main save data
	lea	buram_data+save.attack_struct_size,a1
	move.w	#save.main_struct_size/4-1,d0

.SetupMainData:
	move.l	(a0)+,(a1)+
	dbf	d0,.SetupMainData

	move.b	#0,buram_write_flag				; Set Backup RAM write flag
	move.w	#$B,buram_block_size				; Set Backup RAM block size
	rts

; ------------------------------------------------------------------------------
; Initialize Backup RAM parameters
; ------------------------------------------------------------------------------

InitBuramParams:
	move.b	#0,buram_write_flag				; Set Backup RAM write flag
	move.w	#$B,buram_block_size				; Set Backup RAM block size
	
	lea	.FileName,a0					; Set file name
	bra.s	SetBuramFilename

.FileName:
	dc.b	"SONICCD____"
	even

; ------------------------------------------------------------------------------
; Set Backup RAM file name
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to file name
; ------------------------------------------------------------------------------

SetBuramFileName:
	movem.l	a0-a1,-(sp)					; Save registers
	movea.l	#buram_params,a1				; Copy file name
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	movem.l	(sp)+,a0-a1					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Run Backup RAM command
; ------------------------------------------------------------------------------

RunBuramCommand:
	bsr.w	CheckBuramType					; Check which type of Backup RAM we are using
	bne.s	.BuramCart					; If we are using a Backup RAM cartridge, branch
	
	move.b	save_disabled,buram_disabled			; Copy save disabled flag
	jsr	GiveWordRamAccess				; Run the command
	jsr	WaitWordRamAccess				; Wait for the command to finish
	bra.s	.CheckStatus

.BuramCart:
	bsr.w	CartBuramCommand				; Run Backup RAM cartridge command

.CheckStatus:
	tst.b	buram_status					; Check status
	rts

; ------------------------------------------------------------------------------
; Initialize Backup RAM interaction
; ------------------------------------------------------------------------------
; RETURNS:
;	d0.w - Status
;	        0 = Using Backup RAM cartridge
;	        1 = Using internal Backup RAM
;	       -1 = Internal Backup RAM unformatted
;	       -2 = Backup RAM cartridge unformatted
; ------------------------------------------------------------------------------

InitBuram:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	
	bsr.w	DetectBuramCartridge				; Detect Backup RAM cartridge
	bne.w	.NoBuramCart					; If there is no Backup RAM cartridge, branch
	
	move.b	#BURAM_TYPE_CART,buram_type			; Set Backup RAM type to Backup RAM cartridge
	move.b	#BURAM_CMD_INIT,buram_command			; Initialize Backup RAM interaction
	bsr.s	RunBuramCommand
	
	tst.b	buram_status					; Was it a success?
	beq.s	.FoundBuramCart					; If so, branch
	tst.w	buram_d1					; Is the Backup RAM cartridge unformatted?
	bne.s	.CartUnformatted				; If so, branch

.NoBuramCart:
	move.b	#0,buram_cart_found				; Backup RAM cartridge not found
	bra.s	.InitInternal					; Initialize internal Backup RAM interaction

.FoundBuramCart:
	bsr.w	GetBuramStatus					; Get Backup RAM status
	move.b	#1,buram_cart_found				; Backup RAM cartridge found

.InitInternal:
	move.b	#BURAM_TYPE_INTERNAL,buram_type			; Set Backup RAM type to internal
	move.b	#BURAM_CMD_INIT,buram_command			; Initialize Backup RAM interaction
	bsr.w	RunBuramCommand
	
	tst.b	buram_status					; Was it a success?
	bne.s	.Unformatted					; If not, branch
	bsr.w	GetBuramStatus					; Get Backup RAM status
	
	tst.b	buram_cart_found				; Was a Backup RAM cartridge found?
	beq.s	.NoBuramCart2					; If not, branch
	move.w	#0,d0						; Using Backup RAM cartridge
	rts

.NoBuramCart2:
	move.w	#1,d0						; Using internal Backup RAM
	move.w	#0,d1
	rts

.Unformatted:
	move.w	#-1,d0						; Internal Backup RAM unformatted
	rts

.CartUnformatted:
	move.w	#-2,d0						; Backup RAM cartridge unformatted
	rts

; ------------------------------------------------------------------------------
; Detect Backup RAM cartridge
; ------------------------------------------------------------------------------
; RETURNS:
;	eq/ne - Found/Not found
;	d0.l  - Status
;	         0 = Found
;	        -1 = Not found
; ------------------------------------------------------------------------------

DetectBuramCartridge:
	btst	#7,BURAM_CART_ID				; Is there a special Backup RAM cartridge?
	beq.s	.NormalBuramCart				; If not, branch

	lea	SPECIAL_CART_ID,a0				; Check special cartridge
	lea	.RamSignature,a1
	moveq	#12/4-1,d0

.CheckSpecialCart:
	cmpm.l	(a0)+,(a1)+					; Is the signature present?
	bne.s	.NormalBuramCart				; If not, branch
	dbf	d0,.CheckSpecialCart				; Loop until finished

	movea.l	#_BURAM,a0					; Run special cart entry code
	jsr	SPECIAL_CART_START
	bra.w	.Found						; Mark as found

.NormalBuramCart:
	btst	#7,BURAM_CART_ID				; Were we just checking for special Backup RAM cartridge data?
	bne.w	.NotFound					; If so, branch

	move.b	BURAM_CART_ID,d0				; Get size of cartridge data
	andi.l	#7,d0
	move.l	#$2000,d1
	lsl.l	d0,d1
	lsl.l	#1,d1						; Data is stored every other byte

	lea	BURAM_CART_DATA-($40*2)-1,a2			; Go to end of cartridge data
	adda.l	d1,a2
	
	movea.l	a2,a0						; Check normal Backup RAM cartridge
	adda.w	#$30*2,a0
	lea	.RamSignature,a1

	movep.l	1(a0),d1					; Is the signature present?
	cmp.l	(a1),d1
	bne.w	.NoSignature					; If not, branch
	
	movep.l	1+(4*2)(a0),d1					; Is the signature present?
	cmp.l	4(a1),d1
	bne.w	.NoSignature					; If not, branch
	
	movep.l	1+(8*2)(a0),d1					; Is the signature present?
	cmp.l	8(a1),d1
	bne.w	.NoSignature					; If not, branch

	movea.l	a2,a0						; Check format signature
	adda.w	#$20*2,a0
	lea	.FormatSig,a1

	movep.l	1(a0),d1					; Is the signature present?
	cmp.l	(a1),d1
	bne.w	.NoSignature					; If it's not present, branch

	movep.l	1+(4*2)(a0),d1					; Is the signature present?
	cmp.l	4(a1),d1
	bne.w	.NoSignature					; If it's not present, branch

	movep.l	1+(8*2)(a0),d1					; Is the signature present?
	cmp.l	8(a1),d1
	bne.w	.NoSignature					; If it's not present, branch
	
	bra.w	.Found						; Mark as found

.NoSignature:
	bset	#0,BURAM_CART_PROTECT				; Enable writing
	lea	BURAM_CART_DATA,a0				; Backup RAM cartridge data
	move.b	(a0),d0						; Save first byte
	
	move.b	#$5A,(a0)					; Write random value
	cmpi.b	#$5A,(a0)					; Was it written?
	bne.s	.WriteFailed					; If not, branch
	
	move.b	#$A5,(a0)					; Write another random value
	cmpi.b	#$A5,(a0)					; Was it written?
	bne.s	.WriteFailed					; If not, branch

	move.b	d0,(a0)						; Restore first byte
	bclr	#0,BURAM_CART_PROTECT				; Disable writing
	bra.s	.Found2						; Mark as found

.WriteFailed:
	bclr	#0,BURAM_CART_PROTECT				; Disable writing
	bra.s	.NotFound					; Mark as not found

.Found:
	moveq	#0,d0						; Mark as found
	rts

.Found2:
	moveq	#0,d0						; Mark as found
	rts

.NotFound:
	moveq	#-1,d0						; Mark as not found
	rts

; ------------------------------------------------------------------------------

.RamSignature:
	dc.b	"RAM_CARTRIDG"
	even

.FormatSig:
	dc.b	"SEGA_CD_ROM"
	even

; ------------------------------------------------------------------------------
; Get Backup RAM directory
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - H: Number of files to skip when all files can't be read
;	          read in one try
;	       L: Size of directory buffer
; ------------------------------------------------------------------------------

GetBuramDirectory:
	move.l	d0,-(sp)					; Wait for Word RAM access
	jsr	WaitWordRamAccess
	move.l	(sp)+,d0

	move.l	d0,buram_data					; Set parameters
	lea	.Template,a0					; Set template file name
	bsr.w	SetBuramFileName

	move.b	#BURAM_CMD_DIRECTORY,buram_command		; Get directory
	bra.w	RunBuramCommand

; ------------------------------------------------------------------------------

.Template:
	dc.b	"***********"
	even

; ------------------------------------------------------------------------------
; Get Backup RAM status
; ------------------------------------------------------------------------------

GetBuramStatus:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	move.b	#BURAM_CMD_STATUS,buram_command			; Get Backup RAM status
	bra.w	RunBuramCommand

; ------------------------------------------------------------------------------
; Search Backup RAM
; ------------------------------------------------------------------------------

SearchBuram:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	move.b	#BURAM_CMD_SEARCH,buram_command			; Get Backup RAM status
	bra.w	RunBuramCommand

; ------------------------------------------------------------------------------
; Read Backup RAM
; ------------------------------------------------------------------------------

ReadBuram:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	move.b	#BURAM_CMD_READ,buram_command			; Read Backup RAM data
	bra.w	RunBuramCommand

; ------------------------------------------------------------------------------
; Read save data
; ------------------------------------------------------------------------------

ReadSaveData:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	move.b	#BURAM_CMD_READ_SAVE,buram_command		; Read save data
	bra.w	RunBuramCommand

; ------------------------------------------------------------------------------
; Write Backup RAM
; ------------------------------------------------------------------------------

WriteBuram:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	move.b	#BURAM_CMD_WRITE,buram_command			; Write Backup RAM data
	bsr.w	RunBuramCommand
	bne.s	.End						; If it failed, branch
	bsr.w	VerifyBuram					; Verify Backup RAM

.End:
	rts

; ------------------------------------------------------------------------------
; Write save data
; ------------------------------------------------------------------------------

WriteSaveData:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	move.b	#BURAM_CMD_WRITE_SAVE,buram_command		; Write save data
	bsr.w	RunBuramCommand
	rts

; ------------------------------------------------------------------------------
; Delete Backup RAM
; ------------------------------------------------------------------------------

DeleteBuram:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	move.b	#BURAM_CMD_DELETE,buram_command			; Delete Backup RAM
	bra.w	RunBuramCommand

; ------------------------------------------------------------------------------
; Format Backup RAM
; ------------------------------------------------------------------------------

FormatBuram:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	move.b	#BURAM_CMD_FORMAT,buram_command			; Format Backup RAM
	bra.w	RunBuramCommand

; ------------------------------------------------------------------------------
; Verify Backup RAM
; ------------------------------------------------------------------------------

VerifyBuram:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	move.b	#BURAM_CMD_VERIFY,buram_command			; Verify Backup RAM
	bra.w	RunBuramCommand

; ------------------------------------------------------------------------------
