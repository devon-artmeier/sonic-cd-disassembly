; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Springboard object
; ------------------------------------------------------------------------------

oSprBrdFling	EQU	obj.var_2A		; Timer

; ------------------------------------------------------------------------------
; Check player collision
; ------------------------------------------------------------------------------

ObjSpringBoard_ChkPlayer:
	tst.b	debug_mode			; Are we in debug mode?
	bne.s	.NoCollision			; If so, branch
	cmpi.b	#6,obj.routine(a1)		; Is the player dead?
	bcc.s	.NoCollision			; If so, branch
	tst.w	obj.y_speed(a1)			; Is the player moving upwards?
	bmi.s	.NoCollision			; If so, branch
	bra.s	.ChkTouch			; Check collision

.NoCollision:
	bclr	#3,obj.flags(a0)		; Clear stood on flag
	moveq	#0,d1				; No collision
	rts

.ChkTouch:
	lea	.Hitboxes,a2			; Get collision hitbox size
	andi.w	#7,d0
	asl.w	#2,d0
	lea	(a2,d0.w),a2
	
	move.w	obj.x(a0),d0			; Get X position
	move.w	obj.x(a1),d1			; Get player's X position
	move.b	obj.collide_width(a1),d3	; Get player's collision width
	ext.w	d3
	
	move.b	0(a2),d2			; Get hitbox's right X point
	ext.w	d2
	move.w	d0,d4				; Get points to compare
	move.w	d1,d5
	add.w	d2,d4				; X + Hitbox's right X point
	sub.w	d3,d5				; Player X - Player's collision width
	cmp.w	d4,d5				; Is the player right of the hitbox?
	bpl.s	.NoCollision2			; If so, branch
	
	move.b	1(a2),d2			; Get hitbox's left X point
	ext.w	d2
	neg.w	d2
	move.w	d0,d4				; Get points to compare
	move.w	d1,d5
	sub.w	d2,d4				; X + Hitbox's left X point
	add.w	d3,d5				; Player X + Player's collision width
	cmp.w	d5,d4				; Is the player left of the hitbox?
	bpl.s	.NoCollision2			; If so, branch
	
	move.w	obj.y(a0),d0			; Get Y position
	move.w	obj.y(a1),d1			; Get player's Y position
	move.b	obj.collide_height(a1),d3	; Get player's collision height
	ext.w	d3
	
	move.b	2(a2),d2			; Get hitbox's bottom X point
	ext.w	d2
	move.w	d0,d4				; Get points to compare
	move.w	d1,d5
	add.w	d2,d4				; Y + Hitbox's right Y point
	sub.w	d3,d5				; Player Y - Player's collision height
	cmp.w	d4,d5				; Is the player below the hitbox?
	bpl.s	.NoCollision2			; If so, branch
	
	move.b	3(a2),d2			; Get hitbox's top X point
	ext.w	d2
	neg.w	d2
	move.w	d0,d4				; Get points to compare
	move.w	d1,d5
	sub.w	d2,d4				; Y + Hitbox's left Y point
	add.w	d3,d5				; Player Y + Player's collision height
	cmp.w	d5,d4				; Is the player above the hitbox?
	bpl.s	.NoCollision2			; If so, branch

.Collided:
	bset	#3,obj.flags(a0)		; Set stood on flag
	moveq	#-1,d1				; Collision
	rts

.NoCollision2:
	bclr	#3,obj.flags(a0)		; Clear stood on flag
	moveq	#0,d1				; No collision
	rts

; ------------------------------------------------------------------------------

.Hitboxes:
	dc.b	16, -16, 16, -16
	dc.b	16, -16,  4,  -4
	dc.b	 9,  -9, 56,  16
	dc.b	 0, -24,  4,  -4		; Idle (flipped)
	dc.b	 0, -24, 12,   0		; Flinging (flipped)
	dc.b	24,   0,  4,  -4		; Idle (normal)
	dc.b	24,   0, 12,   0		; Flinging (normal)
	dc.b	32, -32, 32, -32
	
; ------------------------------------------------------------------------------
; Springboard object
; ------------------------------------------------------------------------------

ObjSpringBoard:
	moveq	#0,d0				; Run routine
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	jmp	CheckObjDespawn			; Check despawn

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjSpringBoard_Init-.Index
	dc.w	ObjSpringBoard_NormalMain-.Index
	dc.w	ObjSpringBoard_FlipMain-.Index
	dc.w	ObjSpringBoard_NormalMain2-.Index
	dc.w	ObjSpringBoard_FlipMain2-.Index
	dc.w	ObjSpringBoard_NormalFling-.Index
	dc.w	ObjSpringBoard_FlipFling-.Index

; ------------------------------------------------------------------------------

ObjSpringBoard_Init:
	move.l	#MapSpr_SpringBoard,obj.sprites(a0)	; Set mappings
	ori.b	#4,obj.sprite_flags(a0)		; Set sprite flags
	move.b	#3,obj.sprite_layer(a0)		; Set priority
	move.b	#$10,obj.width(a0)		; Set width
	move.b	#$18,obj.collide_width(a0)
	move.b	#4,obj.collide_height(a0)	; Set height
	moveq	#7,d0				; Set base tile ID
	jsr	SetObjectTileID(pc)
	
	move.b	#3,d0				; Normal animation
	move.b	#2,d1				; Normal routine
	tst.b	obj.subtype(a0)			; Are we flipped?
	bne.s	.Flip				; If so, branch
	btst	#0,obj.sprite_flags(a0)		; Is our sprite flipped?
	beq.s	.SetRoutine			; If not, branch

.Flip:
	move.b	#4,d0				; Flipped animation
	move.b	#4,d1				; Flipped routine
	bclr	#0,obj.sprite_flags(a0)		; Clear horizontal flip flags
	bclr	#0,obj.flags(a0)

.SetRoutine:
	move.b	d0,obj.anim_id(a0)		; Set animation
	move.b	d1,obj.routine(a0)		; Set routine
	rts

; ------------------------------------------------------------------------------

ObjSpringBoard_Draw:
	lea	Ani_SpringBoard(pc),a1		; Animate sprite
	jsr	AnimateObject
	jmp	DrawObject			; Draw sprite

; ------------------------------------------------------------------------------

ObjSpringBoard_FlipMain:
	lea	player_object,a1		; Check player collision
	moveq	#3,d0
	bsr.w	ObjSpringBoard_ChkPlayer
	tst.b	d1
	beq.s	.Draw				; If there was no collision, branch
	
	move.l	obj.y(a0),d0			; Align player on top of us
	moveq	#0,d1
	move.b	obj.collide_height(a1),d1
	swap	d1
	sub.l	d1,d0
	move.l	d0,obj.y(a1)
	
	move.b	#$C,obj.routine(a0)		; Fling and bounce the player
	move.b	#4,obj.anim_id(a0)		; Reset animation

.Draw:
	bra.w	ObjSpringBoard_Draw		; Draw and animate sprite

; ------------------------------------------------------------------------------

ObjSpringBoard_FlipMain2:
	lea	player_object,a1		; Check player collision
	moveq	#3,d0
	bsr.w	ObjSpringBoard_ChkPlayer
	tst.b	d1
	bne.w	.Draw				; If there was a collision, branch
	
	move.b	#4,obj.routine(a0)		; Set to main routine
	btst	#1,obj.flags(a1)		; Is the player in the air?
	beq.s	.CheckFling			; If not, branch
	move.b	#$C,obj.routine(a0)		; Set to flinging routine

.CheckFling:
	cmpi.b	#$C,obj.routine(a0)		; Are we flinging?
	beq.s	.SetFlingTimer			; If so, branch
	bra.s	.Draw				; If not, branch

.SetFlingTimer:
	move.b	#$40,oSprBrdFling(a0)		; Set fling timer

.Draw:
	bra.w	ObjSpringBoard_Draw		; Draw and animate sprite

; ------------------------------------------------------------------------------

ObjSpringBoard_FlipFling:
	move.b	#2,obj.anim_id(a0)		; Set flinging animation
	nop
	nop
	nop
	nop
	
	lea	player_object,a1		; Check player collision
	moveq	#4,d0
	bsr.w	ObjSpringBoard_ChkPlayer
	tst.b	d1
	beq.s	.Animate			; If there was no collision, branch
	
	move.w	obj.y_speed(a1),d0		; Get the speed the player hit us at
	addi.w	#$100,d0			; Increment it
	cmpi.w	#$A00,d0			; Is it too big now?
	bmi.s	.SetYVel			; If not, branch
	move.w	#$A00,d0			; If so, cap it

.SetYVel:
	neg.w	d0				; Bounce the player up
	move.w	d0,obj.y_speed(a1)
	
	move.b	#$40,oSprBrdFling(a0)		; Set timer
	bset	#1,obj.flags(a1)		; Set player in air flag
	beq.s	.SetupPlayer			; If the player was not already in the air, branch
	clr.b	oPlayerJump(a1)			; Clear player jump flag

.SetupPlayer:
	bclr	#5,obj.flags(a1)		; Clear player push flag
	clr.b	oPlayerStick(a1)		; Clear player collision stick flag
	
	move.b	#$13,obj.collide_height(a1)	; Set normal hitbox for player
	move.b	#9,obj.collide_width(a1)
	btst	#2,obj.flags(a1)		; Was the player rolling?
	bne.s	.RollJump			; If so, branch
	move.b	#$E,obj.collide_height(a1)	; Set rolling hitbox for player
	move.b	#7,obj.collide_width(a1)
	addq.w	#5,obj.y(a1)			; Shift player down to account for hitbox change
	bset	#2,obj.flags(a1)		; Set player roll flag
	move.b	#2,obj.anim_id(a1)		; Set player rolling animation
	bra.s	.Animate

.RollJump:
	bset	#4,obj.flags(a1)		; Set roll jump flag

.Animate:
	move.b	oSprBrdFling(a0),d0		; Decrement fling timer
	subq.b	#1,d0
	move.b	d0,oSprBrdFling(a0)
	bne.s	.Draw				; If it hasn't run out, branch
	
	move.b	#$40,oSprBrdFling(a0)		; Reset fling timer
	move.b	#4,obj.routine(a0)		; Set to main routine
	move.b	#4,obj.anim_id(a0)		; Reset animation

.Draw:
	bra.w	ObjSpringBoard_Draw		; Draw and animate sprite

; ------------------------------------------------------------------------------

ObjSpringBoard_NormalMain:
	lea	player_object,a1		; Check player collision
	moveq	#5,d0
	bsr.w	ObjSpringBoard_ChkPlayer
	tst.b	d1
	beq.s	.Draw				; If there was no collision, branch
	
	move.l	obj.y(a0),d0			; Align player on top of us
	moveq	#0,d1
	move.b	obj.collide_height(a1),d1
	swap	d1
	sub.l	d1,d0
	move.l	d0,obj.y(a1)
	
	move.b	#$A,obj.routine(a0)		; Fling and bounce the player
	move.b	#3,obj.anim_id(a0)		; Reset animation

.Draw:
	bra.w	ObjSpringBoard_Draw		; Draw and animate sprite

; ------------------------------------------------------------------------------

ObjSpringBoard_NormalMain2:
	lea	player_object,a1		; Check player collision
	moveq	#5,d0
	bsr.w	ObjSpringBoard_ChkPlayer
	tst.b	d1
	bne.w	.Draw				; If there was a collision, branch
	
	move.b	#2,obj.routine(a0)		; Set to main routine
	btst	#1,obj.flags(a1)		; Is the player in the air?
	beq.s	.CheckFling			; If not, branch
	move.b	#$A,obj.routine(a0)		; Set to flinging routine

.CheckFling:
	cmpi.b	#$A,obj.routine(a0)		; Are we flinging?
	beq.s	.SetFlingTimer			; If so, branch
	bra.s	.Draw				; If not, branch

.SetFlingTimer:
	move.b	#$40,oSprBrdFling(a0)		; Set fling timer

.Draw:
	bra.w	ObjSpringBoard_Draw		; Draw and animate sprite

; ------------------------------------------------------------------------------

ObjSpringBoard_NormalFling:
	move.b	#1,obj.anim_id(a0)		; Set bounce animation
	
	lea	player_object,a1		; Check player collision
	moveq	#6,d0
	bsr.w	ObjSpringBoard_ChkPlayer
	tst.b	d1
	beq.s	.Animate			; If there was no collision, branch
	
	move.w	obj.y_speed(a1),d0		; Get the speed the player hit us at
	addi.w	#$100,d0			; Increment it
	cmpi.w	#$A00,d0			; Is it too big now?
	bmi.s	.SetYVel			; If not, branch
	move.w	#$A00,d0			; If so, cap it

.SetYVel:
	neg.w	d0				; Bounce the player up
	move.w	d0,obj.y_speed(a1)
	
	move.b	#$40,oSprBrdFling(a0)
	bset	#1,obj.flags(a1)
	beq.s	.SetupPlayer			; If the player was not already in the air, branch
	clr.b	oPlayerJump(a1)

.SetupPlayer:
	bclr	#5,obj.flags(a1)		; Clear player push flag
	clr.b	oPlayerStick(a1)		; Clear player collision stick flag
	
	move.b	#$13,obj.collide_height(a1)	; Set normal hitbox for player
	move.b	#9,obj.collide_width(a1)
	btst	#2,obj.flags(a1)		; Was the player rolling?
	bne.s	.RollJump			; If so, branch
	move.b	#$E,obj.collide_height(a1)	; Set rolling hitbox for player
	move.b	#7,obj.collide_width(a1)
	addq.w	#5,obj.y(a1)			; Shift player down to account for hitbox change
	bset	#2,obj.flags(a1)		; Set player roll flag
	move.b	#2,obj.anim_id(a1)		; Set player rolling animation
	bra.s	.Animate

.RollJump:
	bset	#4,obj.flags(a1)		; Set roll jump flag

.Animate:
	move.b	oSprBrdFling(a0),d0		; Decrement fling timer
	subq.b	#1,d0
	move.b	d0,oSprBrdFling(a0)
	bne.s	.Draw				; If it hasn't run out, branch
	
	move.b	#2,obj.routine(a0)		; Set to main routine
	move.b	#3,obj.anim_id(a0)		; Reset animation
	move.b	#$40,oSprBrdFling(a0)		; Reset fling timer

.Draw:
	bra.w	ObjSpringBoard_Draw		; Draw and animate sprite

; ------------------------------------------------------------------------------
; Data
; ------------------------------------------------------------------------------

Ani_SpringBoard:
	include	"Level/Palmtree Panic/Objects/Springboard/Data/Animations.asm"
	even
MapSpr_SpringBoard:
	include	"Level/Palmtree Panic/Objects/Springboard/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------
