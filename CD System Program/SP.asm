; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; System program
; ------------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Sub CPU.i"
	include	"_Include/System.i"
	include	"_Include/Backup RAM.i"

; ------------------------------------------------------------------------------
; Header
; ------------------------------------------------------------------------------

	org SP_START
SpHeader:
	dc.b	'MAIN       ', 0
	dc.w	0, 0
	dc.l	0
	dc.l	SpEnd-SpHeader
	dc.l	SpHeaderOffsets-SpHeader
	dc.l	0

; ------------------------------------------------------------------------------
; Offsets
; ------------------------------------------------------------------------------

SpHeaderOffsets:
	dc.w	Initialize-SpHeaderOffsets			; Initialization
	dc.w	Main-SpHeaderOffsets				; Main
	dc.w	MegaDriveIrq-SpHeaderOffsets			; Mega Drive interrupt
	dc.w	UserCall-SpHeaderOffsets			; User call
	dc.w	0

; ------------------------------------------------------------------------------
; Initialization
; ------------------------------------------------------------------------------

Initialize:
	lea	MCD_SUB_COMMS,a0				; Clear communication registers
	moveq	#0,d0
	move.b	d0,MCD_SUB_FLAG-MCD_SUB_COMMS(a0)
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+

	lea	DriveInitParams(pc),a0				; Initialzie drive
	move.w	#DRVINIT,d0
	jsr	_CDBIOS

.WaitReady:
	move.w	#CDBSTAT,d0					; Is the BIOS ready?
	jsr	_CDBIOS
	andi.b	#BIOS_BUSY_MASK,_CDSTAT
	bne.s	.WaitReady					; If not, wait

	andi.b	#~(MCDR_RET|MCDR_MODE),MCD_MEM_MODE		; Set to 2M mode
	
	move.w	#FILE_INIT,d0					; Initialize file engine
	jsr	FileFunction.l

UserCall:
	rts

; ------------------------------------------------------------------------------

DriveInitParams:
	dc.b	1, $FF

SpxFile:
	dc.b	"SPX___.BIN;1", 0
	even

; ------------------------------------------------------------------------------
; Main
; ------------------------------------------------------------------------------

Main:
	move.w	#FILE_GET_FILES,d0				; Get files
	jsr	FileFunction.l

.Wait:
	jsr	_WAITVSYNC					; VSync

	move.w	#FILE_STATUS,d0					; Is the operation finished?
	jsr	FileFunction.l
	bcs.s	.Wait						; If not, wait

	cmpi.w	#FILE_STATUS_OK,d0				; Was the operation a success?
	bne.w	.Error						; If not, branch

	lea	SpxFile(pc),a0					; Load SPX file
	lea	Spx,a1
	jsr	LoadFile

	lea	Stack,sp					; Set stack pointer
	jmp	SpxStart					; Go to SPX

.Error:
	nop							; Loop here forever
	nop
	bra.s	.Error

; ------------------------------------------------------------------------------
; Variables
; ------------------------------------------------------------------------------

	ALIGN	SpVariables

; ------------------------------------------------------------------------------
; Temporary save data buffer
; ------------------------------------------------------------------------------

	ALIGN	SaveDataTemp
	include	"Backup RAM/Initial Data.asm"

; ------------------------------------------------------------------------------
; IRQ2
; ------------------------------------------------------------------------------

	ALIGN	MegaDriveIrq
	movem.l	d0-a6,-(sp)					; Save registers
	move.w	#FILE_OPERATION,d0				; Perform file engine operation
	jsr	FileFunction.l
	movem.l	(sp)+,d0-a6					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Load file
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to file name
;	a1.l - File read destination buffer
; ------------------------------------------------------------------------------

	ALIGN	LoadFile
	move.w	#FILE_LOAD_FILE,d0				; Start file loading
	jsr	FileFunction.l

.WaitFileLoad:
	jsr	_WAITVSYNC					; VSync
	
	move.w	#FILE_STATUS,d0					; Is the operation finished?
	jsr	FileFunction.l
	bcs.s	.WaitFileLoad					; If not, wait

	cmpi.w	#FILE_STATUS_OK,d0				; Was the operation a success?
	bne.w	LoadFile					; If not, try again
	rts

; ------------------------------------------------------------------------------
; Get file name
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - File ID
; RETURNS:
;	a0.l - Pointer to file name
; ------------------------------------------------------------------------------

	ALIGN	GetFileName
	mulu.w	#FILE_NAME_SIZE+1,d0				; Get file name pointer
	lea	SpxFileTable,a0
	adda.w	d0,a0
	rts

; ------------------------------------------------------------------------------
; File engine function
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - File engine function ID
; ------------------------------------------------------------------------------

	ALIGN	FileFunction
	movem.l	a0-a6,-(sp)					; Save registers
	lea	FileVariables,a5				; Perform function
	add.w	d0,d0
	move.w	.Functions(pc,d0.w),d0
	jsr	.Functions(pc,d0.w)
	movem.l	(sp)+,a0-a6					; Restore registers
	rts

; ------------------------------------------------------------------------------

.Functions:
	dc.w	InitFileEngine-.Functions			; Initialize file engine
	dc.w	RunFileOperation-.Functions			; Perform file operation
	dc.w	GetFileStatus-.Functions			; Get status
	dc.w	StartFileTableRead-.Functions			; Read file table
	dc.w	StartFileLoad-.Functions			; Load file
	dc.w	FindFile-.Functions				; Find file
	dc.w	StartFmvLoad-.Functions				; Load FMV
	dc.w	ResetFileEngine-.Functions			; Reset file engine
	dc.w	StartMuteFmvLoad-.Functions			; Load mute FMV

; ------------------------------------------------------------------------------
; Start file table read
; ------------------------------------------------------------------------------

StartFileTableRead:
	move.w	#FILE_OPERATE_GET_FILES,file.operation_mode(a5)	; Start getting file table
	move.b	#FMV_SECTION_1,file.fmv_flags(a5)		; Mark as reading data section 1
	move.l	#0,file.fmv_fail_count(a5)			; Reset fail counter
	rts

; ------------------------------------------------------------------------------
; Initialize file engine
; ------------------------------------------------------------------------------

InitFileEngine:
	move.l	#FileOperation,file.bookmark(a5)		; Reset operation bookmark
	move.w	#FILE_OPERATE_NONE,file.operation_mode(a5)	; Set operation mode to "none"
	rts

; ------------------------------------------------------------------------------
; Perform file operation
; ------------------------------------------------------------------------------

RunFileOperation:
	movea.l	file.bookmark(a5),a0				; Go to operation bookmark
	jmp	(a0)

; ------------------------------------------------------------------------------
; Handle file engine operation
; ------------------------------------------------------------------------------

FileOperation:
	bsr.w	FileOperationBookmark				; Set bookmark
	
	move.w	file.operation_mode(a5),d0			; Perform operation
	add.w	d0,d0
	move.w	.Opers(pc,d0.w),d0
	jmp	.Opers(pc,d0.w)

; ------------------------------------------------------------------------------

.Opers:
	dc.w	FileOperation-.Opers				; None
	dc.w	FileTableOperation-.Opers			; Read file table
	dc.w	FileLoadOperation-.Opers			; Load file
	dc.w	FmvLoadOperation-.Opers				; Load FMV
	dc.w	MuteFmvLoadOperation-.Opers			; Load mute FMV

; ------------------------------------------------------------------------------
; Set operation bookmark
; ------------------------------------------------------------------------------

FileOperationBookmark:
	move.l	(sp)+,file.bookmark(a5)				; Set bookmark
	rts

; ------------------------------------------------------------------------------
; File table read operation operation
; ------------------------------------------------------------------------------

FileTableOperation:
	move.b	#MCDR_CDC_SUB_READ,file.cdc_device(a5)		; Set CDC device destination
	move.l	#$10,file.sector(a5)				; Read from sector $10 (primary volume descriptor)
	move.l	#1,file.sector_count(a5)			; Read 1 sector
	
	lea	file.directory(a5),a0				; Get read buffer
	move.l	a0,file.read_buffer(a5)
	
	bsr.w	ReadSectors					; Read sectors
	cmpi.w	#FILE_STATUS_READ_FAIL,file.status(a5)		; Was the operation a failure?
	beq.w	.Failed						; If so, branch

	lea	file.directory(a5),a1				; Primary volume descriptor buffer
	move.l	$A2(a1),file.sector(a5)				; Get root directory sector
	move.l	$AA(a1),d0					; Get root directory size
	divu.w	#$800,d0					; Get size in sectors
	swap	d0
	tst.w	d0						; Is the size sector aligned?
	beq.s	.Aligned					; If so, branch
	addi.l	#1<<16,d0					; Align sector count

.Aligned:
	swap	d0						; Set sector count
	move.w	d0,file.dir_sector_count(a5)
	clr.w	file.count(a5)					; Reset file count

.GetDirectory:
	move.l	#1,file.sector_count(a5)			; Read 1 sector
	lea	file.directory(a5),a1				; Get read buffer
	move.l	a1,file.read_buffer(a5)
	
	bsr.w	ReadSectors					; Read sector of root directory
	
	cmpi.w	#FILE_STATUS_READ_FAIL,file.status(a5)		; Was the operation a failure?
	beq.w	.Failed						; If so, branch

	lea	file.list(a5),a0				; Go to file list cursor
	move.w	file.count(a5),d0
	mulu.w	#file_entry.struct_len,d0
	adda.l	d0,a0
	
	lea	file.directory(a5),a1				; Prepare to get file info
	moveq	#0,d0

.GetFileInfo:
	move.b	0(a1),d0					; Get file entry size
	beq.s	.NoMoreFiles					; If there are no more files left, branch
	move.b	$19(a1),file_entry.flags(a0)			; Get file flags
	
	moveq	#0,d1						; Prepare to get location and size

.GetFileLocSize:
	move.b	6(a1,d1.w),file_entry.sector(a0,d1.w)		; Get file sector
	move.b	$E(a1,d1.w),file_entry.length(a0,d1.w)		; Get file size
	addq.w	#1,d1
	cmpi.w	#4,d1						; Are we done?
	blt.s	.GetFileLocSize					; If not, branch
	
	moveq	#0,d1						; Prepare to get file name

.GetFileName:
	move.b	$21(a1,d1.w),(a0,d1.w)				; Get file name
	addq.w	#1,d1
	cmp.b	$20(a1),d1					; Are we done?
	blt.s	.GetFileName					; If not, branch

.PadFileName:
	cmpi.b	#FILE_NAME_SIZE,d1				; Are we at the end of the file name?
	bge.s	.NextFile					; If so, branch
	
	move.b	#' ',(a0,d1.w)					; If not, pad out with spaces
	addq.w	#1,d1
	bra.s	.PadFileName					; Loop until done

.NextFile:
	addq.w	#1,file.count(a5)				; Increment fle count
	adda.l	d0,a1						; Prepare next file
	adda.l	#file_entry.struct_len,a0
	bra.s	.GetFileInfo

.NoMoreFiles:
	subq.w	#1,file.dir_sector_count(a5)			; Decrement directory sector count
	bne.w	.GetDirectory					; If there are sectors left, branch

	move.w	#FILE_STATUS_OK,file.status(a5)			; Mark operation as successful

.Done:
	move.w	#FILE_OPERATE_NONE,file.operation_mode(a5)	; Set operation mode to "none"
	bra.w	FileOperation					; Loop back

.Failed:
	move.w	#FILE_STATUS_GET_FAIL,file.status(a5)		; Mark operation as failed
	bra.s	.Done

; ------------------------------------------------------------------------------
; File load operation
; ------------------------------------------------------------------------------

FileLoadOperation:
	move.b	#MCDR_CDC_SUB_READ,file.cdc_device(a5)		; Set CDC device destination
	lea	file.name(a5),a0				; Find file
	bsr.w	FindFile
	bcs.w	.FileNotFound					; If it wasn't found, branch
	
	move.l	file_entry.sector(a0),file.sector(a5)		; Get file sector
	move.l	file_entry.length(a0),d1			; Get file size
	move.l	d1,file.size(a5)

	move.l	#1,file.sector_count(a5)			; Get file size in sectors

.GetSectors:
	subi.l	#$800,d1
	ble.s	.ReadFile
	addq.l	#1,file.sector_count(a5)
	bra.s	.GetSectors

.ReadFile:
	bsr.w	ReadSectors					; Read file
	cmp.w	#FILE_STATUS_OK,file.status(a5)			; Was the operation a success?
	beq.s	.Done						; If so, branch
	move.w	#FILE_STATUS_LOAD_FAIL,file.status(a5)		; Mark as failed

.Done:
	move.w	#FILE_OPERATE_NONE,file.operation_mode(a5)	; Set operation mode to "none"
	bra.w	FileOperation					; Loop back

.FileNotFound:
	move.w	#FILE_STATUS_NOT_FOUND,file.status(a5)		; Mark as not found
	bra.s	.Done

; ------------------------------------------------------------------------------
; Get file engine status
; ------------------------------------------------------------------------------
; RETURNS:
;	d0.w  - Return code
;	d1.l  - File size if file load was successful
;	        Sectors read if file load failed
;	cc/cs - Inactive/Busy
; ------------------------------------------------------------------------------

GetFileStatus:
	cmpi.w	#FILE_OPERATE_NONE,file.operation_mode(a5)	; Is there an operation going on?
	bne.s	.Busy						; If so, branch
	
	move.w	file.status(a5),d0				; Get status
	cmpi.w	#FILE_STATUS_OK,d0				; Is the status marked as successful?
	bne.s	.Failed						; If not, branch
	move.l	file.size(a5),d1				; Return file size
	bra.s	.Inactive

.Failed:
	cmpi.w	#FILE_STATUS_LOAD_FAIL,d0			; Is the status marked as a failed load?
	bne.s	.Inactive					; If not, branch
	move.w	file.sectors_read(a5),d1			; Return sectors read

.Inactive:
	move	#0,ccr						; Mark as inactive
	rts

.Busy:
	move	#1,ccr						; Mark as busy
	rts

; ------------------------------------------------------------------------------
; Start loading a file
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - File name
;	a1.l - File read destination buffer
; ------------------------------------------------------------------------------

StartFileLoad:
	move.w	#FILE_OPERATE_LOAD_FILE,file.operation_mode(a5)	; Set operation mode to "load file"
	move.l	a1,file.read_buffer(a5)				; Set read buffer
	
	movea.l	a0,a1						; Copy file name
	lea	file.name(a5),a2
	move.w	#FILE_NAME_SIZE-1,d1

.CopyFileName:
	move.b	(a1)+,(a2)+
	dbf	d1,.CopyFileName
	rts

; ------------------------------------------------------------------------------
; Find file
; ------------------------------------------------------------------------------
; PARAMETERS
;	a0.l  - File name
; RETURNS:
;	a0.l  - Found file information
;	cc/cs - Found/Not found
; ------------------------------------------------------------------------------

FindFile:
	move.l	a2,-(sp)					; Save registers
	moveq	#0,d1						; Prepare to find file
	movea.l	a0,a1
	move.w	#FILE_NAME_SIZE-2,d0

.GetNameLength:
	tst.b	(a1)						; Is this character a termination character?
	beq.s	.GotNameLength					; If so, branch
	cmpi.b	#';',(a1)					; Is this character a semicolon?
	beq.s	.GotNameLength					; If so, branch
	cmpi.b	#' ',(a1)					; Is this character a space?
	beq.s	.GotNameLength					; If so, branch

	addq.w	#1,d1						; Increment length
	addq.w	#1,a1						; Next character
	dbf	d0,.GetNameLength				; Loop until finished

.GotNameLength:
	move.w	file.count(a5),d0				; Prepare to scan file list
	movea.l	a0,a1
	lea	file.list(a5),a0

	lea	.FirstFile(pc),a2				; Are we retrieving the first file?
	bsr.w	CompareStrings
	beq.w	.Done						; If so, branch

	movea.l	a0,a2						; Start scanning list
	subq.w	#1,d0

.FindFile:
	bsr.w	CompareStrings					; Is this file entry the one we are looking for?
	beq.s	.FileFound					; If so, branch
	
	adda.w	#file_entry.struct_len,a2			; Go to next file
	dbf	d0,.FindFile					; Loop until file is found or until all files are scanned
	bra.s	.FileNotFound					; File not found

.FileFound:
	moveq	#1,d0						; Mark as found
	movea.l	a2,a0						; Get file entry

.Done:
	movea.l	(sp)+,a2					; Restore registers
	rts

.FileNotFound:
	move	#1,ccr						; Mark as not found
	bra.s	.Done

; ------------------------------------------------------------------------------

.FirstFile:
	dc.b	"\          ", 0
	even

; ------------------------------------------------------------------------------
; Read disc sectors
; ------------------------------------------------------------------------------

ReadSectors:
	move.l	(sp)+,file.return(a5)				; Save return address
	move.w	#0,file.sectors_read(a5)			; Reset sectors read count
	move.w	#30,file.retries(a5)				; Set retry counter

.StartRead:
	move.b	file.cdc_device(a5),MCD_CDC_DEVICE&$FFFFFF	; Set CDC device
	
	lea	file.sector(a5),a0				; Get sector information
	move.l	(a0),d0						; Get sector frame (in BCD)
	divu.w	#75,d0
	swap	d0
	ext.l	d0
	divu.w	#10,d0
	move.b	d0,d1
	lsl.b	#4,d1
	swap	d0
	move	#0,ccr
	abcd	d1,d0
	move.b	d0,file.sector_frame(a5)

	move.w	#CDCSTOP,d0					; Stop CDC
	jsr	_CDBIOS
	move.w	#ROMREADN,d0					; Start reading
	jsr	_CDBIOS
	
	move.w	#600,file.wait_time(a5)				; Set wait timer

.Bookmark:
	bsr.w	FileOperationBookmark				; Set bookmark

.CheckReady:
	move.w	#CDCSTAT,d0					; Check if data is ready
	jsr	_CDBIOS
	bcc.s	.ReadData					; If so, branch
	
	subq.w	#1,file.wait_time(a5)				; Decrement wait time
	bge.s	.Bookmark					; If we are still waiting, branch
	subq.w	#1,file.retries(a5)				; If we waited too long, decrement retry counter
	bge.s	.StartRead					; If we can still retry, do it
	bra.w	.ReadFailed					; Give up

.ReadData:
	move.w	#CDCREAD,d0					; Read data
	jsr	_CDBIOS
	bcs.w	.ReadRetry					; If the data isn't read, branch
	
	move.l	d0,file.read_time(a5)				; Get time of sector read
	
	move.b	file.sector_frame(a5),d0			; Does the read sector match the sector we want?
	cmp.b	file.read_frame(a5),d0
	beq.s	.WaitDataSet					; If so, branch

.ReadRetry:
	subq.w	#1,file.retries(a5)				; Decrement retry counter
	bge.w	.StartRead					; If we can still retry, do it
	bra.w	.ReadFailed					; Give up

.WaitDataSet:
	move.w	#$800-1,d0					; Wait for data set

.WaitDataSetLoop:
	btst	#MCDR_DSR_BIT,MCD_CDC_DEVICE&$FFFFFF		; Have we gotten the data?
	dbne	d0,.WaitDataSetLoop				; If so, loop
	bne.s	.TransferData					; If the data is ready to be transfered, branch
	
	subq.w	#1,file.retries(a5)				; Decrement retry counter
	bge.w	.StartRead					; If we can still retry, do it
	bra.w	.ReadFailed					; Give up

.TransferData:
	cmpi.b	#MCDR_CDC_MAIN_READ,file.cdc_device(a5)		; Should the Main CPU read the sector data?
	beq.w	.MainCpuRead					; If so, branch

	move.w	#CDCTRN,d0					; Transfer data
	movea.l	file.read_buffer(a5),a0
	lea	file.read_time(a5),a1
	jsr	_CDBIOS
	bcs.s	.CopyRetry					; If it wasn't successful, branch
	
	move.b	file.sector_frame(a5),d0			; Does the read sector match the sector we want?
	cmp.b	file.read_frame(a5),d0
	beq.s	.NextSectorFrame				; If so, branch

.CopyRetry:
	subq.w	#1,file.retries(a5)				; Decrement retry counter
	bge.w	.StartRead					; If we can still retry, do it
	bra.w	.ReadFailed					; Give up

.NextSectorFrame:
	move	#0,ccr						; Next sector frame
	moveq	#1,d1
	abcd	d1,d0
	move.b	d0,file.sector_frame(a5)
	
	cmpi.b	#$75,file.sector_frame(a5)			; Should we wrap it?
	bcs.s	.FinishSectorRead				; If not, branch
	move.b	#0,file.sector_frame(a5)			; If so, wrap it

.FinishSectorRead:
	move.w	#CDCACK,d0					; Finish data read
	jsr	_CDBIOS

	move.w	#6,file.wait_time(a5)				; Set new wait time
	move.w	#30,file.retries(a5)				; Set new retry counter
	addi.l	#$800,file.read_buffer(a5)			; Advance read buffer
	addq.w	#1,file.sectors_read(a5)			; Increment sectors read counter
	addq.l	#1,file.sector(a5)				; Next sector
	
	subq.l	#1,file.sector_count(a5)			; Decrement sectors to read
	bgt.w	.CheckReady					; If there are still sectors to read, branch
	move.w	#FILE_STATUS_OK,file.status(a5)			; Mark as successful

.Done:
	move.b	file.cdc_device(a5),MCD_CDC_DEVICE&$FFFFFF	; Set CDC device
	movea.l	file.return(a5),a0				; Go to saved return address
	jmp	(a0)

.ReadFailed:
	move.w	#FILE_STATUS_READ_FAIL,file.status(a5)		; Mark as failed
	bra.s	.Done

.MainCpuRead:
	move.w	#6,file.wait_time(a5)				; Set new wait time

.WaitMainCopy:
	bsr.w	FileOperationBookmark				; Set bookmark
	
	btst	#MCDR_EDT_BIT,MCD_CDC_DEVICE&$FFFFFF		; Has the data been transferred?
	bne.s	.FinishSectorRead				; If so, branch
	
	subq.w	#1,file.wait_time(a5)				; Decrement wait time
	bge.s	.WaitMainCopy					; If we are still waiting, branch
	bra.s	.ReadFailed					; If we have waited too long, branch

; ------------------------------------------------------------------------------
; Compare two strings
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d1.w  - Number of characters to compare
;	a1.l  - Pointer to string 1
;	a2.l  - Pointer to string 2
; RETURNS:
;	eq/ne - Same/Different
; ------------------------------------------------------------------------------

CompareStrings:
	movem.l	d1/a1-a2,-(sp)					; Save registers

.Compare:
	cmpm.b	(a1)+,(a2)+					; Compare characters
	bne.s	.Done						; If they aren't the same branch
	dbf	d1,.Compare					; Loop until all characters are scanned

	moveq	#0,d1						; Mark strings as the same

.Done:
	movem.l	(sp)+,d1/a1-a2					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Start loading an FMV
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - File name
; ------------------------------------------------------------------------------

StartFmvLoad:
	move.b	#FMV_SECTION_1,file.fmv_flags(a5)		; Mark as reading data section 1
	move.w	#FILE_OPERATE_FMV,file.operation_mode(a5)	; Set operation mode to "load FMV"
	move.l	#FMV_PCM_BUFFER,file.read_buffer(a5)		; Prepare to read PCM data
	move.w	#0,file.fmv_frame(a5)				; Reset FMV sector frame
	bset	#FMV_SECTION_1_BIT,file.fmv_flags(a5)		; Mark as reading data section 1

	movea.l	a0,a1						; Copy file name
	lea	file.name(a5),a2
	move.w	#FILE_NAME_SIZE-1,d1

.CopyFileName:
	move.b	(a1)+,(a2)+
	dbf	d1,.CopyFileName
	rts

; ------------------------------------------------------------------------------
; FMV load operation
; ------------------------------------------------------------------------------

FmvLoadOperation:
	move.b	#MCDR_CDC_SUB_READ,file.cdc_device(a5)		; Set CDC device destination
	
	lea	file.name(a5),a0				; Find file
	bsr.w	FindFile
	bcs.w	.FileNotFound					; If it wasn't found, branch
	
	move.l	file_entry.sector(a0),file.sector(a5)		; Get file sector
	move.l	file_entry.length(a0),d1			; Get file size
	move.l	d1,file.size(a5)

	move.l	#1,file.sector_count(a5)			; Get file size in sectors

.GetSectors:
	subi.l	#$800,d1
	ble.s	.ReadFile
	addq.l	#1,file.sector_count(a5)
	bra.s	.GetSectors

.ReadFile:
	bsr.w	ReadFmvSectors					; Read FMV file data
	cmp.w	#FILE_STATUS_OK,file.status(a5)			; Was the operation a success?
	beq.s	.Done						; If so, branch
	move.w	#FILE_STATUS_LOAD_FAIL,file.status(a5)		; Mark as failed

.Done:
	move.w	#FILE_OPERATE_NONE,file.operation_mode(a5)	; Set operation mode to "none"
	bra.w	FileOperation					; Loop back

.FileNotFound:
	move.w	#FILE_STATUS_NOT_FOUND,file.status(a5)		; Mark as not found
	bra.s	.Done

; ------------------------------------------------------------------------------
; Read FMV file disc sectors
; ------------------------------------------------------------------------------

ReadFmvSectors:
	move.l	(sp)+,file.return(a5)				; Save return address
	move.w	#0,file.sectors_read(a5)			; Reset sectors read count
	move.w	#10,file.retries(a5)				; Set retry counter

.StartRead:
	move.b	file.cdc_device(a5),MCD_CDC_DEVICE&$FFFFFF	; Set CDC device
	
	lea	file.sector(a5),a0				; Get sector frame (in BCD)
	move.l	(a0),d0
	divu.w	#75,d0
	swap	d0
	ext.l	d0
	divu.w	#10,d0
	move.b	d0,d1
	lsl.b	#4,d1
	swap	d0
	move	#0,ccr
	abcd	d1,d0
	move.b	d0,file.sector_frame(a5)

	move.w	#CDCSTOP,d0					; Stop CDC
	jsr	_CDBIOS
	move.w	#ROMREADN,d0					; Start reading
	jsr	_CDBIOS
	
	move.w	#600,file.wait_time(a5)				; Set wait timer

.Bookmark:
	bsr.w	FileOperationBookmark				; Set bookmark

.CheckReady:
	move.w	#CDCSTAT,d0					; Check if data is ready
	jsr	_CDBIOS
	bcc.s	.ReadData					; If so, branch
	
	subq.w	#1,file.wait_time(a5)				; Decrement wait time
	bge.s	.Bookmark					; If we are still waiting, branch
	subq.w	#1,file.retries(a5)				; If we waited too long, decrement retry counter
	bge.s	.StartRead					; If we can still retry, do it
	bra.w	.ReadFailed					; Give up

.ReadData:
	move.w	#CDCREAD,d0					; Read data
	jsr	_CDBIOS
	bcs.w	.ReadRetry					; If the data isn't read, branch
	
	move.l	d0,file.read_time(a5)				; Get time of sector read
	
	move.b	file.sector_frame(a5),d0			; Does the read sector match the sector we want?
	cmp.b	file.read_frame(a5),d0
	beq.s	.WaitDataSet					; If so, branch

.ReadRetry:
	addq.l	#1,file.fmv_fail_count(a5)			; Increment fail counter
	subq.w	#1,file.retries(a5)				; Decrement retry counter
	bge.w	.StartRead					; If we can still retry, do it
	bra.w	.ReadFailed					; Give up

.WaitDataSet:
	move.w	#$800-1,d0					; Wait for data set

.WaitDataSetLoop:
	btst	#MCDR_DSR_BIT,MCD_CDC_DEVICE&$FFFFFF		; Have we gotten the data?
	dbne	d0,.WaitDataSetLoop				; If so, loop
	bne.s	.TransferData					; If the data is ready to be transfered, branch
	
	subq.w	#1,file.retries(a5)				; Decrement retry counter
	bge.w	.StartRead					; If we can still retry, do it
	bra.w	.ReadFailed					; Give up

.TransferData:
	cmpi.b	#MCDR_CDC_MAIN_READ,file.cdc_device(a5)		; Should the Main CPU read the sector data?
	beq.w	.MainCpuRead					; If so, branch

	move.w	#CDCTRN,d0					; Transfer data
	movea.l	file.read_buffer(a5),a0
	lea	file.read_time(a5),a1
	jsr	_CDBIOS
	bcs.s	.CopyRetry					; If it wasn't successful, branch
	
	move.b	file.sector_frame(a5),d0			; Does the read sector match the sector we want?
	cmp.b	file.read_frame(a5),d0
	beq.s	.NextSectorFrame				; If so, branch

.CopyRetry:
	addq.l	#1,file.fmv_fail_count(a5)			; Increment fail counter
	subq.w	#1,file.retries(a5)				; Decrement retry counter
	bge.w	.StartRead					; If we can still retry, do it
	bra.w	.ReadFailed					; Give up

.NextSectorFrame:
	move	#0,ccr						; Next sector frame
	moveq	#1,d1
	abcd	d1,d0
	move.b	d0,file.sector_frame(a5)
	
	cmpi.b	#$75,file.sector_frame(a5)			; Should we wrap it?
	bcs.s	.FinishSectorRead				; If not, branch
	move.b	#0,file.sector_frame(a5)			; If so, wrap it

.FinishSectorRead:
	move.w	#CDCACK,d0					; Finish data read
	jsr	_CDBIOS

	move.w	#6,file.wait_time(a5)				; Set new wait time
	move.w	#10,file.retries(a5)				; Set new retry counter
	
	move.w	file.fmv_frame(a5),d0				; Get current sector frame
	cmpi.w	#15,d0						; Is it time to load graphics data now?
	beq.s	.PcmDone					; If so, branch
	cmpi.w	#74,d0						; Are we done loading graphics data?
	beq.s	.GfxDone					; If so, branch
	
	addi.l	#$800,file.read_buffer(a5)			; Advance read buffer
	bra.w	.Advance

.PcmDone:
	move.b	#FMV_DATA_GFX,file.fmv_data_type(a5)		; Set graphics data type
	bclr	#FMV_SECTION_1_BIT,file.fmv_flags(a5)		; Mark as reading data section 2
	move.l	#FMV_GFX_BUFFER,file.read_buffer(a5)		; Set read buffer for graphics data
	bra.w	.Advance

.GfxDone:
	bset	#0,MCD_SUB_FLAG					; Sync with Main CPU
	bset	#FMV_SECTION_1_BIT,file.fmv_flags(a5)		; Mark as reading data section 1
	bset	#FMV_READY_BIT,file.fmv_flags(a5)		; Mark as ready

.WaitMain:
	btst	#0,MCD_MAIN_FLAG				; Wait for Main CPU
	beq.s	.WaitMain
	btst	#0,MCD_MAIN_FLAG
	beq.s	.WaitMain
	bclr	#0,MCD_SUB_FLAG
	
	bchg	#MCDR_RET_BIT,MCD_MEM_MODE			; Swap Word RAM banks

.WaitWordRam:
	btst	#MCDR_DMNA_BIT,MCD_MEM_MODE
	bne.s	.WaitWordRam
	
	move.b	#FMV_DATA_PCM,file.fmv_data_type(a5)		; Set PCM data type
	move.l	#FMV_PCM_BUFFER,file.read_buffer(a5)		; Set read buffer for PCM data
	bset	#FMV_SECTION_1_BIT,file.fmv_flags(a5)		; Mark as reading data section 1

.Advance:
	addq.w	#1,file.sectors_read(a5)			; Increment sectors read counter
	addq.l	#1,file.sector(a5)				; Next sector
	addq.w	#1,file.fmv_frame(a5)				; Increment FMV sector frame
	
	cmpi.w	#75,file.fmv_frame(a5)				; Should we wrap it?
	bcs.s	.CheckSectorsLeft				; If not, branch
	move.w	#0,file.fmv_frame(a5)				; If so, wrap it

.CheckSectorsLeft:
	subq.l	#1,file.sector_count(a5)			; Decrement sectors to read
	bgt.w	.CheckReady					; If there are still sectors to read, branch
	move.w	#FILE_STATUS_OK,file.status(a5)			; Mark as successful

.Done:
	move.b	file.cdc_device(a5),MCD_CDC_DEVICE&$FFFFFF	; Set CDC device
	movea.l	file.return(a5),a0				; Go to saved return address
	jmp	(a0)

.ReadFailed:
	move.w	file.fmv_frame(a5),d0				; Get current sector frame
	cmpi.w	#15,d0						; Is it time to load graphics data now?
	beq.s	.PcmDone2					; If so, branch
	cmpi.w	#74,d0						; Are we done loading graphics data?
	beq.s	.GfxDone2					; If so, branch
	
	addi.l	#$800,file.read_buffer(a5)			; Advance read buffer
	bra.w	.Advance2

.PcmDone2:
	move.b	#FMV_DATA_GFX,file.fmv_data_type(a5)		; Set graphics data type
	bclr	#FMV_SECTION_1_BIT,file.fmv_flags(a5)		; Mark as reading data section 2
	move.l	#FMV_GFX_BUFFER,file.read_buffer(a5)		; Set read buffer for graphics data
	bra.w	.Advance2

.GfxDone2:
	bset	#0,MCD_SUB_FLAG					; Sync with Main CPU
	bset	#FMV_SECTION_1_BIT,file.fmv_flags(a5)		; Mark as reading data section 1
	bset	#FMV_READY_BIT,file.fmv_flags(a5)		; Mark as ready

.WaitMain2:
	btst	#0,MCD_MAIN_FLAG				; Wait for Main CPU
	beq.s	.WaitMain2
	btst	#0,MCD_MAIN_FLAG
	beq.s	.WaitMain2
	bclr	#0,MCD_SUB_FLAG
	
	bchg	#MCDR_RET_BIT,MCD_MEM_MODE			; Swap Word RAM banks

.WaitWordRam2:
	btst	#MCDR_DMNA_BIT,MCD_MEM_MODE
	bne.s	.WaitWordRam2
	
	move.b	#FMV_DATA_PCM,file.fmv_data_type(a5)		; Set PCM data type
	move.l	#FMV_PCM_BUFFER,file.read_buffer(a5)		; Set read buffer for PCM data
	bset	#FMV_SECTION_1_BIT,file.fmv_flags(a5)		; Mark as reading data section 1

.Advance2:
	addq.w	#1,file.sectors_read(a5)			; Increment sectors read counter
	addq.l	#1,file.sector(a5)				; Next sector
	addq.w	#1,file.fmv_frame(a5)				; Increment FMV sector frame
	
	cmpi.w	#75,file.fmv_frame(a5)				; Should we wrap it?
	bcs.s	.CheckSectorsLeft2				; If not, branch
	move.w	#0,file.fmv_frame(a5)				; If so, wrap it

.CheckSectorsLeft2:
	subq.l	#1,file.sector_count(a5)			; Decrement sectors to read
	bgt.w	.StartRead					; If there are still sectors to read, branch
	
	move.w	#FILE_STATUS_FMV_FAIL,file.status(a5)		; Mark as failed
	bra.w	.Done

.MainCpuRead:
	move.w	#6,file.wait_time(a5)				; Set new wait time

.WaitMainCopy:
	bsr.w	FileOperationBookmark				; Set bookmark
	
	btst	#MCDR_EDT_BIT,MCD_CDC_DEVICE&$FFFFFF		; Has the data been transferred?
	bne.w	.FinishSectorRead				; If so, branch
	
	subq.w	#1,file.wait_time(a5)				; Decrement wait time
	bge.s	.WaitMainCopy					; If we are still waiting, branch
	bra.w	.ReadFailed					; If we have waited too long, branch

; ------------------------------------------------------------------------------
; Start loading a mute FMV
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - File name
; ------------------------------------------------------------------------------

StartMuteFmvLoad:
	move.b	#FMV_SECTION_1,file.fmv_flags(a5)		; Mark as reading data section 1
	move.w	#FILE_OPERATE_FMV_MUTE,file.operation_mode(a5)	; Set operation mode to "load mute FMV"
	move.l	#FMV_GFX_BUFFER,file.read_buffer(a5)		; Prepare to read graphics data
	move.w	#0,file.fmv_frame(a5)				; Reset FMV sector frame
	
	movea.l	a0,a1						; Copy file name
	lea	file.name(a5),a2
	move.w	#FILE_NAME_SIZE-1,d1

.CopyFileName:
	move.b	(a1)+,(a2)+
	dbf	d1,.CopyFileName
	rts

; ------------------------------------------------------------------------------
; Mute FMV load operation
; ------------------------------------------------------------------------------

MuteFmvLoadOperation:
	move.b	#MCDR_CDC_SUB_READ,file.cdc_device(a5)		; Set CDC device destination
	
	lea	file.name(a5),a0				; Find file
	bsr.w	FindFile
	bcs.w	.FileNotFound					; If it wasn't found, branch
	
	move.l	file_entry.sector(a0),file.sector(a5)		; Get file sector
	move.l	file_entry.length(a0),d1			; Get file size
	move.l	d1,file.size(a5)

	move.l	#0,file.sector_count(a5)			; Get file size in sectors

.GetSectors:
	subi.l	#$800,d1
	ble.s	.ReadFile
	addq.l	#1,file.sector_count(a5)
	bra.s	.GetSectors

.ReadFile:
	bsr.w	ReadMuteFmvSectors				; Read FMV file data
	
	cmp.w	#FILE_STATUS_OK,file.status(a5)			; Was the operation a success?
	beq.s	.Done						; If so, branch
	move.w	#FILE_STATUS_LOAD_FAIL,file.status(a5)		; Mark as failed

.Done:
	move.w	#FILE_OPERATE_NONE,file.operation_mode(a5)	; Set operation mode to "none"
	bra.w	FileOperation					; Loop back

.FileNotFound:
	move.w	#FILE_STATUS_NOT_FOUND,file.status(a5)		; Mark as not found
	bra.s	.Done

; ------------------------------------------------------------------------------
; Read mute FMV disc sectors
; ------------------------------------------------------------------------------

ReadMuteFmvSectors:
	move.l	(sp)+,file.return(a5)				; Save return address
	move.w	#0,file.sectors_read(a5)			; Reset sectors read count
	move.w	#10,file.retries(a5)				; Set retry counter

.StartRead:
	move.b	file.cdc_device(a5),MCD_CDC_DEVICE&$FFFFFF	; Set CDC device
	
	lea	file.sector(a5),a0				; Get sector information
	move.l	(a0),d0						; Get sector frame (in BCD)
	divu.w	#75,d0
	swap	d0
	ext.l	d0
	divu.w	#10,d0
	move.b	d0,d1
	lsl.b	#4,d1
	swap	d0
	move	#0,ccr
	abcd	d1,d0
	move.b	d0,file.sector_frame(a5)

	move.w	#CDCSTOP,d0					; Stop CDC
	jsr	_CDBIOS
	move.w	#ROMREADN,d0					; Start reading
	jsr	_CDBIOS
	
	move.w	#600,file.wait_time(a5)				; Set wait timer

.Bookmark:
	bsr.w	FileOperationBookmark				; Set bookmark

.CheckReady:
	move.w	#CDCSTAT,d0					; Check if data is ready
	jsr	_CDBIOS
	bcc.s	.ReadData					; If so, branch
	
	subq.w	#1,file.wait_time(a5)				; Decrement wait time
	bge.s	.Bookmark					; If we are still waiting, branch
	subq.w	#1,file.retries(a5)				; If we waited too long, decrement retry counter
	bge.s	.StartRead					; If we can still retry, do it
	bra.w	.ReadFailed					; Give up

.ReadData:
	move.w	#CDCREAD,d0					; Read data
	jsr	_CDBIOS
	bcs.w	.ReadRetry					; If the data isn't read, branch
	
	move.l	d0,file.read_time(a5)				; Get time of sector read
	
	move.b	file.sector_frame(a5),d0			; Does the read sector match the sector we want?
	cmp.b	file.read_frame(a5),d0
	beq.s	.WaitDataSet					; If so, branch

.ReadRetry:
	addq.l	#1,file.fmv_fail_count(a5)			; Increment fail counter
	subq.w	#1,file.retries(a5)				; Decrement retry counter
	bge.w	.StartRead					; If we can still retry, do it
	bra.w	.ReadFailed					; Give up

.WaitDataSet:
	move.w	#$800-1,d0					; Wait for data set

.WaitDataSetLoop:
	btst	#MCDR_DSR_BIT,MCD_CDC_DEVICE&$FFFFFF		; Have we gotten the data?
	dbne	d0,.WaitDataSetLoop				; If so, loop
	bne.s	.TransferData					; If the data is ready to be transfered, branch
	
	subq.w	#1,file.retries(a5)				; Decrement retry counter
	bge.w	.StartRead					; If we can still retry, do it
	bra.w	.ReadFailed					; Give up

.TransferData:
	cmpi.b	#MCDR_CDC_MAIN_READ,file.cdc_device(a5)		; Should the Main CPU read the sector data?
	beq.w	.MainCpuRead					; If so, branch

	move.w	#CDCTRN,d0					; Transfer data
	movea.l	file.read_buffer(a5),a0
	lea	file.read_time(a5),a1
	jsr	_CDBIOS
	bcs.s	.CopyRetry					; If it wasn't successful, branch
	
	move.b	file.sector_frame(a5),d0			; Does the read sector match the sector we want?
	cmp.b	file.read_frame(a5),d0
	beq.s	.NextSectorFrame				; If so, branch

.CopyRetry:
	addq.l	#1,file.fmv_fail_count(a5)			; Increment fail counter
	subq.w	#1,file.retries(a5)				; Decrement retry counter
	bge.w	.StartRead					; If we can still retry, do it
	bra.w	.ReadFailed					; Give up

.NextSectorFrame:
	move	#0,ccr						; Next sector frame
	moveq	#1,d1
	abcd	d1,d0
	move.b	d0,file.sector_frame(a5)
	
	cmpi.b	#$75,file.sector_frame(a5)			; Should we wrap it?
	bcs.s	.FinishSectorRead				; If not, branch
	move.b	#0,file.sector_frame(a5)			; If so, wrap it

.FinishSectorRead:
	move.w	#CDCACK,d0					; Finish data read
	jsr	_CDBIOS

	move.w	#6,file.wait_time(a5)				; Set new wait time
	move.w	#10,file.retries(a5)				; Set new retry counter
	addq.w	#1,file.sectors_read(a5)			; Increment sectors read counter
	addq.l	#1,file.sector(a5)				; Next sector
	addq.w	#1,file.fmv_frame(a5)				; Increment FMV sector frame
	
	move.w	file.fmv_frame(a5),d0				; Get current sector frame
	cmpi.w	#5,d0						; Are we done loading graphics data?
	beq.s	.GfxDone					; If so, branch
	
	addi.l	#$800,file.read_buffer(a5)			; Advance read buffer
	bra.w	.Advance

.GfxDone:
	bset	#0,MCD_SUB_FLAG					; Sync with Main CPU

.WaitMain:
	btst	#0,MCD_MAIN_FLAG				; Wait for Main CPU
	beq.s	.WaitMain
	btst	#0,MCD_MAIN_FLAG
	beq.s	.WaitMain
	bclr	#0,MCD_SUB_FLAG
	
	bchg	#MCDR_RET_BIT,MCD_MEM_MODE			; Swap Word RAM banks

.WaitWordRam:
	btst	#MCDR_DMNA_BIT,MCD_MEM_MODE
	bne.s	.WaitWordRam
	
	move.l	#FMV_GFX_BUFFER,file.read_buffer(a5)		; Set read buffer for graphics data
	move.w	#0,file.fmv_frame(a5)				; Reset FMV sector frame

.Advance:
	subq.l	#1,file.sector_count(a5)			; Decrement sectors to read
	bgt.w	.CheckReady					; If there are still sectors to read, branch
	move.w	#FILE_STATUS_OK,file.status(a5)			; Mark as successful

.Done:
	move.b	file.cdc_device(a5),MCD_CDC_DEVICE&$FFFFFF	; Set CDC device
	movea.l	file.return(a5),a0				; Go to saved return address
	jmp	(a0)

.ReadFailed:
	move.w	#FILE_STATUS_FMV_FAIL,file.status(a5)		; Mark as failed
	bra.s	.Done

.MainCpuRead:
	move.w	#6,file.wait_time(a5)				; Set new wait time

.WaitMainCopy:
	bsr.w	FileOperationBookmark				; Set bookmark
	
	btst	#MCDR_EDT_BIT,MCD_CDC_DEVICE&$FFFFFF		; Has the data been transferred?
	bne.w	.FinishSectorRead				; If so, branch
	
	subq.w	#1,file.wait_time(a5)				; Decrement wait time
	bge.s	.WaitMainCopy					; If we are still waiting, branch
	bra.s	.ReadFailed					; If we have waited too long, branch

; ------------------------------------------------------------------------------
; Reset file engine
; ------------------------------------------------------------------------------

ResetFileEngine:
	bsr.w	InitFileEngine					; Reset file engine
	rts

; ------------------------------------------------------------------------------

SpEnd:

; ------------------------------------------------------------------------------
