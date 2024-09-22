; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; UFO objects (special stage)
; ------------------------------------------------------------------------------

ufo.player_collide	equ obj.var_4F			; Player collision object ID
ufo.anim_id		equ obj.var_52			; Current animation ID
ufo.explode_dir		equ obj.var_53			; Explode direction
ufo.shadow		equ obj.var_54			; Shadow
ufo.path_start		equ obj.var_58			; Path data start pointer
ufo.path		equ obj.var_5C			; Path data pointer
ufo.path_time		equ obj.var_60			; Path timer
ufo.path_item		equ obj.var_62			; Item ID
ufo.unk_var		equ obj.var_63			; Unknown
ufo.draw_delay		equ obj.var_64			; Draw delay

; ------------------------------------------------------------------------------
; Time UFO
; ------------------------------------------------------------------------------

ObjTimeUFO:
	moveq	#0,d0					; Run routine
	move.b	obj.routine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	move.w	player_object+obj.z,obj.z(a0)		; Shift Z position according to Sonic's Z position
	subi.w	#$140,obj.z(a0)

	tst.b	ufo.draw_delay(a0)			; Is the draw delay counter active?
	beq.s	.End					; If not, branch
	subq.b	#1,ufo.draw_delay(a0)			; Decrement counter
	bset	#2,obj.flags(a0)			; Don't draw sprite

.End:
	rts

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjTimeUFO_Init-.Index
	dc.w	ObjTimeUFO_Main-.Index
	dc.w	ObjTimeUFO_Explode-.Index

; ------------------------------------------------------------------------------

ObjTimeUFO_Init:
	move.w	#$8440,obj.sprite_tile(a0)		; Base tile ID
	bsr.w	ObjUFO_FollowPath			; Start following path
	move.l	#MapSpr_UFORings,obj.sprites(a0)	; Mappings

	move.w	player_object+obj.z,obj.z(a0)		; Shift Z position according to Sonic's Z position
	subi.w	#$140,obj.z(a0)

	addq.b	#1,obj.routine(a0)			; Set routine to main
	move.b	#2,ufo.draw_delay(a0)			; Set draw delay
	
	move.b	#FM_BC,d0				; Play spawn sound
	bsr.w	PlayFMSound

; ------------------------------------------------------------------------------

ObjTimeUFO_Main:
	move.l	obj.x_speed(a0),d0			; Move
	add.l	d0,obj.x(a0)
	move.l	obj.y_speed(a0),d0
	add.l	d0,obj.y(a0)

	subq.w	#1,ufo.path_time(a0)			; Decrement path time
	bne.s	.Draw					; If it hasn't run out yet, branch
	bsr.w	ObjUFO_FollowPath			; Follow path

.Draw:
	bsr.w	ObjUFO_Draw				; Draw sprite
	bsr.w	Set3DSpritePos				; Set sprite position

	bsr.w	ObjUFO_CheckPlayerCol			; Check player collision
	tst.b	ufo.player_collide(a0)			; Was there a collision?
	beq.s	.End					; If not, branch
	tst.b	time_stopped				; Is time stopped?
	bne.s	.End					; If so, branch

	move.b	#2,obj.routine(a0)			; Start exploding
	
	movea.l	ufo.shadow(a0),a1			; Delete shadow
	bset	#0,obj.flags(a1)

	move.w	#60,obj.timer(a0)			; Set explosion time
	bsr.w	Random					; Set explosion direction
	andi.b	#1,d0
	move.b	d0,ufo.explode_dir(a0)

	move.b	#0,d0					; Set animation
	bsr.w	SetObjAnim
	addi.l	#30,special_stage_timer			; Add 30 seconds to the timer

	lea	item_object,a1				; Spawn item icon
	move.b	#4,(a1)
	move.b	#3,item.spawn_type(a1)
	move.w	obj.sprite_x(a0),obj.sprite_x(a1)
	move.w	obj.sprite_y(a0),obj.sprite_y(a1)

.End:
	rts

; ------------------------------------------------------------------------------

ObjTimeUFO_Explode:
	subq.w	#4,obj.sprite_x(a0)			; Move left
	tst.b	ufo.explode_dir(a0)			; Are we supposed to be moving right?
	bne.s	.Fall					; If not, branch
	addq.w	#8,obj.sprite_x(a0)			; If so, move right

.Fall:
	addq.w	#1,obj.sprite_y(a0)			; Move down
	bclr	#2,obj.flags(a0)			; Enable sprite drawing

	subq.w	#1,obj.timer(a0)			; Decrement timer
	bne.s	.Explode				; If it hasn't run out, branch
	bset	#0,obj.flags(a0)			; Delete object

.Explode:
	btst	#0,obj.timer+1(a0)			; Only spawn explosion every other frame
	bne.s	.End

	bsr.w	FindExplosionObjSlot			; Spawn explosion
	bne.s	.End
	move.b	#$C,obj.id(a1)
	move.w	obj.sprite_x(a0),obj.sprite_x(a1)
	subi.w	#16,obj.sprite_x(a1)
	move.w	obj.sprite_y(a0),obj.sprite_y(a1)
	bsr.w	Random
	move.w	d0,d1
	andi.w	#$1F,d0
	add.w	d0,obj.sprite_x(a1)
	andi.w	#$1F,d1
	sub.w	d0,obj.sprite_y(a1)

.End:
	rts

; ------------------------------------------------------------------------------
; UFO object
; ------------------------------------------------------------------------------

ObjUFO:
	moveq	#0,d0					; Run routine
	move.b	obj.routine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	move.w	player_object+obj.z,obj.z(a0)		; Shift Z position according to Sonic's Z position
	subi.w	#$140,obj.z(a0)

	tst.b	ufo.draw_delay(a0)			; Is the draw delay counter active?
	beq.s	.End					; If not, branch
	subq.b	#1,ufo.draw_delay(a0)			; Decrement counter
	bset	#2,obj.flags(a0)			; Don't draw sprite

.End:
	rts

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjUFO_Init-.Index
	dc.w	ObjUFO_Main-.Index
	dc.w	ObjUFO_Explode-.Index

; ------------------------------------------------------------------------------

ObjUFO_Init:
	move.w	#$E440,obj.sprite_tile(a0)		; Base tile ID
	bsr.w	ObjUFO_FollowPath			; Start following path
	
	move.l	#MapSpr_UFORings,obj.sprites(a0)	; Mappings (ring)
	cmpi.b	#0,ufo.path_item(a0)			; Does this UFO have rings?
	beq.s	.GotAnim				; If so, branch
	move.l	#MapSpr_UFOShoes,obj.sprites(a0)	; Mappings (speed shoes)

.GotAnim:
	move.w	player_object+obj.z,obj.z(a0)		; Shift Z position according to Sonic's Z position
	subi.w	#$140,obj.z(a0)

	moveq	#0,d0					; Set animation
	move.b	d0,ufo.anim_id(a0)
	bsr.w	SetObjAnim
	
	move.b	#2,ufo.draw_delay(a0)			; Set draw delay
	addq.b	#1,obj.routine(a0)			; Set routine to main

; ------------------------------------------------------------------------------

ObjUFO_Main:
	move.l	obj.x_speed(a0),d0			; Move
	add.l	d0,obj.x(a0)
	move.l	obj.y_speed(a0),d0
	add.l	d0,obj.y(a0)

	subq.w	#1,ufo.path_time(a0)			; Decrement path time
	bne.s	.Draw					; If it hasn't run out yet, branch
	bsr.w	ObjUFO_FollowPath			; Follow path

.Draw:
	bsr.w	ObjUFO_Draw				; Draw sprite
	bsr.w	Set3DSpritePos				; Set sprite position

	bsr.w	ObjUFO_CheckPlayerCol			; Check player collision
	tst.b	ufo.player_collide(a0)			; Was there a collision?
	beq.w	ObjUFO_End				; If not, branch

	cmpi.b	#2,ufo_count				; Is this the last UFO?
	bcc.s	.Explode				; If not, branch
	move.b	#1,time_stopped				; If so, stop the timer

.Explode:
	bsr.w	DecUFOCount				; Decrement UFO count

	move.b	#2,obj.routine(a0)			; Start exploding
	
	movea.l	ufo.shadow(a0),a1			; Delete shadow
	bset	#0,obj.flags(a1)

	move.w	#60,obj.timer(a0)			; Set explosion time
	bsr.w	Random					; Set explosion direction
	andi.b	#1,d0
	move.b	d0,ufo.explode_dir(a0)

	move.b	#0,d0					; Set animation
	bsr.w	SetObjAnim
	
	lea	item_object,a1				; Spawn item icon
	move.b	#4,(a1)
	move.w	obj.sprite_x(a0),obj.sprite_x(a1)
	move.w	obj.sprite_y(a0),obj.sprite_y(a1)
	move.b	ufo.path_item(a0),item.spawn_type(a1)

	moveq	#0,d0					; Give item bonus
	move.b	ufo.path_item(a0),d0
	add.w	d0,d0
	move.w	.Items(pc,d0.w),d0
	jmp	.Items(pc,d0.w)

; ------------------------------------------------------------------------------

.Items:
	dc.w	.Rings-.Items				; Rings
	dc.w	.SpeedShoes-.Items			; Speed shoes
	dc.w	.Rings-.Items				; Dummy
	dc.w	.Rings-.Items				; Hand

; ------------------------------------------------------------------------------

.Rings:
	move.w	ufo_ring_bonus,d1			; Get ring bonus and double it
	move.w	d1,d0
	add.w	d1,d1
	move.w	d1,ufo_ring_bonus
	bra.w	AddRings

; ------------------------------------------------------------------------------

.SpeedShoes:
	move.w	#200,player_object+player.speed_shoes	; Set speed shoes timer
	move.w	#20,ufo_ring_bonus			; Reset ring bonus
	rts

; ------------------------------------------------------------------------------

ObjUFO_End:
	rts

; ------------------------------------------------------------------------------

ObjUFO_Explode:
	subq.w	#4,obj.sprite_x(a0)			; Move left
	tst.b	ufo.explode_dir(a0)			; Are we supposed to be moving right?
	bne.s	.Fall					; If not, branch
	addq.w	#8,obj.sprite_x(a0)			; If so, move right

.Fall:
	addq.w	#1,obj.sprite_y(a0)			; Move down
	bclr	#2,obj.flags(a0)			; Enable sprite drawing

	subq.w	#1,obj.timer(a0)			; Decrement timer
	bne.s	.Explode				; If it hasn't run out, branch
	bset	#0,obj.flags(a0)			; Delete object

.Explode:
	btst	#0,obj.timer+1(a0)			; Only spawn explosion every other frame
	bne.s	.End

	bsr.w	FindExplosionObjSlot			; Spawn explosion
	bne.s	.End
	move.b	#$C,obj.id(a1)
	move.w	obj.sprite_x(a0),obj.sprite_x(a1)
	subi.w	#16,obj.sprite_x(a1)
	move.w	obj.sprite_y(a0),obj.sprite_y(a1)
	bsr.w	Random
	move.w	d0,d1
	andi.w	#$1F,d0
	add.w	d0,obj.sprite_x(a1)
	andi.w	#$1F,d1
	sub.w	d0,obj.sprite_y(a1)

.End:
	rts

; ------------------------------------------------------------------------------
; Follow path
; ------------------------------------------------------------------------------

ObjUFO_FollowPath:
	movea.l	ufo.path(a0),a1				; Get current path node
	move.w	(a1)+,ufo.path_time(a0)			; Set path time
	bpl.s	.SetDest				; If this is a node, branch
	move.l	ufo.path_start(a0),ufo.path(a0)		; Restart path
	bra.s	ObjUFO_FollowPath			; Loop

.SetDest:
	move.w	(a1)+,d0				; Set start position
	move.w	(a1)+,d1
	move.w	d0,obj.x(a0)
	move.w	d1,obj.y(a0)

	move.w	(a1)+,d2				; Get target position
	move.w	(a1)+,d3
	
	sub.w	d0,d2					; Get distance from target position
	sub.w	d1,d3
	ext.l	d2
	ext.l	d3
	asl.l	#4,d2
	asl.l	#4,d3
	
	divs.w	ufo.path_time(a0),d2			; Set trajectory
	divs.w	ufo.path_time(a0),d3
	ext.l	d2
	ext.l	d3
	asl.l	#4,d2
	asl.l	#4,d3
	asl.l	#8,d2
	asl.l	#8,d3
	move.l	d2,obj.x_speed(a0)
	move.l	d3,obj.y_speed(a0)

	move.l	a1,ufo.path(a0)				; Update path data pointer
	rts

; ------------------------------------------------------------------------------
; Check if a UFO is on screen
; ------------------------------------------------------------------------------

ObjUFO_ChkOnScreen:
	bclr	#2,obj.flags(a0)			; Enable drawing

	move.w	obj.sprite_x(a0),d0			; Is the UFO onscreen horizontally?
	cmpi.w	#384+128,d0
	bcc.s	.Offscreen				; If not, branch

	move.w	obj.sprite_y(a0),d0			; Is the UFO onscreen vertically?
	cmpi.w	#128+128,d0
	blt.s	.Offscreen				; If not, branch
	cmpi.w	#320+128,d0
	blt.s	.End					; If not, branch

.Offscreen:
	bset	#2,obj.flags(a0)			; Disable drawing

.End:
	rts

; ------------------------------------------------------------------------------
; Draw UFO
; ------------------------------------------------------------------------------

ObjUFO_Draw:
	lea	player_object,a6			; Get angle from player
	move.w	obj.x(a6),d4
	move.w	obj.y(a6),d5
	move.w	obj.x(a0),d0
	move.w	obj.y(a0),d1
	bsr.w	GetAngle

	move.w	obj.x(a6),d5				; Get distance from player
	move.w	obj.y(a6),d6
	move.w	obj.x(a0),d3
	move.w	obj.y(a0),d4
	bsr.w	GetDistance

	bsr.w	Set3DObjectDraw				; Draw in 3D space

	cmpi.l	#$500,d0				; Is the distance too far?
	bcs.s	.SetFrame				; If not, branch
	move.l	#$500,d0				; Cap the distance

.SetFrame:
	lsr.w	#4,d0					; Get animation based on distance
	move.b	.Frames(pc,d0.w),d0
	cmp.b	ufo.anim_id(a0),d0			; Is the animation different?
	beq.s	.End					; If not, branch
	move.b	d0,ufo.anim_id(a0)			; If so, set it
	bsr.w	ChgObjAnim

.End:
	rts

; ------------------------------------------------------------------------------

.Frames:
	dc.b	0, 1, 2, 2, 3, 3, 3, 3
	dc.b	4, 4, 4, 4, 4, 4, 4, 4
	dc.b	5, 5, 5, 5, 5, 5, 5, 5
	dc.b	5, 5, 5, 5, 5, 5, 5, 5
	dc.b	6, 6, 6, 6, 6, 6, 6, 6
	dc.b	6, 6, 6, 6, 6, 6, 6, 6
	dc.b	7, 7, 7, 7, 7, 7, 7, 7
	dc.b	7, 7, 7, 7, 7, 7, 7, 7
	dc.b	8, 8, 8, 8, 8, 8, 8, 8
	dc.b	8, 8, 8, 8, 8, 8, 8, 8
	dc.b	9, 0

; ------------------------------------------------------------------------------
; Spawn UFOs
; ------------------------------------------------------------------------------

SpawnUFOs:
	moveq	#0,d0					; Get UFO path data for stage
	move.b	special_stage_id,d0
	lsl.w	#2,d0
	movea.l	.Index(pc,d0.w),a1

	lea	ufo_objects,a2				; UFO object slots
	move.w	(a1)+,d7				; Get number of UFOs
	move.b	d7,ufo_count
	subq.w	#1,d7

.SpawnLoop:
	bsr.s	.Spawn					; Spawn UFO
	lea	obj.struct_size(a2),a2			; Next slot
	dbf	d7,.SpawnLoop				; Loop until UFOs are spawned
	rts

; ------------------------------------------------------------------------------

.Index:
	dc.l	UfoPaths_Stage1				; Stage 1
	dc.l	UfoPaths_Stage2				; Stage 2
	dc.l	UfoPaths_Stage3				; Stage 3
	dc.l	UfoPaths_Stage4				; Stage 4
	dc.l	UfoPaths_Stage5				; Stage 5
	dc.l	UfoPaths_Stage6				; Stage 6
	dc.l	UfoPaths_Stage7				; Stage 7
	dc.l	UfoPaths_Stage8				; Stage 8

; ------------------------------------------------------------------------------

.Spawn:
	movea.l	(a1)+,a3				; Get path data
	lea	ufo_shadow_objects-ufo_objects(a2),a4	; Get shadow slot

	move.b	#2,(a2)					; Spawn UFO
	move.b	(a3)+,ufo.path_item(a2)
	move.b	(a3)+,ufo.unk_var(a2)
	move.l	a3,ufo.path_start(a2)
	move.l	a3,ufo.path(a2)
	move.l	a4,ufo.shadow(a2)

	move.b	#5,(a4)					; Spawn shadow
	move.l	a2,shadow.parent(a4)
	rts

; ------------------------------------------------------------------------------
; Spawn time UFO
; ------------------------------------------------------------------------------

SpawnTimeUFO:
	cmpi.l	#20,special_stage_timer			; Are we running out of time?
	bcc.s	.End					; If not, branch

	lea	time_ufo_object,a2			; Time UFO object slot
	lea	TimeUfoPath(pc),a3			; Path data
	tst.b	(a2)					; If the time UFO already spawned?
	bne.s	.End					; If so, branch
	lea	ufo_shadow_objects-ufo_objects(a2),a4	; Get shadow slot

	move.b	#3,(a2)					; Spawn UFO
	move.b	(a3)+,ufo.path_item(a2)
	move.b	(a3)+,ufo.unk_var(a2)
	move.l	a3,ufo.path_start(a2)
	move.l	a3,ufo.path(a2)
	move.l	a4,ufo.shadow(a2)

	move.b	#5,(a4)					; Spawn shadow
	move.l	a2,shadow.parent(a4)

.End:
	rts

; ------------------------------------------------------------------------------
; UFO path data
; ------------------------------------------------------------------------------

TimeUfoPath:
	incbin	"Special Stage/Data/Time UFO Path.bin"
	even

; ------------------------------------------------------------------------------

UfoPaths_Stage1:
	dc.w	6
	dc.l	UfoPath_Stage1_1
	dc.l	UfoPath_Stage1_2
	dc.l	UfoPath_Stage1_3
	dc.l	UfoPath_Stage1_4
	dc.l	UfoPath_Stage1_5
	dc.l	UfoPath_Stage1_6

UfoPaths_Stage2:
	dc.w	6
	dc.l	UfoPath_Stage2_1
	dc.l	UfoPath_Stage2_2
	dc.l	UfoPath_Stage2_3
	dc.l	UfoPath_Stage2_4
	dc.l	UfoPath_Stage2_5
	dc.l	UfoPath_Stage2_6

UfoPaths_Stage3:
	dc.w	6
	dc.l	UfoPath_Stage3_1
	dc.l	UfoPath_Stage3_2
	dc.l	UfoPath_Stage3_3
	dc.l	UfoPath_Stage3_4
	dc.l	UfoPath_Stage3_5
	dc.l	UfoPath_Stage3_6

UfoPaths_Stage4:
	dc.w	6
	dc.l	UfoPath_Stage4_1
	dc.l	UfoPath_Stage4_2
	dc.l	UfoPath_Stage4_3
	dc.l	UfoPath_Stage4_4
	dc.l	UfoPath_Stage4_5
	dc.l	UfoPath_Stage4_6

UfoPaths_Stage5:
	dc.w	6
	dc.l	UfoPath_Stage5_1
	dc.l	UfoPath_Stage5_2
	dc.l	UfoPath_Stage5_3
	dc.l	UfoPath_Stage5_4
	dc.l	UfoPath_Stage5_5
	dc.l	UfoPath_Stage5_6

UfoPaths_Stage6:
	dc.w	6
	dc.l	UfoPath_Stage6_1
	dc.l	UfoPath_Stage6_2
	dc.l	UfoPath_Stage6_3
	dc.l	UfoPath_Stage6_4
	dc.l	UfoPath_Stage6_5
	dc.l	UfoPath_Stage6_6

UfoPaths_Stage7:
	dc.w	6
	dc.l	UfoPath_Stage7_1
	dc.l	UfoPath_Stage7_2
	dc.l	UfoPath_Stage7_3
	dc.l	UfoPath_Stage7_4
	dc.l	UfoPath_Stage7_5
	dc.l	UfoPath_Stage7_6

UfoPaths_Stage8:
	dc.w	6
	dc.l	UfoPath_Stage8_1
	dc.l	UfoPath_Stage8_2
	dc.l	UfoPath_Stage8_3
	dc.l	UfoPath_Stage8_4
	dc.l	UfoPath_Stage8_5
	dc.l	UfoPath_Stage8_6

; ------------------------------------------------------------------------------

UfoPath_Stage1_1:
	incbin	"Special Stage/Data/Stage 1/UFO 1.bin"
	even

UfoPath_Stage1_2:
	incbin	"Special Stage/Data/Stage 1/UFO 2.bin"
	even

UfoPath_Stage1_3:
	incbin	"Special Stage/Data/Stage 1/UFO 3.bin"
	even

UfoPath_Stage1_4:
	incbin	"Special Stage/Data/Stage 1/UFO 4.bin"
	even

UfoPath_Stage1_5:
	incbin	"Special Stage/Data/Stage 1/UFO 5.bin"
	even

UfoPath_Stage1_6:
	incbin	"Special Stage/Data/Stage 1/UFO 6.bin"
	even

UfoPath_Stage2_1:
	incbin	"Special Stage/Data/Stage 2/UFO 1.bin"
	even

UfoPath_Stage2_2:
	incbin	"Special Stage/Data/Stage 2/UFO 2.bin"
	even

UfoPath_Stage2_3:
	incbin	"Special Stage/Data/Stage 2/UFO 3.bin"
	even

UfoPath_Stage2_4:
	incbin	"Special Stage/Data/Stage 2/UFO 4.bin"
	even

UfoPath_Stage2_5:
	incbin	"Special Stage/Data/Stage 2/UFO 5.bin"
	even

UfoPath_Stage2_6:
	incbin	"Special Stage/Data/Stage 2/UFO 6.bin"
	even

UfoPath_Stage3_1:
	incbin	"Special Stage/Data/Stage 3/UFO 1.bin"
	even

UfoPath_Stage3_2:
	incbin	"Special Stage/Data/Stage 3/UFO 2.bin"
	even

UfoPath_Stage3_3:
	incbin	"Special Stage/Data/Stage 3/UFO 3.bin"
	even

UfoPath_Stage3_4:
	incbin	"Special Stage/Data/Stage 3/UFO 4.bin"
	even

UfoPath_Stage3_5:
	incbin	"Special Stage/Data/Stage 3/UFO 5.bin"
	even

UfoPath_Stage3_6:
	incbin	"Special Stage/Data/Stage 3/UFO 6.bin"
	even

UfoPath_Stage4_1:
	incbin	"Special Stage/Data/Stage 4/UFO 1.bin"
	even

UfoPath_Stage4_2:
	incbin	"Special Stage/Data/Stage 4/UFO 2.bin"
	even

UfoPath_Stage4_3:
	incbin	"Special Stage/Data/Stage 4/UFO 3.bin"
	even

UfoPath_Stage4_4:
	incbin	"Special Stage/Data/Stage 4/UFO 4.bin"
	even

UfoPath_Stage4_5:
	incbin	"Special Stage/Data/Stage 4/UFO 5.bin"
	even

UfoPath_Stage4_6:
	incbin	"Special Stage/Data/Stage 4/UFO 6.bin"
	even

UfoPath_Stage5_1:
	incbin	"Special Stage/Data/Stage 5/UFO 1.bin"
	even

UfoPath_Stage5_2:
	incbin	"Special Stage/Data/Stage 5/UFO 2.bin"
	even

UfoPath_Stage5_3:
	incbin	"Special Stage/Data/Stage 5/UFO 3.bin"
	even

UfoPath_Stage5_4:
	incbin	"Special Stage/Data/Stage 5/UFO 4.bin"
	even

UfoPath_Stage5_5:
	incbin	"Special Stage/Data/Stage 5/UFO 5.bin"
	even

UfoPath_Stage5_6:
	incbin	"Special Stage/Data/Stage 5/UFO 6.bin"
	even

UfoPath_Stage6_1:
	incbin	"Special Stage/Data/Stage 6/UFO 1.bin"
	even

UfoPath_Stage6_2:
	incbin	"Special Stage/Data/Stage 6/UFO 2.bin"
	even

UfoPath_Stage6_3:
	incbin	"Special Stage/Data/Stage 6/UFO 3.bin"
	even

UfoPath_Stage6_4:
	incbin	"Special Stage/Data/Stage 6/UFO 4.bin"
	even

UfoPath_Stage6_5:
	incbin	"Special Stage/Data/Stage 6/UFO 5.bin"
	even

UfoPath_Stage6_6:
	incbin	"Special Stage/Data/Stage 6/UFO 6.bin"
	even

UfoPath_Stage7_1:
	incbin	"Special Stage/Data/Stage 7/UFO 1.bin"
	even

UfoPath_Stage7_2:
	incbin	"Special Stage/Data/Stage 7/UFO 2.bin"
	even

UfoPath_Stage7_3:
	incbin	"Special Stage/Data/Stage 7/UFO 3.bin"
	even

UfoPath_Stage7_4:
	incbin	"Special Stage/Data/Stage 7/UFO 4.bin"
	even

UfoPath_Stage7_5:
	incbin	"Special Stage/Data/Stage 7/UFO 5.bin"
	even

UfoPath_Stage7_6:
	incbin	"Special Stage/Data/Stage 7/UFO 6.bin"
	even

UfoPath_Stage8_1:
	incbin	"Special Stage/Data/Stage 8/UFO 1.bin"
	even

UfoPath_Stage8_2:
	incbin	"Special Stage/Data/Stage 8/UFO 2.bin"
	even

UfoPath_Stage8_3:
	incbin	"Special Stage/Data/Stage 8/UFO 3.bin"
	even

UfoPath_Stage8_4:
	incbin	"Special Stage/Data/Stage 8/UFO 4.bin"
	even

UfoPath_Stage8_5:
	incbin	"Special Stage/Data/Stage 8/UFO 5.bin"
	even

UfoPath_Stage8_6:
	incbin	"Special Stage/Data/Stage 8/UFO 6.bin"
	even

; ------------------------------------------------------------------------------
