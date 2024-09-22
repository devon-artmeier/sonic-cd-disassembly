; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Title screen Main CPU program
; ------------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Main CPU.i"
	include	"_Include/Main CPU Variables.i"
	include	"_Include/Sound.i"
	include	"_Include/MMD.i"
	include	"Title Screen/_Common.i"

; ------------------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------------------

; Objects
	if REGION<>JAPAN					; Object count
OBJECT_COUNT		equ 10
	else
OBJECT_COUNT		equ 8
	endif

; ------------------------------------------------------------------------------
; Image buffer VRAM constants
; ------------------------------------------------------------------------------

IMGVRAM			equ $0020				; VRAM address
IMGV1LEN		equ IMGLENGTH/2				; Part 1 length

; ------------------------------------------------------------------------------
; Object variables structure
; ------------------------------------------------------------------------------

	rsreset
obj.addr		rs.w 1					; Address
obj.active		rs.b 1					; Active flag
obj.flags		rs.b 1					; Flags
obj.sprite_tile		rs.w 1					; Base sprite tile
obj.sprites		rs.l 1					; Mappings
obj.sprite_frame	rs.b 1					; Mappings frame
			rs.b 1
obj.x			rs.l 1					; X position
obj.y			rs.l 1					; Y position
obj.vars		rs.b $40-__rs				; Object specific variables
obj.struct_size		rs.b 0					; Size of structure

; ------------------------------------------------------------------------------
; Variables
; ------------------------------------------------------------------------------

	rsset	WORK_RAM+$FF00A000
VARIABLES		rs.b 0					; Start of variables
cloud_image		rs.b IMGLENGTH				; Clouds image buffer
hscroll			rs.b $380				; Horizontal scroll buffer
			rs.b $80
sprites			rs.b 80*8				; Sprite buffer
water_scroll		rs.b $100				; Scroll buffer
			rs.b $B80

objects			rs.b OBJECT_COUNT*obj.struct_size	; Object pool
objects_end		rs.b 0					; End of object pool

	if REGION=JAPAN
			rs.b $1200
	else
			rs.b $1180
	endif

nem_code_table		rs.b $200				; Nemesis decompression code table
palette			rs.w $40				; Palette buffer
fade_palette		rs.w $40				; Fade palette buffer
			rs.b 1
unk_palette_fade_flag	rs.b 1					; Unknown palette fade flag
palette_fade_params	rs.b 0					; Palette fade parameters
palette_fade_start	rs.b 1					; Palette fade start
palette_fade_length	rs.b 1					; Palette fade length
title_mode		rs.b 1					; Title screen mode
			rs.b 5
global_object_y_speed	rs.w 1					; Global object Y speed
palette_cycle_frame	rs.b 1					; Palette cycle frame
palette_cycle_delay	rs.b 1					; Palette cycle delay
exit_flag		rs.b 1					; Exit flag
menu_selection		rs.b 1					; Menu selection
menu_options		rs.b 8					; Available menu options
p2_ctrl_data		rs.b 0					; Player 2 controller data
p2_ctrl_hold		rs.b 1					; Player 2 controller held buttons data
p2_ctrl_tap		rs.b 1					; Player 2 controller tapped buttons data
p1_ctrl_data		rs.b 0					; Player 1 controller data
p1_ctrl_hold		rs.b 1					; Player 1 controller held buttons data
p1_ctrl_tap		rs.b 1					; Player 1 controller tapped buttons data
control_clouds		rs.b 1					; Control clouds flag
			rs.b 1
fm_sound_queue		rs.b 1					; FM sound queue
			rs.b 1
sub_wait_time		rs.l 1					; Sub CPU wait time
sub_fail_count		rs.b 1					; Sub CPU fail count
			rs.b 1
enable_display		rs.b 1					; Enable display flag
			rs.b $19
vblank_routine		rs.w 1					; V-BLANK routine ID
timer			rs.w 1					; Timer
frame_count		rs.w 1					; V-BLANK interrupt counter
saved_sr		rs.w 1					; Saved status register
sprite_count		rs.b 1					; Sprite count
			rs.b 1
cur_sprite_slot		rs.l 1					; Current sprite slot
			rs.b $B2
VARIABLES_SIZE		equ __rs-VARIABLES			; Size of variables area

lag_counter		rs.l 1					; Lag counter

sub_p2_ctrl_data	equ MCD_MAIN_COMM_14			; Sub CPU player 2 controller data
sub_p2_ctrl_hold	equ sub_p2_ctrl_data			; Sub CPU player 2 controller held buttons data
sub_p2_ctrl_tap		equ sub_p2_ctrl_data+1			; Sub CPU player 2 controller tapped buttons data

; ------------------------------------------------------------------------------
; MMD header
; ------------------------------------------------------------------------------

	MMD	MMDSUBM, &
		work_ram_file, $8000, &
		Start, 0, 0

; ------------------------------------------------------------------------------
; Program start
; ------------------------------------------------------------------------------

Start:
	move.w	#$8134,ipx_vdp_reg_81				; Disable display
	move.w	ipx_vdp_reg_81,VDP_CTRL
	
	move.l	#VInterrupt,_LEVEL6+2				; Set V-BLANK interrupt address
	move.l	#-1,lag_counter					; Disable lag counter

	moveq	#0,d0						; Clear communication registers
	move.l	d0,MCD_MAIN_COMM_0
	move.l	d0,MCD_MAIN_COMM_4
	move.l	d0,MCD_MAIN_COMM_8
	move.l	d0,MCD_MAIN_COMM_C
	move.b	d0,MCD_MAIN_FLAG
	
	move.b	d0,enable_display				; Clear display enable flag
	move.l	d0,sub_wait_time				; Reset Sub CPU wait time
	move.b	d0,sub_fail_count				; Reset Sub CPU fail count
	
	lea	VARIABLES,a0					; Clear variables
	move.w	#VARIABLES_SIZE/4-1,d7

.ClearVars:
	clr.l	(a0)+
	dbf	d7,.ClearVars
	
	bsr.w	WaitSubCpuStart					; Wait for the Sub CPU program to start
	bsr.w	GiveWordRamAccess				; Give Word RAM access
	bsr.w	WaitSubCpuInit					; Wait for the Sub CPU program to finish initializing
	
	bsr.w	InitMegaDrive					; Initialize Mega Drive hardware
	bsr.w	ClearSprites					; Clear sprites
	bsr.w	ClearObjects					; Clear objects
	bsr.w	DrawTilemaps					; Draw tilemaps
	
	VDP_CMD move.l,$D800,VRAM,WRITE,VDP_CTRL		; Load press start text art
	lea	PressStartTextArt(pc),a0
	bsr.w	NemDec
	
	VDP_CMD move.l,$DC00,VRAM,WRITE,VDP_CTRL		; Load menu arrow art
	lea	MenuArrowArt(pc),a0
	bsr.w	NemDec
	
	if REGION=USA						; Load copyright/TM art
		VDP_CMD move.l,$DE00,VRAM,WRITE,VDP_CTRL
		lea	CopyrightTmArt(pc),a0
		bsr.w	NemDec
		
		VDP_CMD move.l,$DFC0,VRAM,WRITE,VDP_CTRL
		lea	TmArt(pc),a0
		bsr.w	NemDec
	else
		VDP_CMD move.l,$DE00,VRAM,WRITE,VDP_CTRL
		lea	CopyrightArt(pc),a0
		bsr.w	NemDec
		
		VDP_CMD move.l,$DF20,VRAM,WRITE,VDP_CTRL
		lea	TmArt(pc),a0
		bsr.w	NemDec
	endif
	
	VDP_CMD move.l,$F000,VRAM,WRITE,VDP_CTRL		; Load banner art
	lea	BannerArt(pc),a0
	bsr.w	NemDec
	
	VDP_CMD move.l,$6D00,VRAM,WRITE,VDP_CTRL		; Load Sonic art
	lea	SonicArt(pc),a0
	bsr.w	NemDec

	lea	ObjSonic(pc),a2					; Spawn Sonic
	bsr.w	SpawnObject
	
	VDP_CMD move.l,$BC20,VRAM,WRITE,VDP_CTRL		; Load solid tiles
	lea	SolidColorArt(pc),a0
	bsr.w	NemDec
	
	bsr.w	DrawCloudTilemap				; Draw cloud tilemap
	bsr.w	VSync						; VSync

	move.b	#1,enable_display				; Enable display
	move.w	#4,vblank_routine				; VSync
	bsr.w	VSync

	if REGION=USA
		move.w	#48-1,d7				; Delay 48 frames

.Delay:
		bsr.w	VSync
		dbf	d7,.Delay
	endif

	move.l	#0,lag_counter					; Enable and reset lag counter
	jsr	RunObjects(pc)					; Run objects
	move.w	#5,vblank_routine				; VSync
	bsr.w	VSync

	lea	Pal_Title+($30*2),a1				; Fade in Sonic palette
	lea	fade_palette+($30*2),a2
	movem.l	(a1)+,d0-d7
	movem.l	d0-d7,(a2)
	move.w	#($30<<9)|($10-1),palette_fade_params
	bsr.w	FadeFromBlack

.WaitSonicTurn:
	move.b	#1,title_mode					; Set to "Sonic turning" mode
	
	jsr	ClearSprites(pc)				; Clear sprites
	jsr	RunObjects(pc)					; Run objects

	btst	#7,title_mode					; Has Sonic turned around?
	bne.s	.FlashWhite					; If so, branch
	move.w	#5,vblank_routine				; VSync
	bsr.w	VSync
	bra.w	.WaitSonicTurn					; Loop

.FlashWhite:
	bclr	#7,title_mode					; Clear Sonic turned flag

	VDP_CMD move.l,$6D80,VRAM,WRITE,VDP_CTRL		; Load emblem art
	lea	EmblemArt(pc),a0
	bsr.w	NemDec

	lea	Pal_Title,a1					; Flash white and fade in title screen paltte
	lea	fade_palette,a2
	bsr.w	Copy128
	move.w	#(0<<9)|($30-1),palette_fade_params
	bsr.w	FadeFromWhite2

	lea	ObjPlanet(pc),a2				; Spawn background planet
	bsr.w	SpawnObject
	
	lea	ObjMenu,a2					; Spawn menu
	bsr.w	SpawnObject
	
	lea	ObjCopyright(pc),a2				; Spawn copyright
	bsr.w	SpawnObject
	
	if REGION<>JAPAN
		lea	ObjTM(pc),a2				; Spawn TM symbol
		bsr.w	SpawnObject
	endif

; ------------------------------------------------------------------------------

MainLoop:
	move.b	#2,title_mode					; Set to "menu" mode
	
	; Show buffer 2, render to buffer 1
	bsr.w	RenderClouds					; Start rendering clouds
	jsr	ClearSprites(pc)				; Clear sprites
	jsr	RunObjects(pc)					; Run objects
	bsr.w	PaletteCycle					; Run palette cycle
	bsr.w	ScrollBgBuf2					; Scroll background (show buffer 2)
	move.w	#0,vblank_routine				; VSync (copy 1st half of last cloud image to buffer 1)
	bsr.w	VSync

	jsr	ClearSprites(pc)				; Clear sprites
	jsr	RunObjects(pc)					; Run objects
	move.w	#1,vblank_routine				; VSync (copy 2nd half of last cloud image to buffer 1)
	bsr.w	VSync

	bsr.w	WaitWordRamAccess				; Wait for Word RAM access
	bsr.w	GetCloudImage					; Get cloud image
	bsr.w	GiveWordRamAccess				; Give back Word RAM access

	tst.b	exit_flag					; Are we exiting the title screen?
	bne.s	.Exit						; If so, branch
	
	; Show buffer 1, render to buffer 2
	jsr	ClearSprites(pc)				; Clear sprites
	jsr	RunObjects(pc)					; Run objects
	bsr.w	PaletteCycle					; Run palette cycle
	bsr.w	RenderClouds					; Start rendering clouds
	bsr.w	ScrollBgBuf1					; Scroll background (show buffer 1)
	move.w	#2,vblank_routine				; VSync (copy 1st half of last cloud image to buffer 2)
	bsr.w	VSync

	jsr	ClearSprites(pc)				; Clear sprites
	jsr	RunObjects(pc)					; Run objects
	move.w	#3,vblank_routine				; VSync (copy 2nd half of last cloud image to buffer 2)
	bsr.w	VSync

	bsr.w	WaitWordRamAccess				; Wait for Word RAM access
	bsr.w	GetCloudImage					; Get cloud image
	bsr.w	GiveWordRamAccess				; Give back Word RAM access

	tst.b	exit_flag					; Are we exiting the title screen?
	bne.s	.Exit						; If so, branch
	bra.w	MainLoop					; Loop

.Exit:
	if REGION=USA
		cmpi.b	#4,sub_fail_count			; Is the Sub CPU deemed unreliable?
		bcc.s	.FadeOut				; If so, branch
	endif
	bset	#0,MCD_MAIN_FLAG				; Tell Sub CPU we are finished

.WaitSubCpu:
	btst	#0,MCD_SUB_FLAG					; Has the Sub CPU received our tip?
	beq.s	.WaitSubCpu					; If not, branch
	bclr	#0,MCD_MAIN_FLAG				; Respond to the Sub CPU

.FadeOut:
	move.w	#5,vblank_routine				; Fade to black
	bsr.w	FadeToBlack

	moveq	#0,d1						; Set exit code
	move.b	exit_flag,d1
	bmi.s	.NegFlag					; If it was negative, branch
	rts

.NegFlag:
	moveq	#0,d1						; Override with 0
	rts

; ------------------------------------------------------------------------------
; VSync
; ------------------------------------------------------------------------------

VSync:
	bset	#0,ipx_vsync					; Set VSync flag
	move	#$2500,sr					; Enable interrupts

.Wait:
	btst	#0,ipx_vsync					; Has the V-BLANK interrupt handler run?
	bne.s	.Wait						; If not, wait
	rts

; ------------------------------------------------------------------------------
; V-BLANK interrupt
; ------------------------------------------------------------------------------

VInterrupt:
	movem.l	d0-a6,-(sp)					; Save registers

	move.b	#1,MCD_IRQ2					; Trigger IRQ2 on Sub CPU
	
	bclr	#0,ipx_vsync					; Clear VSync flag
	beq.w	VInt_Lag					; If it wasn't set, branch
	
	tst.b	enable_display					; Should we enable the display?
	beq.s	.Update						; If not, branch
	
	bset	#6,ipx_vdp_reg_81+1				; Enable display
	move.w	ipx_vdp_reg_81,VDP_CTRL
	clr.b	enable_display					; Clear enable display flag

.Update:
	lea	VDP_CTRL,a1					; VDP control port
	lea	VDP_DATA,a2					; VDP data port
	move.w	(a1),d0						; Reset V-BLANK flag

	jsr	StopZ80(pc)					; Stop the Z80
	DMA_M68K palette,$0000,$80,CRAM				; Copy palette data
	DMA_M68K hscroll,$D000,$380,VRAM			; Copy horizontal scroll data

	move.w	vblank_routine,d0				; Run routine
	add.w	d0,d0
	move.w	.Routines(pc,d0.w),d0
	jmp	.Routines(pc,d0.w)

; ------------------------------------------------------------------------------

.Routines:
	dc.w	VInt_CopyClouds1_1-.Routines
	dc.w	VInt_CopyClouds1_2-.Routines
	dc.w	VInt_CopyClouds2_1-.Routines
	dc.w	VInt_CopyClouds2_2-.Routines
	dc.w	VInt_Nothing-.Routines
	dc.w	VInt_NoClouds-.Routines

; ------------------------------------------------------------------------------

VInt_CopyClouds1_1:
	DMA_M68K sprites,$D400,$280,VRAM			; Copy sprite data
	COPYIMG	cloud_image,0,0					; Copy cloud image
	jsr	ReadControllers(pc)				; Read controllers
	bra.w	VInt_Finish					; Finish

; ------------------------------------------------------------------------------

VInt_CopyClouds1_2:
	DMA_M68K sprites,$D400,$280,VRAM			; Copy sprite data
	COPYIMG	cloud_image,0,1					; Copy cloud image
	jsr	ReadControllers(pc)				; Read controllers
	bra.w	VInt_Finish					; Finish

; ------------------------------------------------------------------------------

VInt_CopyClouds2_1:
	DMA_M68K sprites,$D400,$280,VRAM			; Copy sprite data
	COPYIMG	cloud_image,1,0					; Copy cloud image
	jsr	ReadControllers(pc)				; Read controllers
	bra.w	VInt_Finish					; Finish

; ------------------------------------------------------------------------------

VInt_CopyClouds2_2:
	DMA_M68K sprites,$D400,$280,VRAM			; Copy sprite data
	COPYIMG	cloud_image,1,1					; Copy cloud image
	jsr	ReadControllers(pc)				; Read controllers
	bra.w	VInt_Finish					; Finish

; ------------------------------------------------------------------------------

VInt_Nothing:
	bra.w	VInt_Finish					; Finish

; ------------------------------------------------------------------------------

VInt_NoClouds:
	DMA_M68K sprites,$D400,$280,VRAM			; Copy sprite data
	jsr	ReadControllers(pc)				; Read controllers

; ------------------------------------------------------------------------------

VInt_Finish:
	tst.b	fm_sound_queue					; Is there a sound queued?
	beq.s	.NoSound					; If not, branch
	move.b	fm_sound_queue,FMDrvQueue2			; Queue sound in driver
	clr.b	fm_sound_queue					; Clear sound queue

.NoSound:
	bsr.w	StartZ80					; Start the Z80
	
	tst.w	timer						; Is the timer running?
	beq.s	.NoTimer					; If not, branch
	subq.w	#1,timer					; Decrement timer

.NoTimer:
	addq.w	#1,frame_count					; Increment frame count
	
	movem.l	(sp)+,d0-a6					; Restore registers
	rte

; ------------------------------------------------------------------------------

VInt_Lag:
	cmpi.l	#-1,lag_counter					; Is the lag counter disabled?
	beq.s	.NoLagCounter					; If so, branch
	addq.l	#1,lag_counter					; Increment lag counter
	move.b	vblank_routine+1,lag_counter			; Save routine ID

.NoLagCounter:
	movem.l	(sp)+,d0-a6					; Restore registers
	rte

; ------------------------------------------------------------------------------
; Unused functions to show a buffer
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - VDP control port
;	a2.l - VDP data port
; ------------------------------------------------------------------------------

ShowCloudsBuf1:
	move.w	#$8F20,(a1)					; Set for every 8 scanlines
	VDP_CMD move.l,$D002,VRAM,WRITE,VDP_CTRL		; Write background scroll data
	moveq	#0,d0						; Show buffer 1
	bra.s	ShowCloudsBuf

; ------------------------------------------------------------------------------

ShowCloudsBuf2:
	move.w	#$8F20,(a1)					; Set for every 8 scanlines
	VDP_CMD move.l,$D002,VRAM,WRITE,VDP_CTRL		; Write background scroll data
	move.w	#$100,d0					; Show buffer 2

; ------------------------------------------------------------------------------

ShowCloudsBuf:
	rept	(IMGHEIGHT-8)/8					; Set scroll offset for clouds
		move.w	d0,(a2)
	endr
	move.w	#$8F02,(a1)					; Restore autoincrement
	rts

; ------------------------------------------------------------------------------
; Scroll background (show buffer 1)
; ------------------------------------------------------------------------------

ScrollBgBuf1:
	lea	hscroll,a1					; Show buffer 1
	moveq	#(IMGHEIGHT-8)-1,d1

.ShowClouds:
	clr.l	(a1)+
	dbf	d1,.ShowClouds

	lea	water_scroll,a2					; Water scroll buffer
	moveq	#64-1,d2					; 64 scanlines
	move.l	#$1000,d1					; Speed accumulator
	move.l	#$4000,d0					; Initial speed

.MoveWaterSects:
	add.l	d0,(a2)+					; Move water line
	add.l	d1,d0						; Increase speed
	dbf	d2,.MoveWaterSects				; Loop until all lines are moved

	lea	water_scroll,a2					; Set water scroll positions
	lea	hscroll+(160*4),a1
	moveq	#64-1,d2					; 64 scanlines
	moveq	#0,d0

.SetWaterScroll:
	move.w	(a2),d0						; Set scanline offset
	move.l	d0,(a1)+
	lea	4(a2),a2					; Next line
	dbf	d2,.SetWaterScroll				; Loop until all scanlines are set
	rts

; ------------------------------------------------------------------------------
; Scroll background (show buffer 2)
; ------------------------------------------------------------------------------

ScrollBgBuf2:
	lea	hscroll,a1					; Show buffer 2
	moveq	#(IMGHEIGHT-8)-1,d1

.ShowClouds:
	move.l	#$100,(a1)+
	dbf	d1,.ShowClouds

	lea	water_scroll,a2					; Water scroll buffer
	moveq	#64-1,d2					; 64 scanlines
	move.l	#$1000,d1					; Speed accumulator
	move.l	#$4000,d0					; Initial speed

.MoveWaterSects:
	add.l	d0,(a2)+					; Move water line
	add.l	d1,d0						; Increase speed
	dbf	d2,.MoveWaterSects				; Loop until all lines are moved

	lea	water_scroll,a2					; Set water scroll positions
	lea	hscroll+(160*4),a1
	moveq	#64-1,d2					; 64 scanlines
	moveq	#0,d0

.SetWaterScroll:
	move.w	(a2),d0						; Set scanline offset
	move.l	d0,(a1)+
	lea	4(a2),a2					; Next line
	dbf	d2,.SetWaterScroll				; Loop until all scanlines are set
	rts

; ------------------------------------------------------------------------------
; Read controller data
; ------------------------------------------------------------------------------

ReadControllers:
	lea	p1_ctrl_data,a0					; Player 1 controller data buffer
	lea	IO_DATA_1,a1					; Controller port 1
	bsr.s	ReadController					; Read controller data
	
	lea	p2_ctrl_data,a0					; Player 2 controller data buffer
	lea	IODATA2,a1					; Controller port 2

	tst.b	control_clouds					; Are the clouds controllable?
	beq.s	ReadController					; If not, branch
	
	move.w	p2_ctrl_data,sub_p2_ctrl_data			; Send controller data to Sub CPU for controlling the clouds

; ------------------------------------------------------------------------------

ReadController:
	move.b	#0,(a1)						; TH = 0
	tst.w	(a0)						; Delay
	move.b	(a1),d0						; Read start and A buttons
	lsl.b	#2,d0
	andi.b	#$C0,d0
	
	move.b	#$40,(a1)					; TH = 1
	tst.w	(a0)						; Delay
	move.b	(a1),d1						; Read B, C, and D-pad buttons
	andi.b	#$3F,d1

	or.b	d1,d0						; Combine button data
	not.b	d0						; Flip bits
	move.b	d0,d1						; Make copy

	move.b	(a0),d2						; Mask out tapped buttons
	eor.b	d2,d0
	move.b	d1,(a0)+					; Store pressed buttons
	and.b	d1,d0						; Store tapped buttons
	move.b	d0,(a0)+
	rts

; ------------------------------------------------------------------------------
; Run palette cycle
; ------------------------------------------------------------------------------

PaletteCycle:
	addi.b	#$40,palette_cycle_delay			; Run delay timer
	bcs.s	.Update						; If it's time to update, branch
	rts

.Update:
	moveq	#0,d0						; Get frame
	move.b	palette_cycle_frame,d0
	addq.b	#1,d0						; Increment frame
	cmpi.b	#3,d0						; Is it time to wrap?
	bcs.s	.NoWrap						; If not, branch
	clr.b	d0						; Wrap back to start

.NoWrap:
	move.b	d0,palette_cycle_frame				; Update frame ID

	lea	.WaterPalCycle(pc),a1				; Set palette cycle colors
	lea	palette+(5*2),a2
	add.b	d0,d0
	add.b	d0,d0
	add.b	d0,d0
	lea	(a1,d0.w),a1
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	rts

; ------------------------------------------------------------------------------

.WaterPalCycle:
	dc.w	$ECC, $ECA, $EEE, $EA8
	dc.w	$EA8, $ECC, $ECC, $ECA
	dc.w	$ECA, $EA8, $ECA, $ECC

; ------------------------------------------------------------------------------
; Draw cloud tilemap
; ------------------------------------------------------------------------------

DrawCloudTilemap:
	lea	VDP_CTRL,a2					; VDP control port
	lea	VDP_DATA,a3					; VDP data port

	move.w	#$8001,d6					; Draw buffer 1 tilemap
	VDP_CMD move.l,$E000,VRAM,WRITE,d0
	moveq	#IMGWTILE-1,d1
	moveq	#IMGHTILE-1,d2
	bsr.s	.DrawMap

	move.w	#$8181,d6					; Draw buffer 2 tilemap
	VDP_CMD move.l,$E040,VRAM,WRITE,d0
	moveq	#IMGWTILE-1,d1
	moveq	#IMGHTILE-1,d2

; ------------------------------------------------------------------------------

.DrawMap:
	move.l	#$800000,d4					; Row delta

.DrawRow:
	move.l	d0,(a2)						; Set VDP command
	move.w	d1,d3						; Get width
	move.w	d6,d5						; Get first column tile

.DrawTile:
	move.w	d5,(a3)						; Write tile ID
	addi.w	#IMGHTILE,d5					; Next column tile
	dbf	d3,.DrawTile					; Loop until row is written
	
	add.l	d4,d0						; Next row
	addq.w	#1,d6						; Next column tile
	dbf	d2,.DrawRow					; Loop until map is drawn
	rts

; ------------------------------------------------------------------------------
; Render clouds
; ------------------------------------------------------------------------------

RenderClouds:
	cmpi.b	#4,sub_fail_count				; Is the Sub CPU deemed unreliable?
	bcc.s	.End						; If so, branch
	
	move.b	#1,MCD_MAIN_COMM_2				; Tell Sub CPU to render clouds

.WaitSubCpu:
	cmpi.b	#1,MCD_SUB_COMM_2				; Has the Sub CPU responded?
	beq.s	.CommDone					; If so, branch
	addq.w	#1,sub_wait_time				; Increment wait time
	bcc.s	.WaitSubCpu					; If we should wait some more, loop

.CommDone:
	clr.l	sub_wait_time					; Reset Sub CPU wait time
	move.b	#0,MCD_MAIN_COMM_2				; Respond to the Sub CPU

.WaitSubCpu2:
	tst.b	MCD_SUB_COMM_2					; Has the Sub CPU responded?
	beq.s	.End						; If so, branch
	
	addq.w	#1,sub_wait_time				; Increment wait time
	bcc.s	.WaitSubCpu2					; If we should wait some more, loop

.End:
	clr.l	sub_wait_time					; Reset Sub CPU wait time
	rts

; ------------------------------------------------------------------------------
; Wait for the Sub CPU program to start
; ------------------------------------------------------------------------------

WaitSubCpuStart:
	cmpi.b	#4,sub_fail_count				; Is the Sub CPU deemed unreliable?
	bcc.s	.End						; If so, branch
	
	btst	#7,MCD_SUB_FLAG					; Has the Sub CPU program started?
	bne.s	.End						; If so, branch
	
	addq.w	#1,sub_wait_time				; Increment wait time
	bcc.s	WaitSubCpuStart					; If we should wait some more, loop
	addq.b	#1,sub_fail_count				; Increment Sub CPU fail count

.End:
	clr.l	sub_wait_time					; Reset Sub CPU wait time
	rts

; ------------------------------------------------------------------------------
; Wait for the Sub CPU program to finish initializing
; ------------------------------------------------------------------------------

WaitSubCpuInit:
	cmpi.b	#4,sub_fail_count				; Is the Sub CPU deemed unreliable?
	bcc.s	.End						; If so, branch
	
	btst	#7,MCD_SUB_FLAG					; Has the Sub CPU program initialized?
	beq.s	.End						; If so, branch
	
	addq.w	#1,sub_wait_time				; Increment wait time
	bcc.s	WaitSubCpuInit					; If we should wait some more, loop
	addq.b	#1,sub_fail_count				; Increment Sub CPU fail count

.End:
	clr.l	sub_wait_time					; Reset Sub CPU wait time
	rts

; ------------------------------------------------------------------------------
; Give Sub CPU Word RAM access
; ------------------------------------------------------------------------------

GiveWordRamAccess:
	cmpi.b	#4,sub_fail_count				; Is the Sub CPU deemed unreliable?
	bcc.s	.Done						; If so, branch
	
	btst	#1,MCD_MEM_MODE					; Does the Sub CPU already have Word RAM Access?
	bne.s	.End						; If so, branch
	bset	#1,MCD_MEM_MODE					; Give Sub CPU Word RAM access

.Wait:
	btst	#1,MCD_MEM_MODE					; Has it been given?
	bne.s	.Done						; If so, branch
	addq.w	#1,sub_wait_time				; Increment wait time
	bcc.s	.Wait						; If we should wait some more, loop
	addq.b	#1,sub_fail_count				; Increment Sub CPU fail count

.Done:
	clr.l	sub_wait_time					; Reset Sub CPU wait time

.End:
	rts

; ------------------------------------------------------------------------------
; Wait for Word RAM access
; ------------------------------------------------------------------------------

WaitWordRamAccess:
	cmpi.b	#4,sub_fail_count				; Is the Sub CPU deemed unreliable?
	bcc.s	.End						; If so, branch

	btst	#0,MCD_MEM_MODE					; Do we have Word RAM access?
	bne.s	.End						; If so, branch

	addq.w	#1,sub_wait_time				; Increment wait time
	bcc.s	WaitWordRamAccess				; If we should wait some more, loop
	addq.b	#1,sub_fail_count				; Increment Sub CPU fail count

.End:
	clr.l	sub_wait_time					; Reset Sub CPU wait time
	rts

; ------------------------------------------------------------------------------
; Initialize the Mega Drive hardware
; ------------------------------------------------------------------------------

InitMegaDrive:
	lea	.VDPRegs(pc),a0					; Set up VDP registers
	move.w	#$8000,d0
	moveq	#.VDPRegsEnd-.VDPRegs-1,d7

.SetVDPRegs:
	move.b	(a0)+,d0
	move.w	d0,VDP_CTRL
	addi.w	#$100,d0
	dbf	d7,.SetVDPRegs

	moveq	#$40,d0						; Set up controller ports
	move.b	d0,IO_CTRL_1
	move.b	d0,IO_CTRL_2
	move.b	d0,IO_CTRL_3
	move.b	#$C0,IO_DATA_1

	jsr	StopZ80(pc)					; Stop the Z80

	DMAFILL	0,$10000,0					; Clear VRAM

	lea	.Palette(pc),a0					; Load palette
	lea	palette,a1
	moveq	#(.PaletteEnd-.Palette)/4-1,d7

.LoadPal:
	move.l	(a0)+,d0
	move.l	d0,(a1)+
	dbf	d7,.LoadPal

	VDP_CMD move.l,0,VSRAM,WRITE,VDP_CTRL			; Clear VSRAM
	move.l	#0,VDP_DATA

	jsr	StartZ80(pc)					; Start the Z80
	move.w	#$8134,ipx_vdp_reg_81				; Reset IPX VDP register 1 cache
	rts

; ------------------------------------------------------------------------------

.VDPRegs:
	dc.b	%00000100					; No H-BLANK interrupt
	dc.b	%00110100					; V-BLANK interrupt, DMA, mode 5
	dc.b	$C000/$400					; Plane A location
	dc.b	0						; Window location
	dc.b	$E000/$2000					; Plane B location
	dc.b	$D400/$200					; Sprite table location
	dc.b	0						; Reserved
	dc.b	0						; BG color line 0 color 0
	dc.b	0						; Reserved
	dc.b	0						; Reserved
	dc.b	0						; H-INT counter 0
	dc.b	%00000011					; Scroll by line
	dc.b	%00000000					; H32
	dc.b	$D000/$400					; Horizontal scroll table lcation
	dc.b	0						; Reserved
	dc.b	2						; Auto increment by 2
	dc.b	%00000001					; 64x32 tile plane size
	dc.b	0						; Window horizontal position 0
	dc.b	0						; Window vertical position 0
.VDPRegsEnd:
	even

.Palette:
	incbin	"Title Screen/Data/Palette (Initialization).bin"
.PaletteEnd:
	even

; ------------------------------------------------------------------------------
; Palette
; ------------------------------------------------------------------------------

Pal_Title:
	incbin	"Title Screen/Data/Palette.bin"
	even

; ------------------------------------------------------------------------------
; Stop the Z80
; ------------------------------------------------------------------------------

StopZ80:
	move	sr,saved_sr					; Save status register
	move	#$2700,sr					; Disable interrupts
	Z80STOP							; Stop the Z80
	rts

; ------------------------------------------------------------------------------
; Start the Z80
; ------------------------------------------------------------------------------

StartZ80:
	Z80START						; Start the Z80
	move	saved_sr,sr					; Restore status register
	rts

; ------------------------------------------------------------------------------
; Get cloud image
; ------------------------------------------------------------------------------

GetCloudImage:
	lea	WORD_RAM_2M+IMGBUFFER,a1			; Rendered image in Word RAM
	lea	cloud_image,a2					; Destination buffer
	move.w	#(IMGLENGTH/$800)-1,d7				; Number of $800 byte chunks to copy

.CopyChunks:
	rept	$800/$80					; Copy $800 bytes
		bsr.s	Copy128
	endr
	dbf	d7,.CopyChunks					; Loop until chunks are copied
	rts

; ------------------------------------------------------------------------------
; Copy 128 bytes from a source to a destination buffer
; ------------------------------------------------------------------------------
; PARAMAETERS:
;	a1.l - Pointer to source
;	a2.l - Pointer to destination buffer
; RETURNS:
;	a2.l - Pointer to source buffer, advanced by $80 bytes
;	a2.l - Pointer to destination buffer, advanced by $80 bytes
; ------------------------------------------------------------------------------

Copy128:
	rept $80/$20						; Copy bytes
		movem.l	(a1)+,d0-d5/a3-a4
		movem.l	d0-d5/a3-a4,(a2)
	endr
	lea	$80(a2),a2					; Advance destination buffer pointer
	rts

; ------------------------------------------------------------------------------
; Fade to black
; ------------------------------------------------------------------------------

FadeToBlack:
	move.w	#(0<<9)|($40-1),palette_fade_params		; Fade entire palette
	move.w	#(7*3),d4					; Number of fade frames

.Loop:
	move.b	#1,unk_palette_fade_flag			; Set unknown flag
	bsr.w	VSync						; VSync
	bsr.s	FadeToBlackFrame				; Do a frame of fading
	dbf	d4,.Loop					; Loop until palette is faded
	rts

; ------------------------------------------------------------------------------
; Do a frame of a fade to black
; ------------------------------------------------------------------------------

FadeToBlackFrame:
	moveq	#0,d0						; Get palette offset
	lea	palette,a0
	move.b	palette_fade_start,d0
	adda.w	d0,a0

	move.b	palette_fade_length,d0				; Get color count

.FadeColors:
	bsr.s	FadeColorToBlack				; Fade color
	dbf	d0,.FadeColors					; Loop until all colors have faded a frame
	rts

; ------------------------------------------------------------------------------
; Fade a color to black
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to palette color
; RETURNS:
;	a0.l - Pointer to next color
; ------------------------------------------------------------------------------

FadeColorToBlack:
	move.w	(a0),d2						; Get color
	beq.s	.End						; If it's already black, branch

.CheckRed:
	move.w	d2,d1						; Check red channel
	andi.w	#$E,d1
	beq.s	.CheckGreen					; If it's already 0, branch
	subq.w	#2,(a0)+					; Decrement red channel
	rts

.CheckGreen:
	move.w	d2,d1						; Check green channel
	andi.w	#$E0,d1
	beq.s	.CheckBlue					; If it's already 0, branch
	subi.w	#$20,(a0)+					; Decrement green channel
	rts

.CheckBlue:
	move.w	d2,d1						; Check blue channel
	andi.w	#$E00,d1
	beq.s	.End						; If it's already 0, branch
	subi.w	#$200,(a0)+					; Decrement blue channel
	rts

.End:
	addq.w	#2,a0						; Skip to next color
	rts

; ------------------------------------------------------------------------------
; Fade from black
; ------------------------------------------------------------------------------

FadeFromBlack:
	moveq	#0,d0						; Get palette offset
	lea	palette,a0
	move.b	palette_fade_start,d0
	adda.w	d0,a0
	
	moveq	#0,d1						; Black
	move.b	palette_fade_length,d0				; Get color count

.FillBlack:
	move.w	d1,(a0)+					; Fill palette region with black
	dbf	d0,.FillBlack

	move.w	#(7*3),d4					; Number of fade frames

.Loop:
	move.b	#1,unk_palette_fade_flag			; Set unknown flag
	bsr.w	VSync						; VSync
	bsr.s	FadeFromBlackFrame				; Do a frame of fading
	dbf	d4,.Loop					; Loop until palette is faded
	rts

; ------------------------------------------------------------------------------
; Do a frame of a fade from black
; ------------------------------------------------------------------------------

FadeFromBlackFrame:
	moveq	#0,d0						; Get palette offsets
	lea	palette,a0
	lea	fade_palette,a1
	move.b	palette_fade_start,d0
	adda.w	d0,a0
	adda.w	d0,a1
	
	move.b	palette_fade_length,d0				; Get color count

.FadeColors:
	bsr.s	FadeColorFromBlack				; Fade color
	dbf	d0,.FadeColors					; Loop until all colors have faded a frame
	rts

; ------------------------------------------------------------------------------
; Fade a color from black
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to palette color
;	a1.l - Pointer to target palette color
; RETURNS:
;	a0.l - Pointer to next color
;	a1.l - Pointer to next target color
; ------------------------------------------------------------------------------

FadeColorFromBlack:
	move.w	(a1)+,d2					; Get target color
	move.w	(a0),d3						; Get color
	cmp.w	d2,d3						; Are they the same?
	beq.s	.End						; If so, branch

.CheckBlue:
	move.w	d3,d1						; Increment blue channel
	addi.w	#$200,d1
	cmp.w	d2,d1						; Have we gone past the target channel value?
	bhi.s	.CheckGreen					; If so, branch
	move.w	d1,(a0)+					; Update color
	rts

.CheckGreen:
	move.w	d3,d1						; Increment green channel
	addi.w	#$20,d1
	cmp.w	d2,d1						; Have we gone past the target channel value?
	bhi.s	.IncRed						; If so, branch
	move.w	d1,(a0)+					; Update color
	rts

.IncRed:
	addq.w	#2,(a0)+					; Increment red channel
	rts

.End:
	addq.w	#2,a0						; Skip to next color
	rts

; ------------------------------------------------------------------------------
; Fade from white
; ------------------------------------------------------------------------------

FadeFromWhite:
	move.w	#($00<<9)|($40-1),palette_fade_params		; Fade entire palette
	
FadeFromWhite2:
	moveq	#0,d0						; Get palette offset
	lea	palette,a0
	move.b	palette_fade_start,d0
	adda.w	d0,a0
	
	move.w	#$EEE,d1					; White
	move.b	palette_fade_length,d0				; Get color count

.FillWhite:
	move.w	d1,(a0)+					; Fill palette region with black
	dbf	d0,.FillWhite
	move.w	#0,palette+($2E*2)				; Set line 2 color 14 to black

	move.w	#(7*3),d4					; Number of fade frames

.Loop:
	move.b	#1,unk_palette_fade_flag			; Set unknown flag
	bsr.w	VSync						; VSync
	
	move.l	d4,-(sp)					; Scrapped code?
	move.l	(sp)+,d4
	
	bsr.s	FadeFromWhiteFrame				; Do a frame of fading
	dbf	d4,.Loop					; Loop until palette is faded
	
	clr.b	unk_palette_fade_flag				; Clear unknown flag
	rts

; ------------------------------------------------------------------------------
; Do a frame of a fade from white
; ------------------------------------------------------------------------------

FadeFromWhiteFrame:
	moveq	#0,d0						; Get palette offsets
	lea	palette,a0
	lea	fade_palette,a1
	move.b	palette_fade_start,d0
	adda.w	d0,a0
	adda.w	d0,a1
	
	move.b	palette_fade_length,d0				; Get color count

.FadeColors:
	bsr.s	FadeColorFromWhite				; Fade color
	dbf	d0,.FadeColors					; Loop until all colors have faded a frame
	rts

; ------------------------------------------------------------------------------
; Fade a color from white
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to palette color
;	a1.l - Pointer to target palette color
; RETURNS:
;	a0.l - Pointer to next color
;	a1.l - Pointer to next target color
; ------------------------------------------------------------------------------

FadeColorFromWhite:
	move.w	(a1)+,d2					; Get target color
	move.w	(a0),d3						; Get color
	cmp.w	d2,d3						; Are they the same?
	beq.s	.End						; If so, branch

.CheckBlue:
	move.w	d3,d1						; Decrement blue channel
	subi.w	#$200,d1
	bcs.s	.CheckGreen					; If it underflowed, branch
	cmp.w	d2,d1						; Have we gone past the target channel value?
	bcs.s	.CheckGreen					; If so, branch
	move.w	d1,(a0)+					; Update color
	rts

.CheckGreen:
	move.w	d3,d1						; Decrement green channel
	subi.w	#$20,d1
	bcs.s	.IncRed						; If it underflowed, branch
	cmp.w	d2,d1						; Have we gone past the target channel value?
	bcs.s	.IncRed						; If so, branch
	move.w	d1,(a0)+					; Update color
	rts

.IncRed:
	subq.w	#2,(a0)+					; Decrement red channel
	rts

.End:
	addq.w	#2,a0						; Skip to next color
	rts

; ------------------------------------------------------------------------------
; Fade to white
; ------------------------------------------------------------------------------

FadeToWhite:
	move.w	#(0<<9)|($40-1),palette_fade_params		; Fade entire palette
	move.w	#(7*3),d4					; Number of fade frames

.Loop:
	move.b	#1,unk_palette_fade_flag			; Set unknown flag
	bsr.w	VSync						; VSync
	bsr.s	FadeToWhiteFrame				; Do a frame of fading
	dbf	d4,.Loop					; Loop until palette is faded
	
	clr.b	unk_palette_fade_flag				; Clear unknown flag
	rts

; ------------------------------------------------------------------------------
; Do a frame of a fade to white
; ------------------------------------------------------------------------------

FadeToWhiteFrame:
	moveq	#0,d0						; Get palette offset
	lea	palette,a0
	move.b	palette_fade_start,d0
	adda.w	d0,a0

	move.b	palette_fade_length,d0				; Get color count

.FadeColors:
	bsr.s	FadeColorToWhite				; Fade color
	dbf	d0,.FadeColors					; Loop until all colors have faded a frame
	rts

; ------------------------------------------------------------------------------
; Fade a color to white
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to palette color
; RETURNS:
;	a0.l - Pointer to next color
; ------------------------------------------------------------------------------

FadeColorToWhite:
	move.w	(a0),d2						; Get color
	cmpi.w	#$EEE,d2					; Is it already white?
	beq.s	.End						; If so, branch

.CheckRed:
	move.w	d2,d1						; Check red channel
	andi.w	#$E,d1
	cmpi.w	#$E,d1						; Is it already at max?
	beq.s	.CheckGreen					; If so, branch
	addq.w	#2,(a0)+					; Decrement red channel
	rts

.CheckGreen:
	move.w	d2,d1						; Check green channel
	andi.w	#$E0,d1
	cmpi.w	#$E0,d1						; Is it already at max?
	beq.s	.CheckBlue					; If so, branch
	addi.w	#$20,(a0)+					; Decrement green channel
	rts

.CheckBlue:
	move.w	d2,d1						; Check blue channel
	andi.w	#$E00,d1
	cmpi.w	#$E00,d1					; Is it already at max?
	beq.s	.End						; If so, branch
	addi.w	#$200,(a0)+					; Decrement blue channel
	rts

.End:
	addq.w	#2,a0						; Skip to next color
	rts
	
; ------------------------------------------------------------------------------
; Advance Nemesis data bitstream
; ------------------------------------------------------------------------------
; PARAMETERS:
;	branch - Branch to take if no new byte is needed (optional)
; ------------------------------------------------------------------------------

NEMESIS_ADVANCE macro branch
	cmpi.w	#9,d6						; Does a new byte need to be read?
	if narg>1						; If not, branch
		bcc.s	\branch
	else
		bcc.s	.NoNewByte\@
	endm
	
	addq.w	#8,d6						; Read next byte
	asl.w	#8,d5
	move.b	(a0)+,d5

.NoNewByte\@:
	endm

; ------------------------------------------------------------------------------
; Decompress Nemesis art into VRAM (Note: VDP write command must be
; set beforehand)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Nemesis art pointer
; ------------------------------------------------------------------------------

NemDec:
	movem.l	d0-a1/a3-a5,-(sp)				; Save registers
	lea	WriteNemRowVdp,a3				; Write all data to the same location
	lea	VDP_DATA,a4					; VDP data port
	bra.s	NemDecMain

; ------------------------------------------------------------------------------
; Decompress Nemesis data into RAM
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Nemesis data pointer
;	a4.l - Destination buffer pointer
; ------------------------------------------------------------------------------

NemDecToRam:
	movem.l	d0-a1/a3-a5,-(sp)				; Save registers
	lea	WriteNemRow,a3					; Advance to the next location after each write

; ------------------------------------------------------------------------------

NemDecMain:
	lea	nem_code_table,a1				; Prepare decompression buffer
	
	move.w	(a0)+,d2					; Get number of tiles
	lsl.w	#1,d2						; Should we use XOR mode?
	bcc.s	.GetRows					; If not, branch
	adda.w	#WriteNemRowVdpXor-WriteNemRowVdp,a3		; Use XOR mode

.GetRows:
	lsl.w	#2,d2						; Get number of rows
	movea.w	d2,a5
	moveq	#8,d3						; 8 pixels per row
	moveq	#0,d2						; XOR row buffer
	moveq	#0,d4						; Row buffer
	
	bsr.w	BuildNemCodeTable				; Build code table
	
	move.b	(a0)+,d5					; Get first word of compressed data
	asl.w	#8,d5
	move.b	(a0)+,d5
	move.w	#16,d6						; Set bitstream read data position
	
	bsr.s	DecompressNemData				; Decompress data
	
	movem.l	(sp)+,d0-a1/a3-a5				; Restore registers
	rts

; ------------------------------------------------------------------------------

DecompressNemData:
	move.w	d6,d7						; Peek 8 bits from bitstream
	subq.w	#8,d7
	move.w	d5,d1
	lsr.w	d7,d1
	cmpi.b	#%11111100,d1					; Should we read inline data?
	bcc.s	ReadInlineNemData				; If so, branch
	
	andi.w	#$FF,d1						; Get code length
	add.w	d1,d1
	move.b	(a1,d1.w),d0
	ext.w	d0
	
	sub.w	d0,d6						; Advance bitstream read data position
	NEMESIS_ADVANCE

	move.b	1(a1,d1.w),d1					; Get palette index
	move.w	d1,d0
	andi.w	#$F,d1
	andi.w	#$F0,d0						; Get repeat count

GetNemCodeLength:
	lsr.w	#4,d0						; Isolate repeat count

WriteNemPixel:
	lsl.l	#4,d4						; Shift up by a nibble
	or.b	d1,d4						; Write pixel
	subq.w	#1,d3						; Has an entire 8-pixel row been written?
	bne.s	NextNemPixel					; If not, loop
	jmp	(a3)						; Otherwise, write the row to its destination

; ------------------------------------------------------------------------------

ResetNemRow:
	moveq	#0,d4						; Reset row
	moveq	#8,d3						; Reset nibble counter

NextNemPixel:
	dbf	d0,WriteNemPixel				; Loop until finished
	bra.s	DecompressNemData				; Read next code

; ------------------------------------------------------------------------------

ReadInlineNemData:
	subq.w	#6,d6						; Advance bitstream read data position
	NEMESIS_ADVANCE

	subq.w	#7,d6						; Read inline data
	move.w	d5,d1
	lsr.w	d6,d1
	move.w	d1,d0
	andi.w	#$F,d1						; Get palette index
	andi.w	#$70,d0						; Get repeat count
	
	NEMESIS_ADVANCE GetNemCodeLength			; Advance bitstream read data position
	bra.s	GetNemCodeLength

; ------------------------------------------------------------------------------

WriteNemRowVdp:
	move.l	d4,(a4)						; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

WriteNemRowVdpXor:
	eor.l	d4,d2						; XOR the previous row with the current row
	move.l	d2,(a4)						; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

WriteNemRow:
	move.l	d4,(a4)+					; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

WriteNemRowXor:
	eor.l	d4,d2						; XOR the previous row with the current row
	move.l	d2,(a4)+					; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

BuildNemCodeTable:
	move.b	(a0)+,d0					; Read first byte

.CheckEnd:
	cmpi.b	#$FF,d0						; Has the end of the code table been reached?
	bne.s	.NewPaletteIndex				; If not, branch
	rts

.NewPaletteIndex:
	move.w	d0,d7						; Set palette index

.Loop:
	move.b	(a0)+,d0					; Read next byte
	cmpi.b	#$80,d0						; Should we set a new palette index?
	bcc.s	.CheckEnd					; If so, branch

	move.b	d0,d1						; Copy repeat count
	andi.w	#$F,d7						; Get palette index
	andi.w	#$70,d1						; Get repeat count
	or.w	d1,d7						; Combine them
	
	andi.w	#$F,d0						; Get code length
	move.b	d0,d1
	lsl.w	#8,d1
	or.w	d1,d7						; Combine with palette index and repeat count
	
	moveq	#8,d1						; Is the code length 8 bits in size?
	sub.w	d0,d1
	bne.s	.ShortCode					; If not, branch
	
	move.b	(a0)+,d0					; Store code entry
	add.w	d0,d0
	move.w	d7,(a1,d0.w)
	bra.s	.Loop

.ShortCode:
	move.b	(a0)+,d0					; Get index
	lsl.w	d1,d0
	add.w	d0,d0
	
	moveq	#1,d5						; Get number of entries
	lsl.w	d1,d5
	subq.w	#1,d5

.ShortCode_Loop:
	move.w	d7,(a1,d0.w)					; Store code entry
	addq.w	#2,d0						; Increment index
	dbf	d5,.ShortCode_Loop				; Loop until finished
	bra.s	.Loop

; ------------------------------------------------------------------------------
; Run objects
; ------------------------------------------------------------------------------

RunObjects:
	lea	objects,a0					; Object pool
	moveq	#OBJECT_COUNT-1,d7				; Number of objects

.RunLoop:
	tst.b	obj.active(a0)					; Is this slot active?
	beq.s	.NextObjRun					; If not, branch

	move.l	d7,-(sp)					; Run object
	jsr	RunObject
	move.l	(sp)+,d7

	btst	#1,obj.flags(a0)				; Should the global Y speed be applied?
	beq.s	.NextObjRun					; If not, branch
	
	moveq	#0,d0						; Apply global Y speed
	move.w	global_object_y_speed,d0
	swap	d0
	sub.l	d0,obj.y(a0)

.NextObjRun:
	lea	obj.struct_size(a0),a0				; Next object
	dbf	d7,.RunLoop					; Loop until all objects are run

	lea	objects_end-obj.struct_size,a0			; Start from the bottom of the object pool
	moveq	#OBJECT_COUNT-1,d7				; Number of objects

.DrawLoop:
	tst.b	obj.active(a0)					; Is this slot active?
	beq.s	.NextObjDraw					; If not, branch
	btst	#0,obj.flags(a0)				; Is this object set to be drawn?
	beq.s	.NextObjDraw					; If not, branch
	
	bsr.w	DrawObject					; Draw object

.NextObjDraw:
	lea	-obj.struct_size(a0),a0				; Next object
	dbf	d7,.DrawLoop					; Loop until all objects are drawn
	rts

; ------------------------------------------------------------------------------
; Run an object
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; ------------------------------------------------------------------------------

RunObject:
	moveq	#$FFFFFFFF,d0					; Run object
	move.w	obj.addr(a0),d0
	movea.l	d0,a1
	jmp	(a1)

; ------------------------------------------------------------------------------
; Spawn an object
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Pointer to object code
; RETURNS:
;	eq/ne - Object slot not found/Found
;	a1.l  - Found object slot
; ------------------------------------------------------------------------------

SpawnObject:
	moveq	#-1,d0						; Active flag
	lea	objects,a1					; Object pool
	moveq	#OBJECT_COUNT-1,d2				; Number of objects

.FindSlot:
	tst.b	obj.active(a1)					; Is this slot active?
	beq.s	.Found						; If not, branch
	lea	obj.struct_size(a1),a1				; Next object slot
	dbf	d2,.FindSlot					; Loop until all slots are checked

.NotFound:
	ori	#1,ccr						; Object slot not found
	rts

.Found:
	move.b	d0,obj.active(a1)				; Set active flag
	move.w	a2,obj.addr(a1)					; Set code address
	rts

; ------------------------------------------------------------------------------
; Clear objects
; ------------------------------------------------------------------------------

ClearObjects:
	lea	objects,a0					; Clear object data
	
	if OBJECT_COUNT<=8
		moveq	#(objects_end-objects)/4-1,d7
	else
		move.l	#(objects_end-objects)/4-1,d7
	endif

.Clear:
	clr.l	(a0)+
	dbf	d7,.Clear

	if ((objects_end-objects)&2)<>0				; Clear leftovers
		clr.w	(a0)+
	endif
	if ((objects_end-objects)&1)<>0
		clr.b	(a0)+
	endif
	rts

; ------------------------------------------------------------------------------
; Set object bookmark and exit
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; ------------------------------------------------------------------------------

BookmarkObject:
	move.l	(sp)+,d0					; Set bookmark and exit
	move.w	d0,obj.addr(a0)
	rts

; ------------------------------------------------------------------------------
; Set object bookmark and continue
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; ------------------------------------------------------------------------------

BookmarkObjectCont:
	; BUG: Overwrites object slot pointer
	move.l	(sp)+,d0					; Set bookmark
	move.w	d0,obj.addr(a0)
	movea.l	d0,a0
	jmp	(a0)						; Go back to object code

; ------------------------------------------------------------------------------
; Set object address
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
;	a1.l - Pointer to object code
; ------------------------------------------------------------------------------

SetObjectAddress:
	; BUG: Writes longword when it should've been truncated to a word
	move.l	a1,obj.addr(a0)					; Set object address
	rts

; ------------------------------------------------------------------------------
; Delete object
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; ------------------------------------------------------------------------------

DeleteObject:
	; BUG: It advances a0, but doesn't restore it, so when it exits
	; back to RunObjects, it'll skip the object after this one
	moveq	#obj.struct_size/4-1,d0				; Clear object

.Clear:
	clr.l	(a0)+
	dbf	d0,.Clear

	if (obj.struct_size&2)<>0				; Clear leftovers
		clr.w	(a0)+
	endif
	if (obj.struct_size&1)<>0
		clr.b	(a0)+
	endif
	rts

; ------------------------------------------------------------------------------
; Clear sprites
; ------------------------------------------------------------------------------

ClearSprites:
	lea	sprites,a0					; Clear sprite buffer
	moveq	#(64*8)/4-1,d0					; H32 mode only allows 64 sprites

.Clear:
	clr.l	(a0)+
	dbf	d0,.Clear

	move.b	#1,sprite_count					; Reset sprite count
	lea	sprites,a0					; Reset sprite slot
	move.l	a0,cur_sprite_slot
	rts

; ------------------------------------------------------------------------------
; Draw an object
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; ------------------------------------------------------------------------------

DrawObject:
	move.l	d7,-(sp)					; Save d7

	move.w	obj.x(a0),d4					; Get X position
	move.w	obj.y(a0),d3					; Get Y position
	addi.w	#128,d4						; Add screen origin point
	addi.w	#128,d3
	move.w	obj.sprite_tile(a0),d5				; Get base sprite tile ID
	
	movea.l	obj.sprites(a0),a3				; Get pointer to sprite frame
	moveq	#0,d0
	move.b	obj.sprite_frame(a0),d0
	add.w	d0,d0
	move.w	(a3,d0.w),d0
	lea	(a3,d0.w),a4
	
	movea.l	cur_sprite_slot,a5				; Get current sprite slot

	move.b	(a4)+,d7					; Get sprite count
	beq.s	.End						; If there are no sprites, branch
	subq.b	#1,d7						; Subtract 1 for loop

.DrawLoop:
	cmpi.b	#64,sprite_count				; Are there too many sprites?
	bcc.s	.End						; If so, branch

	move.b	(a4)+,d0					; Set sprite Y position
	ext.w	d0
	add.w	d3,d0
	move.w	d0,(a5)+

	move.b	(a4)+,(a5)+					; Set sprite size
	move.b	sprite_count,(a5)+				; Set sprite link
	addq.b	#1,sprite_count					; Increment sprite count

	move.b	(a4)+,d0					; Get sprite tile ID
	lsl.w	#8,d0
	move.b	(a4)+,d0
	add.w	d5,d0

	move.w	d0,d6						; Does this sprite point to the solid tiles?
	andi.w	#$7FF,d6
	cmpi.w	#$BC20/$20,d6
	bne.s	.SetSpriteTile					; If not, branch
	subi.w	#$2000,d0					; Decrement palette line

.SetSpriteTile:
	move.w	d0,(a5)+					; Set sprite tile ID

	move.b	(a4)+,d0					; Get sprite X position
	ext.w	d0
	add.w	d4,d0
	andi.w	#$1FF,d0
	bne.s	.SetSpriteX					; If it's not 0, branch
	addq.w	#1,d0						; Keep it away from 0

.SetSpriteX:
	move.w	d0,(a5)+					; Set sprite X position
	dbf	d7,.DrawLoop					; Loop until all sprites are drawn

.End:
	move.l	a5,cur_sprite_slot				; Update current sprite slot
	move.l	(sp)+,d7					; Restore d7
	rts

; ------------------------------------------------------------------------------
; Objects
; ------------------------------------------------------------------------------

	include	"Title Screen/Objects/Sonic/Main.asm"
	include	"Title Screen/Objects/Banner/Main.asm"
	include	"Title Screen/Objects/Planet/Main.asm"
	include	"Title Screen/Objects/Menu/Main.asm"
	include	"Title Screen/Objects/Copyright/Main.asm"

; ------------------------------------------------------------------------------
; Draw tilemaps
; ------------------------------------------------------------------------------

DrawTilemaps:
	lea	VDP_CTRL,a2					; VDP control port
	lea	VDP_DATA,a3					; VDP data port

	lea	EmblemTilemap(pc),a0				; Draw emblem
	VDP_CMD move.l,$C206,VRAM,WRITE,d0
	moveq	#$1A-1,d1
	moveq	#$13-1,d2
	bsr.s	DrawFgTilemap

	lea	WaterTilemap(pc),a0				; Draw water (left side)
	VDP_CMD move.l,$EA00,VRAM,WRITE,d0
	moveq	#$20-1,d1
	moveq	#8-1,d2
	bsr.s	DrawBgTilemap

	lea	WaterTilemap(pc),a0				; Draw water (right side)
	VDP_CMD move.l,$EA40,VRAM,WRITE,d0
	moveq	#$20-1,d1
	moveq	#8-1,d2
	bsr.s	DrawBgTilemap

	lea	MountainsTilemap(pc),a0				; Draw mountains
	VDP_CMD move.l,$E580,VRAM,WRITE,d0
	moveq	#$20-1,d1
	moveq	#9-1,d2

; ------------------------------------------------------------------------------
; Draw background tilemap
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - VDP command
;	d1.w - Width
;	d2.w - Height
;	a0.l - Pointer to tilemap
;	a2.l - VDP control port
;	a3.l - VDP data port
; ------------------------------------------------------------------------------

DrawBgTilemap:
	move.l	#$800000,d4					; Row delta

.DrawRow:
	move.l	d0,(a2)						; Set VDP command
	move.w	d1,d3						; Get width

.DrawTile:
	move.w	#$300,d6					; Get tile ID
	move.b	(a0)+,d6
	bne.s	.WriteTile					; If it's not blank, branch
	move.w	#0,d6

.WriteTile:
	move.w	d6,(a3)						; Write tile ID
	dbf	d3,.DrawTile					; Loop until row is drawn
	
	add.l	d4,d0						; Next row
	dbf	d2,.DrawRow					; Loop until map is drawn
	rts

; ------------------------------------------------------------------------------
; Draw foreground tilemap
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - VDP command
;	d1.w - Width
;	d2.w - Height
;	a0.l - Pointer to tilemap
;	a2.l - VDP control port
;	a3.l - VDP data port
; ------------------------------------------------------------------------------

DrawFgTilemap:
	move.l	#$800000,d4					; Row delta

.DrawRow:
	move.l	d0,(a2)						; Set VDP command
	move.w	d1,d3						; Get width

.DrawTile:
	move.w	(a0)+,d6					; Get tile ID
	beq.s	.WriteTile					; If it's blank, branch
	addi.w	#$C000|($6D80/$20),d6				; Add base tile ID

.WriteTile:
	addi.w	#0,d6						; Write tile ID
	move.w	d6,(a3)
	dbf	d3,.DrawTile					; Loop until row is written
	
	add.l	d4,d0						; Next row
	dbf	d2,.DrawRow					; Loop until map is drawn
	rts

; ------------------------------------------------------------------------------
; Data
; ------------------------------------------------------------------------------

WaterTilemap:
	incbin	"Title Screen/Data/Water Mappings.bin"
	even

MountainsTilemap:
	incbin	"Title Screen/Data/Moutains Mappings.bin"
	even

EmblemTilemap:
	incbin	"Title Screen/Data/Emblem Mappings.bin"
	even

WaterArt:
	incbin	"Title Screen/Data/Water Art.nem"
	even

MountainsArt:
	incbin	"Title Screen/Data/Moutains Art.nem"
	even

EmblemArt:
	incbin	"Title Screen/Data/Emblem Art.nem"
	even

BannerArt:
	incbin	"Title Screen/Objects/Banner/Data/Art.nem"
	even

PlanetArt:
	incbin	"Title Screen/Objects/Planet/Data/Art.nem"
	even

SonicArt:
	incbin	"Title Screen/Objects/Sonic/Data/Art.nem"
	even

SolidColorArt:
	incbin	"Title Screen/Data/Solid Color Art.nem"
	even

NewGameTextArt:
	incbin	"Title Screen/Objects/Menu/Data/Art (Text, New Game).nem"
	even

ContinueTextArt:
	incbin	"Title Screen/Objects/Menu/Data/Art (Text, Continue).nem"
	even

TimeAttackTextArt:
	incbin	"Title Screen/Objects/Menu/Data/Art (Text, Time Attack).nem"
	even

RamDataTextArt:
	incbin	"Title Screen/Objects/Menu/Data/Art (Text, RAM Data).nem"
	even

DaGardenTextArt:
	incbin	"Title Screen/Objects/Menu/Data/Art (Text, D.A. Garden).nem"
	even

VisualModeTextArt:
	incbin	"Title Screen/Objects/Menu/Data/Art (Text, Visual Mode).nem"
	even

PressStartTextArt:
	incbin	"Title Screen/Objects/Menu/Data/Art (Text, Press Start).nem"
	even

MenuArrowArt:
	incbin	"Title Screen/Objects/Menu/Data/Art (Arrow).nem"
	even

CopyrightArt:
	incbin	"Title Screen/Objects/Copyright/Data/Art (Copyright, JPN and EUR).nem"
	even

	if REGION=USA
TmArt:
		incbin	"Title Screen/Objects/Copyright/Data/Art (TM, USA).nem"
		even

CopyrightTmArt:
		incbin	"Title Screen/Objects/Copyright/Data/Art (Copyright, USA).nem"
		even
	else
TmArt:
		incbin	"Title Screen/Objects/Copyright/Data/Art (TM, JPN and EUR).nem"
		even
	endif

; ------------------------------------------------------------------------------

End:

; ------------------------------------------------------------------------------
