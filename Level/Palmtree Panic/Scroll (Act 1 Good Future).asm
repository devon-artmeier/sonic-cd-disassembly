; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Palmtree Panic Act 1 Good Future level scrolling/drawing
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Get level size and start position
; ------------------------------------------------------------------------------

LevelSizeLoad:
	lea	player_object,a6		; Get player slot

	moveq	#0,d0				; Clear unused variables
	move.b	d0,unused_f740
	move.b	d0,unused_f741
	move.b	d0,unused_f746
	move.b	d0,unused_f748
	move.b	d0,event_routine		; Clear level event routine

	lea	CamBounds,a0			; Prepare camera boundary information
	move.w	(a0)+,d0			; Get unused word
	move.w	d0,unused_f730
	move.l	(a0)+,d0			; Get left and right boundaries
	move.l	d0,left_bound
	move.l	d0,target_left_bound
	move.l	(a0)+,d0			; Get top and bottom boundaries
	move.l	d0,top_bound
	move.l	d0,target_top_bound
	move.w	left_bound,d0			; Get left boundary + $240
	addi.w	#$240,d0
	move.w	d0,left_bound_unknown
	move.w	#$1010,map_block_cross_fg_x	; Initialize horizontal block crossed flags
	move.w	(a0)+,d0			; Get camera Y center
	move.w	d0,camera_y_center
	move.w	#320/2,camera_x_center		; Get camera X center

	bra.w	LevelSizeLoad_StartPos

; ------------------------------------------------------------------------------
; Camera boundaries
; ------------------------------------------------------------------------------

CamBounds:
	dc.w	4, 0, $2897, 0, $310, $60

; ------------------------------------------------------------------------------
; Leftover ending demo start positions from Sonic 1
; ------------------------------------------------------------------------------

EndingStLocsS1:
	dc.w	$50, $3B0
	dc.w	$EA0, $46C
	dc.w	$1750, $BD
	dc.w	$A00, $62C
	dc.w	$BB0, $4C
	dc.w	$1570, $16C
	dc.w	$1B0, $72C
	dc.w	$1400, $2AC

; ------------------------------------------------------------------------------

LevelSizeLoad_StartPos:
	tst.b	spawn_mode			; Is the player being spawned at the beginning?
	beq.s	.DefaultStart			; If so, branch

	jsr	LoadCheckpointData		; Load checkpoint data
	moveq	#0,d0				; Get player position
	moveq	#0,d1
	move.w	obj.x(a6),d1
	move.w	obj.y(a6),d0
	bpl.s	.SkipCap			; If the Y position is positive, branch
	moveq	#0,d0				; Cap the Y position at 0 if negative

.SkipCap:
	bra.s	.SetupCamera

.DefaultStart:
	lea	LevelStartLoc,a1		; Prepare level start position
	
	tst.w	demo_mode			; Are we in the credits (Sonic 1 leftover)?
	bpl.s	.NotS1Credits			; If not, branch
	move.w	s1_credits_index,d0		; Get Sonic 1 credits starting position
	subq.w	#1,d0
	lsl.w	#2,d0
	lea	EndingStLocsS1,a1
	adda.w	d0,a1
	bra.s	.SetStartPos
	
.NotS1Credits:
	move.w	demo_mode,d0			; Get start position
	lsl.w	#2,d0
	adda.w	d0,a1
	
.SetStartPos:
	moveq	#0,d1				; Get starting X position
	move.w	(a1)+,d1
	move.w	d1,obj.x(a6)
	moveq	#0,d0				; Get starting Y position
	move.w	(a1),d0
	move.w	d0,obj.y(a6)

.SetupCamera:
	subi.w	#320/2,d1			; Get camera X position
	bcc.s	.SkipXLeftBnd			; If it doesn't need to be capped, branch
	moveq	#0,d1				; If it does, cap at 0

.SkipXLeftBnd:
	move.w	right_bound,d2			; Is the camera past the right boundary?
	cmp.w	d2,d1
	bcs.s	.SkipXRightBnd			; If not, branch
	move.w	d2,d1				; If so, cap it

.SkipXRightBnd:
	move.w	d1,camera_fg_x			; Set camera X position

	subi.w	#$60,d0				; Get camera Y position
	bcc.s	.SkipYTopBnd			; If it doesn't need to be capped, branch
	moveq	#0,d0				; If it does, cap at 0

.SkipYTopBnd:
	cmp.w	bottom_bound,d0			; Is the camera past the bottom boundary?
	blt.s	.SkipYBtmBnd			; If not, branch
	move.w	bottom_bound,d0			; If so, cap it

.SkipYBtmBnd:
	move.w	d0,camera_fg_y			; Set camera Y position

	bsr.w	InitLevelScroll			; Initialize level scrolling

	lea	SpecChunks,a1			; Get loop chunks
	move.l	(a1),special_map_chunks
	rts

; ------------------------------------------------------------------------------
; Start location
; ------------------------------------------------------------------------------

LevelStartLoc:
	incbin	"Level/Palmtree Panic/Data/Start Position (Act 1 Past).bin"

; ------------------------------------------------------------------------------
; Special chunk IDs
; ------------------------------------------------------------------------------

SpecChunks:
	dc.b	$8C, $7F, $1E, $1E

; ------------------------------------------------------------------------------
; Initialize level scrolling
; ------------------------------------------------------------------------------

InitLevelScroll:
	swap	d0				; Set background Y positions
	asr.l	#4,d0
	add.l	d0,d0
	move.l	d0,camera_bg_y
	swap	d0
	move.w	d0,camera_bg2_y
	move.w	d0,camera_bg3_y
	
	lsr.w	#2,d1				; Get background X positions
	move.w	d1,camera_bg2_x
	lsr.w	#1,d1
	move.w	d1,camera_bg3_x
	lsr.w	#1,d1
	move.w	d1,d2
	add.w	d2,d2
	add.w	d2,d1
	move.w	d1,camera_bg_x

	lea	deform_buffer,a2		; Clear cloud speeds
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	rts

; ------------------------------------------------------------------------------
; Handle level scrolling
; ------------------------------------------------------------------------------

LevelScroll:
	lea	player_object,a6		; Get player slot
	
	tst.b	scroll_lock			; Is scrolling locked?
	beq.s	.DoScroll			; If not, branch
	rts

.DoScroll:
	clr.w	scroll_flags_fg			; Clear scroll flags
	clr.w	scroll_flags_bg
	clr.w	scroll_flags_bg2
	clr.w	scroll_flags_bg3

	if REGION=USA
		bsr.w	RunLevelEvents		; Run level events
		bsr.w	ScrollCamX		; Scroll camera horizontally
		bsr.w	ScrollCamY		; Scroll camera vertically
	else
		bsr.w	ScrollCamX		; Scroll camera horizontally
		bsr.w	ScrollCamY		; Scroll camera vertically
		bsr.w	RunLevelEvents		; Run level events
	endif

	move.w	camera_fg_y,vscroll_screen	; Update VScroll values
	move.w	camera_bg_y,vscroll_screen+2

; ------------------------------------------------------------------------------

	move.w	scroll_x_diff,d4		; Set scroll offset and flags for the clouds and mountains
	ext.l	d4
	asl.l	#5,d4
	moveq	#6,d6
	bsr.w	SetHorizScrollFlagsBG3

	move.w	scroll_x_diff,d4		; Set scroll offset and flags for the waterfalls and water
	ext.l	d4
	asl.l	#6,d4
	moveq	#4,d6
	bsr.w	SetHorizScrollFlagsBG2

	lea	deform_buffer+$10,a1		; Prepare deformation buffer

	move.w	scroll_x_diff,d4		; Set scroll offset and flags for the bushes + vertical scrolling
	ext.l	d4
	asl.l	#4,d4
	move.l	d4,d3
	add.l	d3,d3
	add.l	d3,d4
	move.w	scroll_y_diff,d5
	ext.l	d5
	asl.l	#4,d5
	add.l	d5,d5
	bsr.w	SetScrollFlagsBG

	move.w	camera_bg_y,vscroll_screen+2	; Update background Y positions
	move.w	camera_bg_y,camera_bg2_y
	move.w	camera_bg_y,camera_bg3_y

	move.b	scroll_flags_bg3,d0		; Combine background scroll flags for the level drawing routine
	or.b	scroll_flags_bg2,d0
	or.b	d0,scroll_flags_bg
	clr.b	scroll_flags_bg3
	clr.b	scroll_flags_bg2

	lea	deform_buffer,a2		; Set speeds for the clouds
	addi.l	#$10000,(a2)+
	addi.l	#$C000,(a2)+
	addi.l	#$8000,(a2)+
	addi.l	#$4000,(a2)+

	move.w	camera_fg_x,d0			; Prepare scroll buffer entry
	neg.w	d0
	swap	d0

	move.w	deform_buffer,d0		; Scroll top clouds
	add.w	camera_bg3_x,d0
	neg.w	d0
	move.w	#4-1,d1
	
.ScrollClouds1:
	move.w	d0,(a1)+
	dbf	d1,.ScrollClouds1

	move.w	deform_buffer+4,d0		; Scroll top middle clouds
	add.w	camera_bg3_x,d0
	neg.w	d0
	move.w	#4-1,d1
	
.ScrollClouds2:
	move.w	d0,(a1)+
	dbf	d1,.ScrollClouds2

	move.w	deform_buffer+8,d0		; Scroll bottom middle clouds
	add.w	camera_bg3_x,d0
	neg.w	d0
	move.w	#2-1,d1
	
.ScrollClouds3:
	move.w	d0,(a1)+
	dbf	d1,.ScrollClouds3

	move.w	deform_buffer+$C,d0		; Scroll bottom clouds
	add.w	camera_bg3_x,d0
	neg.w	d0
	move.w	#2-1,d1
	
.ScrollClouds4:
	move.w	d0,(a1)+
	dbf	d1,.ScrollClouds4
	
	move.w	#6-1,d1				; Scroll mountains
	move.w	camera_bg3_x,d0
	neg.w	d0

.ScrollMountains:
	move.w	d0,(a1)+
	dbf	d1,.ScrollMountains
	
	move.w	#2-1,d1				; Scroll bushes
	move.w	camera_bg_x,d0
	neg.w	d0

.ScrollBushes:
	move.w	d0,(a1)+
	dbf	d1,.ScrollBushes
	
	move.w	#8-1,d1				; Scroll waterfalls
	move.w	camera_bg2_x,d0
	neg.w	d0

.ScrollWaterfalls:
	move.w	d0,(a1)+
	dbf	d1,.ScrollWaterfalls

	lea	hscroll,a1			; Prepare horizontal scroll buffer
	lea	deform_buffer+$10,a2		; Prepare deformation buffer

	move.w	camera_bg_y,d0			; Get background Y position
	move.w	d0,d2
	andi.w	#$1F8,d0
	lsr.w	#2,d0
	move.w	d0,d3
	lsr.w	#1,d3
	
	moveq	#(224/8)-1,d1			; Max number of blocks to scroll
	moveq	#(224/8),d5
	sub.w	d3,d1				; Get number of blocks scrolled on screen
	bcs.s	.ScrollWater			; If there are none, branch
	sub.w	d1,d5				; Get number of blocks unscrolled on screen
	lea	(a2,d0.w),a2			; Scroll blocks
	bsr.w	ScrollBlocks

.ScrollWater:
	move.w	camera_bg2_x,d0			; Get scroll delta
	move.w	camera_fg_x,d2
	sub.w	d0,d2
	ext.l	d2
	asl.l	#8,d2
	divs.w	#$100,d2
	ext.l	d2
	asl.l	#8,d2
	
	moveq	#0,d3				; Get starting scroll offset
	move.w	d0,d3
	
	move.w	d5,d1				; Get number of remaining scanlines on screen
	lsl.w	#3,d1
	subq.w	#1,d1
	
.ScrollWaterLoop:
	move.w	d3,d0				; Set scroll offset
	neg.w	d0
	move.l	d0,(a1)+
	swap	d3				; Add delta
	add.l	d2,d3
	swap	d3
	dbf	d1,.ScrollWaterLoop		; Loop until finished
	rts

; ------------------------------------------------------------------------------

ScrollBlocks:
	andi.w	#7,d2				; Get the number of lines to scroll for the first block of lines
	add.w	d2,d2
	move.w	(a2)+,d0			; Start scrolling
	jmp	ScrollBlockStart(pc,d2.w)

ScrollBlockLoop:
	move.w	(a2)+,d0			; Scroll another block of lines

ScrollBlockStart:
	rept	8				; Scroll a block of 8 lines
		move.l	d0,(a1)+
	endr
	dbf	d1,ScrollBlockLoop		; Loop until finished

.End:
	rts

; ------------------------------------------------------------------------------

ScrollBlocksAlt:
	neg.w	d0				; Start scrolling
	jmp	.ScrollBlock(pc,d2.w)

.ScrollLoop:
	neg.w	d0				; Alternate offset
	
.ScrollBlock:
	rept	8				; Scroll a block of 8 lines
		move.l	d0,(a1)+
	endr
	dbf	d1,ScrollBlockLoop		; Loop until finished

.End:
	rts

; ------------------------------------------------------------------------------
; Scroll the camera horizontally
; ------------------------------------------------------------------------------

ScrollCamX:
	move.w	camera_fg_x,d4			; Handle camera movement
	bsr.s	MoveScreenHoriz

	move.w	camera_fg_x,d0			; Check if a block has been crossed and set flags accordingly
	andi.w	#$10,d0
	move.b	map_block_cross_fg_x,d1
	eor.b	d1,d0
	bne.s	.End
	eori.b	#$10,map_block_cross_fg_x
	move.w	camera_fg_x,d0
	sub.w	d4,d0
	bpl.s	.Forward
	bset	#2,scroll_flags_fg
	rts

.Forward:
	bset	#3,scroll_flags_fg

.End:
	rts

; ------------------------------------------------------------------------------

MoveScreenHoriz:
	move.w	obj.x(a6),d0			; Get the distance scrolled
	sub.w	camera_fg_x,d0
	sub.w	camera_x_center,d0
	beq.s	.AtDest				; If not scrolled at all, branch
	bcs.s	MoveScreenHoriz_CamBehind	; If scrolled to the left, branch
	bra.s	MoveScreenHoriz_CamAhead	; If scrolled to the right, branch

.AtDest:
	clr.w	scroll_x_diff			; Didn't scroll at all
	rts

MoveScreenHoriz_CamAhead:
	cmpi.w	#16,d0				; Have we scrolled past 16 pixels?
	blt.s	.CapSpeed			; If not, branch
	move.w	#16,d0				; Cap at 16 pixels

.CapSpeed:
	add.w	camera_fg_x,d0			; Have we gone past the right boundary?
	cmp.w	right_bound,d0
	blt.s	MoveScreenHoriz_MoveCam		; If not, branch
	move.w	right_bound,d0			; Cap at the right boundary

MoveScreenHoriz_MoveCam:
	move.w	d0,d1				; Update camera position
	sub.w	camera_fg_x,d1
	asl.w	#8,d1
	move.w	d0,camera_fg_x
	move.w	d1,scroll_x_diff		; Get scroll delta
	rts

MoveScreenHoriz_CamBehind:
	cmpi.w	#-16,d0				; Have we scrolled past 16 pixels?
	bge.s	.CapSpeed			; If not, branch
	move.w	#-16,d0				; Cap at 16 pixels

.CapSpeed:
	add.w	camera_fg_x,d0			; Have we gone past the left boundary?
	cmp.w	left_bound,d0
	bgt.s	MoveScreenHoriz_MoveCam		; If not, branch
	move.w	left_bound,d0			; Cap at the left boundary
	bra.s	MoveScreenHoriz_MoveCam

; ------------------------------------------------------------------------------
; Shift the camera horizontally
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Scroll direction
; ------------------------------------------------------------------------------

ShiftCameraHoriz:
	tst.w	d0				; Are we shifting to the right?
	bpl.s	.MoveRight			; If so, branch
	move.w	#-2,d0				; Shift to the left
	bra.s	MoveScreenHoriz_CamBehind

.MoveRight:
	move.w	#2,d0				; Shift to the right
	bra.s	MoveScreenHoriz_CamAhead

; ------------------------------------------------------------------------------
; Scroll the camera vertically
; ------------------------------------------------------------------------------

ScrollCamY:
	moveq	#0,d1				; Get how far we have scrolled vertically
	move.w	obj.y(a6),d0
	sub.w	camera_fg_y,d0
	btst	#2,obj.flags(a6)		; Is the player rolling?
	beq.s	.NoRoll				; If not, branch
	subq.w	#5,d0				; Account for the different height

.NoRoll:
	btst	#1,obj.flags(a6)		; Is the player in the air?
	beq.s	.OnGround			; If not, branch

	addi.w	#$20,d0
	sub.w	camera_y_center,d0
	bcs.s	.DoScrollFast			; If the player is above the boundary, scroll to catch up
	subi.w	#$20*2,d0
	bcc.s	.DoScrollFast			; If the player is below the boundary, scroll to catch up

	tst.b	bottom_bound_shift		; Is the bottom boundary shifting?
	bne.s	.StopCam			; If it is, branch
	bra.s	.DoNotScroll

.OnGround:
	sub.w	camera_y_center,d0		; Subtract center position
	bne.s	.CamMoving			; If the player has moved, scroll to catch up
	tst.b	bottom_bound_shift		; Is the bottom boundary shifting?
	bne.s	.StopCam			; If it is, branch

.DoNotScroll:
	clr.w	scroll_y_diff			; Didn't scroll at all
	rts

; ------------------------------------------------------------------------------

.CamMoving:
	cmpi.w	#$60,camera_y_center		; Is the camera center normal?
	bne.s	.DoScrollSlow			; If not, branch
	move.w	oPlayerGVel(a6),d1		; Get the player's ground velocity
	bpl.s	.DoScrollMedium
	neg.w	d1

.DoScrollMedium:
	cmpi.w	#8<<8,d1			; Is the player moving very fast?
	bcc.s	.DoScrollFast			; If they are, branch
	move.w	#6<<8,d1			; If the player is going too fast, cap the movement to 6 pixels/frame
	cmpi.w	#6,d0				; Is the player going down too fast?
	bgt.s	.MovingDown			; If so, move the camera at the capped speed
	cmpi.w	#-6,d0				; Is the player going up too fast?
	blt.s	.MovingUp			; If so, move the camera at the capped speed
	bra.s	.GotCamSpeed			; Otherwise, move the camera at the player's speed

.DoScrollSlow:
	move.w	#2<<8,d1			; If the player is going too fast, cap the movement to 2 pixels/frame
	cmpi.w	#2,d0				; Is the player going down too fast?
	bgt.s	.MovingDown			; If so, move the camera at the capped speed
	cmpi.w	#-2,d0				; Is the player going up too fast?
	blt.s	.MovingUp			; If so, move the camera at the capped speed
	bra.s	.GotCamSpeed			; Otherwise, move the camera at the player's speed

.DoScrollFast:
	move.w	#16<<8,d1			; If the player is going too fast, cap the movement to 16 pixels/frame
	cmpi.w	#16,d0				; Is the player going down too fast?
	bgt.s	.MovingDown			; If so, move the camera at the capped speed
	cmpi.w	#-16,d0				; Is the player going up too fast?
	blt.s	.MovingUp			; If so, move the camera at the capped speed
	bra.s	.GotCamSpeed			; Otherwise, move the camera at the player's speed

; ------------------------------------------------------------------------------

.StopCam:
	moveq	#0,d0				; Stop the camera
	move.b	d0,bottom_bound_shift		; Clear bottom boundary shifting flag

.GotCamSpeed:
	moveq	#0,d1
	move.w	d0,d1				; Get position difference
	add.w	camera_fg_y,d1			; Add old camera Y position
	tst.w	d0				; Is the camera scrolling down?
	bpl.w	.ChkBottom			; If so, branch
	bra.w	.ChkTop

.MovingUp:
	neg.w	d1				; Make the value negative
	ext.l	d1
	asl.l	#8,d1				; Move this into the upper word to align with the camera's Y position variable
	add.l	camera_fg_y,d1			; Shift the camera over
	swap	d1				; Get the proper Y position

.ChkTop:
	cmp.w	top_bound,d1			; Is the new position past the top boundary?
	bgt.s	.MoveCam			; If not, branch
	cmpi.w	#-$100,d1			; Is Y wrapping enabled?
	bgt.s	.CapTop				; If not, branch
	andi.w	#$7FF,d1			; Apply wrapping
	andi.w	#$7FF,obj.y(a6)
	andi.w	#$7FF,camera_fg_y
	andi.w	#$3FF,camera_bg_y
	bra.s	.MoveCam

; ------------------------------------------------------------------------------

.CapTop:
	move.w	top_bound,d1			; Cap at the top boundary
	bra.s	.MoveCam

.MovingDown:
	ext.l	d1
	asl.l	#8,d1				; Move this into the upper word to align with the camera's Y position variable
	add.l	camera_fg_y,d1			; Shift the camera over
	swap	d1				; Get the proper Y position

.ChkBottom:
	cmp.w	bottom_bound,d1		; Is the new position past the bottom boundary?
	blt.s	.MoveCam			; If not, branch
	subi.w	#$800,d1			; Should we wrap?
	bcs.s	.CapBottom			; If not, branch
	andi.w	#$7FF,obj.y(a6)			; Apply wrapping
	subi.w	#$800,camera_fg_y
	andi.w	#$3FF,camera_bg_y
	bra.s	.MoveCam

; ------------------------------------------------------------------------------

.CapBottom:
	move.w	bottom_bound,d1		; Cap at the bottom boundary

.MoveCam:
	move.w	camera_fg_y,d4			; Update the camera position and get the scroll delta
	swap	d1
	move.l	d1,d3
	sub.l	camera_fg_y,d3
	ror.l	#8,d3
	move.w	d3,scroll_y_diff
	move.l	d1,camera_fg_y

	move.w	camera_fg_y,d0			; Check if a block has been crossed and set flags accordingly
	andi.w	#$10,d0
	move.b	map_block_cross_fg_y,d1
	eor.b	d1,d0
	bne.s	.End
	eori.b	#$10,map_block_cross_fg_y
	move.w	camera_fg_y,d0
	sub.w	d4,d0
	bpl.s	.Downward
	bset	#0,scroll_flags_fg
	rts

.Downward:
	bset	#1,scroll_flags_fg

.End:
	rts

; ------------------------------------------------------------------------------

	include	"Level/Scroll Flag Set.asm"

; ------------------------------------------------------------------------------
; Update level background drawing
; ------------------------------------------------------------------------------

DrawLevelBG:
	lea	VDPCTRL,a5			; Prepare VDP ports
	lea	VDPDATA,a6

	lea	scroll_flags_bg,a2		; Update background section 1
	lea	camera_bg_x,a3
	lea	map_layout+$40,a4
	move.w	#$6000,d2
	bsr.w	DrawLevelBG1

	lea	scroll_flags_bg2,a2		; Update background section 2
	lea	camera_bg2_x,a3
	bra.w	DrawLevelBG2

; ------------------------------------------------------------------------------
; Update level drawing
; ------------------------------------------------------------------------------

DrawLevel:
	lea	VDPCTRL,a5			; Prepare VDP ports
	lea	VDPDATA,a6

	lea	scroll_flags_bg_copy,a2		; Update background
	lea	camera_bg_x_copy,a3
	lea	map_layout+$40,a4
	move.w	#$6000,d2
	bsr.w	DrawLevelBG1

	lea	scroll_flags_bg2_copy,a2	; Update background 2
	lea	camera_bg2_x_copy,a3
	bsr.w	DrawLevelBG2

	lea	scroll_flags_bg3_copy,a2	; Update background 3
	lea	camera_bg3_x_copy,a3
	bsr.w	DrawLevelBG3

	lea	scroll_flags_fg_copy,a2		; Update foreground
	lea	camera_fg_x_copy,a3
	lea	map_layout,a4
	move.w	#$4000,d2

; ------------------------------------------------------------------------------
; Draw foreground
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a2.l - Scroll flags pointer
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; ------------------------------------------------------------------------------

DrawLevelFG:
	tst.b	(a2)				; Are any scroll flags set?
	beq.s	.End				; If not, branch

	bclr	#0,(a2)				; Should we draw a row at the top?
	beq.s	.ChkBottomRow			; If not, branch
	moveq	#-16,d4				; Draw a row at (-16, -16)
	moveq	#-16,d5
	bsr.w	GetBlockVDPCmd
	moveq	#-16,d4
	moveq	#-16,d5
	bsr.w	DrawBlockRow

.ChkBottomRow:
	bclr	#1,(a2)				; Should we draw a row at the bottom?
	beq.s	.ChkLeftCol			; If not, branch
	move.w	#224,d4				; Draw a row at (-16, 224)
	moveq	#-16,d5
	bsr.w	GetBlockVDPCmd
	move.w	#224,d4
	moveq	#-16,d5
	bsr.w	DrawBlockRow

.ChkLeftCol:
	bclr	#2,(a2)				; Should we draw a column on the left?
	beq.s	.ChkRightCol			; If not, branch
	moveq	#-16,d4				; Draw a column at (-16, -16)
	moveq	#-16,d5
	bsr.w	GetBlockVDPCmd
	moveq	#-16,d4
	moveq	#-16,d5
	bsr.w	DrawBlockCol

.ChkRightCol:
	bclr	#3,(a2)				; Should we draw a column on the right?
	beq.s	.End				; If not, branch
	moveq	#-16,d4				; Draw a column at (320, -16)
	move.w	#320,d5
	bsr.w	GetBlockVDPCmd
	moveq	#-16,d4
	move.w	#320,d5
	bsr.w	DrawBlockCol

.End:
	rts
	
; ------------------------------------------------------------------------------
; Draw background section #1
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a2.l - Scroll flags pointer
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; ------------------------------------------------------------------------------

DrawLevelBG1:
	lea	BGCameraSectIDs,a0		; Prepare background section camera IDs
	adda.w	#1,a0

	moveq	#-$10,d4			; Prepare to draw a row at the top

	bclr	#0,(a2)				; Should we draw a row at the top?
	bne.s	.GotRowPos			; If so, branch
	bclr	#1,(a2)				; Should we draw a row at the bottom?
	beq.s	.ChkHorizScroll			; If not, branch

	move.w	#224,d4				; Prepare to draw a row at the bottom

.GotRowPos:
	move.w	camera_bg_y,d0			; Get which camera the current block section is using
	add.w	d4,d0
	andi.w	#$FFF0,d0
	asr.w	#4,d0
	move.b	(a0,d0.w),d0
	ext.w	d0
	add.w	d0,d0
	movea.l	.CameraSects(pc,d0.w),a3
	beq.s	.StaticRow			; If it's a statically drawn row of blocks, branch

	moveq	#-$10,d5			; Draw a row of blocks
	move.l	a0,-(sp)
	movem.l	d4-d5,-(sp)
	bsr.w	GetBlockVDPCmd
	movem.l	(sp)+,d4-d5
	bsr.w	DrawBlockRow
	movea.l	(sp)+,a0

	bra.s	.ChkHorizScroll

.StaticRow:
	moveq	#0,d5				; Draw a full statically drawn row of blocks
	move.l	a0,-(sp)
	movem.l	d4-d5,-(sp)
	bsr.w	GetBlockVDPCmdAbsX
	movem.l	(sp)+,d4-d5
	moveq	#(512/16)-1,d6
	bsr.w	DrawBlockRowAbsX
	movea.l	(sp)+,a0

.ChkHorizScroll:
	tst.b	(a2)				; Did the screen background horizontally at all?
	bne.s	.DidScrollHoriz			; If so, branch
	rts

.DidScrollHoriz:
	moveq	#-$10,d4			; Prepare to draw a column on the left
	moveq	#-$10,d5
	move.b	(a2),d0				; Should we draw a column on the right?
	andi.b	#%10101000,d0
	beq.s	.GotScrollDir			; If not, branch
	lsr.b	#1,d0				; Shift scroll flags to fit camera ID array later on
	move.b	d0,(a2)
	move.w	#320,d5				; Prepare to draw a column on the right

.GotScrollDir:
	move.w	camera_bg_y,d0			; Prepare background section camera ID array
	andi.w	#$FFF0,d0
	asr.w	#4,d0
	suba.w	#1,a0
	lea	(a0,d0.w),a0

	bra.w	.DrawColumn

; ------------------------------------------------------------------------------

.CameraSects:
	dc.l	camera_bg_x_copy		; BG1 (static)
	dc.l	camera_bg_x_copy		; BG1 (dynamic)
	dc.l	camera_bg2_x_copy		; BG2 (dynamic)
	dc.l	camera_bg3_x_copy		; BG3 (dynamic)

; ------------------------------------------------------------------------------

.DrawColumn:
	moveq	#((224+(16*2))/16)-1,d6		; 16 blocks in a column
	move.l	#$800000,d7			; VDP command row delta

.Loop:
	moveq	#0,d0				; Get camera ID for this block section
	move.b	(a0)+,d0
	btst	d0,(a2)				; Has this block section scrolled enough to warrant a new block to be drawn?
	beq.s	.NextBlock			; If not, branch

	add.w	d0,d0				; Draw a block
	movea.l	.CameraSects(pc,d0.w),a3
	movem.l	d4-d5/a0,-(sp)
	movem.l	d4-d5,-(sp)
	bsr.w	GetBlockData
	movem.l	(sp)+,d4-d5
	bsr.w	GetBlockVDPCmd
	bsr.w	DrawBlock
	movem.l	(sp)+,d4-d5/a0

.NextBlock:
	addi.w	#16,d4				; Shift down
	dbf	d6,.Loop			; Loop until finished

	clr.b	(a2)				; Clear scroll flags
	rts

; ------------------------------------------------------------------------------
; Draw background section #2 (unused)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a2.l - Scroll flags pointer
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; ------------------------------------------------------------------------------

DrawLevelBG2:
	rts

; ------------------------------------------------------------------------------
; Draw background section #3 (unused)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a2.l - Scroll flags pointer
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; ------------------------------------------------------------------------------

DrawLevelBG3:
	rts

; ------------------------------------------------------------------------------

	include	"Level/Block Draw.asm"

; ------------------------------------------------------------------------------
; Start level drawing
; ------------------------------------------------------------------------------

InitLevelDraw:
	lea	VDPCTRL,a5			; Prepare VDP ports
	lea	VDPDATA,a6

	lea	camera_fg_x,a3			; Initialize foreground
	lea	map_layout,a4
	move.w	#$4000,d2
	bsr.s	InitLevelDrawFG

	lea	camera_bg_x,a3			; Initialize background
	lea	map_layout+$40,a4
	move.w	#$6000,d2
	bra.w	InitLevelDrawBG

; ------------------------------------------------------------------------------
; Draw foreground
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; ------------------------------------------------------------------------------

InitLevelDrawFG:
	moveq	#-16,d4				; Start drawing at the top of the screen
	moveq	#((224+(16*2))/16)-1,d6		; 16 blocks in a column

.Draw:
	movem.l	d4-d6,-(sp)			; Draw a full row of blocks
	moveq	#0,d5
	move.w	d4,d1
	bsr.w	GetBlockVDPCmd
	move.w	d1,d4
	moveq	#0,d5
	moveq	#(512/16)-1,d6
	bsr.w	DrawBlockRow2
	movem.l	(sp)+,d4-d6

	addi.w	#16,d4				; Move down
	dbf	d6,.Draw			; Loop until finished

	rts

; ------------------------------------------------------------------------------
; Draw background
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; ------------------------------------------------------------------------------

InitLevelDrawBG:
	moveq	#-16,d4				; Start drawing at the top of the screen
	moveq	#((224+(16*2))/16)-1,d6		; 16 blocks in a column

.Draw:
	movem.l	d4-d6/a0,-(sp)			; Draw a row of blocks
	lea	BGCameraSectIDs,a0
	adda.w	#1,a0
	move.w	camera_bg_y,d0
	add.w	d4,d0
	andi.w	#$1F0,d0
	bsr.w	DrawBGBlockRow
	movem.l	(sp)+,d4-d6/a0

	addi.w	#16,d4				; Move down
	dbf	d6,.Draw			; Loop until finished

	rts

; ------------------------------------------------------------------------------
; Background camera sections
; ------------------------------------------------------------------------------
; Each row of blocks is assigned a background camera section to help
; determine how to draw it
; ------------------------------------------------------------------------------
; 0 = Background 1 (Static)
; 2 = Background 1 (Dynamic)
; 4 = Background 2 (Dynamic)
; 6 = Background 3 (Dynamic)
; ------------------------------------------------------------------------------

BGCameraSectIDs:
	BGSECT	16,  BGSTATIC			; Offscreen top row, required to be here
	BGSECT	96,  BGSTATIC			; Clouds
	BGSECT	48,  BGDYNAMIC3			; Mountains
	BGSECT	16,  BGDYNAMIC1			; Bushes
	BGSECT	64,  BGDYNAMIC2			; Waterfalls
	BGSECT	304, BGSTATIC			; Water

; ------------------------------------------------------------------------------

BGCameraSects:
	dc.l	camera_bg_x&$FFFFFF		; BG1 (static)
	dc.l	camera_bg_x&$FFFFFF		; BG1 (dynamic)
	dc.l	camera_bg2_x&$FFFFFF		; BG2 (dynamic)
	dc.l	camera_bg3_x&$FFFFFF		; BG3 (dynamic)

; ------------------------------------------------------------------------------
; Draw row of blocks for the background
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a0.l - Background camera sections
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; ------------------------------------------------------------------------------

DrawBGBlockRow:
	lsr.w	#4,d0				; Get camera section ID
	move.b	(a0,d0.w),d0
	add.w	d0,d0
	movea.l	BGCameraSects(pc,d0.w),a3
	beq.s	.StaticRow			; If it's a statically drawn row of blocks, branch

	moveq	#-16,d5				; Draw a row of blocks
	movem.l	d4-d5,-(sp)
	bsr.w	GetBlockVDPCmd
	movem.l	(sp)+,d4-d5
	bsr.w	DrawBlockRow
	bra.s	.End

.StaticRow:
	moveq	#0,d5				; Draw a full statically drawn row of blocks
	movem.l	d4-d5,-(sp)
	bsr.w	GetBlockVDPCmdAbsX
	movem.l	(sp)+,d4-d5
	moveq	#(512/16)-1,d6
	bsr.w	DrawBlockRowAbsX

.End:
	rts

; ------------------------------------------------------------------------------
