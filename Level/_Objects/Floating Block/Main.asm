; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Floating block object
; ------------------------------------------------------------------------------

ObjFloatBlock:
	moveq	#0,d0				; Run routine
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	move.w	obj.x(a0),d0			; Get the object's chunk position
	andi.w	#$FF80,d0
	move.w	camera_fg_x,d1			; Get the camera's chunk position
	subi.w	#$80,d1
	andi.w	#$FF80,d1
	
	sub.w	d1,d0				; Has the object gone offscreen?
	cmpi.w	#$80+(320+$40)+$80,d0
	bhi.w	DeleteObject			; If so, despawn
	rts

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjFloatBlock_Init-.Index
	dc.w	ObjFloatBlock_Main-.Index
	dc.w	ObjFloatBlock_Fall-.Index
	dc.w	ObjFloatBlock_Appear-.Index
	dc.w	ObjFloatBlock_Visible-.Index
	dc.w	ObjFloatBlock_Vanish-.Index
	dc.w	ObjFloatBlock_Reset-.Index

; ------------------------------------------------------------------------------
; Initialization
; ------------------------------------------------------------------------------

ObjFloatBlock_Init:
	addq.b	#2,obj.routine(a0)			; Next routine
	ori.b	#%00000100,obj.sprite_flags(a0)	; Set sprite flags
	move.l	#MapSpr_FloatBlock,obj.sprites(a0)	; Set mappings
	moveq	#5,d0				; Set base tile ID
	jsr	SetObjectTileID
	move.b	#1,obj.sprite_layer(a0)		; Set priority
	move.b	#$C,obj.width(a0)			; Set width
	move.b	#$C,obj.collide_height(a0)		; Set height
	move.b	#5,obj.sprite_frame(a0)		; Set sprite frame

; ------------------------------------------------------------------------------
; Main routine
; ------------------------------------------------------------------------------

ObjFloatBlock_Main:
	bsr.w	ObjFloatBlock_TopSolid		; Handle solidity
	
	tst.b	time_zone			; Are we in the past?
	beq.s	.Draw				; If so, branch
	cmpi.b	#TIME_FUTURE,time_zone		; Are we in the future?
	bne.s	.Appear				; If not, branch
	
.Fall:
	btst	#3,obj.flags(a0)			; Are we being stood on?
	bne.s	.StartFall			; If so, branch
	bra.s	.Draw

.Appear:
	move.b	#0,obj.sprite_frame(a0)		; Set invisible sprite frame
	btst	#3,obj.flags(a0)			; Are we being stood on?
	beq.s	.Draw				; If not, branch
	move.b	#6,obj.routine(a0)			; Start appearing
	move.b	#1,obj.anim_id(a0)

.Draw:
	jmp	DrawObject			; Draw sprite

.StartFall:
	addq.b	#2,obj.routine(a0)			; Start falling

; ------------------------------------------------------------------------------
; Falling
; ------------------------------------------------------------------------------

ObjFloatBlock_Fall:
	bsr.w	ObjFloatBlock_TopSolid		; Handle solidity
	
	addq.w	#2,obj.y(a0)			; Move down
	move.w	camera_fg_y,d0			; Are we offscreen?
	addi.w	#$E0,d0
	cmp.w	obj.y(a0),d0
	bcc.s	.Draw				; If not, branch
	jmp	DeleteObject			; If so, despawn

.Draw:
	jmp	DrawObject			; Draw sprite

; ------------------------------------------------------------------------------
; Appearing
; ------------------------------------------------------------------------------

ObjFloatBlock_Appear:
	bsr.w	ObjFloatBlock_TopSolid		; Handle solidity
	
	btst	#3,obj.flags(a0)			; Are we being stood on?
	bne.s	.Animate			; If so, branch
	move.b	#2,obj.routine(a0)			; If not, disappear
	rts

.Animate:
	lea	Ani_FloatBlock,a1		; Animate sprite
	bsr.w	AnimateObject
	jmp	DrawObject			; Draw sprite

; ------------------------------------------------------------------------------
; Fully visible
; ------------------------------------------------------------------------------

ObjFloatBlock_Visible:
	move.b	#0,obj.anim_id(a0)
	bsr.w	ObjFloatBlock_TopSolid		; Handle solidity
	
	btst	#3,obj.flags(a0)			; Are we being stood on?
	bne.s	.Animate			; If so, branch
	addq.b	#2,obj.routine(a0)			; If not, disappear
	move.b	#2,obj.anim_id(a0)
	rts

.Animate:
	lea	Ani_FloatBlock,a1		; Animate sprite
	bsr.w	AnimateObject
	jmp	DrawObject			; Draw sprite

; ------------------------------------------------------------------------------
; Vanishing
; ------------------------------------------------------------------------------

ObjFloatBlock_Vanish:
	bsr.w	ObjFloatBlock_TopSolid		; Handle solidity
	
	lea	Ani_FloatBlock,a1		; Animate sprite
	bsr.w	AnimateObject
	jmp	DrawObject

; ------------------------------------------------------------------------------
; Reset
; ------------------------------------------------------------------------------

ObjFloatBlock_Reset:
	move.b	#2,obj.routine(a0)			; Reset
	rts

; ------------------------------------------------------------------------------
; Handle solidity
; ------------------------------------------------------------------------------

ObjFloatBlock_TopSolid:
	lea	player_object,a1		; Check collision with player
	bsr.w	.Check
	; Originally checked for player 2 here
	;lea	player_2_object,a1

.Check:
	move.w	obj.x(a0),d3			; Handle solidity
	move.w	obj.y(a0),d4
	jmp	TopSolidObject

; ------------------------------------------------------------------------------
; Data
; ------------------------------------------------------------------------------

Ani_FloatBlock:
	include	"Level/_Objects/Floating Block/Data/Animations.asm"
	even
MapSpr_FloatBlock:
	include	"Level/_Objects/Floating Block/Data/Mappings.asm"
	even
	
; ------------------------------------------------------------------------------
