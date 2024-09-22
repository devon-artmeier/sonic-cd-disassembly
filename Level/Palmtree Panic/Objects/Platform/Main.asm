; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Platform object
; ------------------------------------------------------------------------------

ObjPlatform:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjPlatform_Index(pc,d0.w),d0
	jsr	ObjPlatform_Index(pc,d0.w)
	jsr	DrawObject
	rts
; End of function ObjPlatform

; ------------------------------------------------------------------------------
ObjPlatform_Index:dc.w	ObjPlatform_Init-ObjPlatform_Index
	dc.w	ObjPlatform_Main-ObjPlatform_Index
; ------------------------------------------------------------------------------

ObjPlatform_SolidObj:
	lea	player_object,a1
	move.w	obj.x(a0),d3
	move.w	obj.y(a0),d4
	jmp	TopSolidObject
; End of function ObjPlatform_SolidObj

; ------------------------------------------------------------------------------

ObjPlatform_Init:
	ori.b	#4,obj.sprite_flags(a0)
	move.w	#$44BE,obj.sprite_tile(a0)
	move.b	#2,obj.sprite_layer(a0)
	move.w	obj.x(a0),obj.var_38(a0)
	move.w	obj.y(a0),obj.var_3A(a0)
	move.w	obj.y(a0),obj.var_36(a0)
	move.l	#MapSpr_Platform,d0
	cmpi.w	#0,zone
	beq.s	.SetMaps
	move.l	#MapSpr_Platform,d0
	cmpi.w	#1,zone
	beq.s	.SetMaps
	move.l	#MapSpr_Platform,d0

.SetMaps:
	move.l	d0,obj.sprites(a0)
	move.b	obj.subtype(a0),d0
	move.b	d0,d1
	andi.w	#3,d0
	move.b	d0,obj.sprite_frame(a0)
	move.b	ObjPlatform_Widths(pc,d0.w),obj.width(a0)
	move.b	#8,obj.collide_height(a0)
	lsr.b	#2,d1
	andi.w	#3,d1
	move.b	ObjPlatform_Ranges(pc,d1.w),obj.var_2D(a0)
	move.b	obj.subtype_2(a0),d0
	beq.s	.NoChild
	jsr	FindObjSlot
	beq.s	.MakeSpring
	jmp	ObjPlatform_Destroy

; ------------------------------------------------------------------------------

.MakeSpring:
	move.b	#$A,obj.id(a1)
	move.w	obj.x(a0),obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)
	subi.w	#$10,obj.y(a1)
	move.b	#$F0,obj.var_39(a1)
	move.w	a0,obj.var_34(a1)
	move.b	obj.subtype_2(a0),d0
	move.b	d0,d1
	andi.b	#2,d1
	move.b	d1,obj.subtype(a1)
	andi.b	#$F8,d0
	move.b	d0,obj.var_38(a1)
	add.w	d0,obj.x(a1)

.NoChild:
	addq.b	#2,obj.routine(a0)
	rts
; End of function ObjPlatform_Init

; ------------------------------------------------------------------------------
ObjPlatform_Widths:dc.b	$10, $20, $30, 0
ObjPlatform_Ranges:dc.b	2, 3, 4, 6
; ------------------------------------------------------------------------------

ObjPlatform_Main:
	tst.w	time_stop
	beq.s	.TimeOK
	bra.w	ObjPlatform_SolidObj

; ------------------------------------------------------------------------------

.TimeOK:
	move.b	obj.subtype(a0),d0
	lsr.b	#4,d0
	andi.w	#$F,d0
	add.w	d0,d0
	move.w	ObjPlatform_Subtypes(pc,d0.w),d0
	jsr	ObjPlatform_Subtypes(pc,d0.w)
	move.w	obj.var_38(a0),d0
	andi.w	#$FF80,d0
	move.w	camera_fg_x,d1
	subi.w	#$80,d1
	andi.w	#$FF80,d1
	sub.w	d1,d0
	cmpi.w	#$280,d0
	bhi.s	.Destroy
	rts

; ------------------------------------------------------------------------------

.Destroy:
	lea	player_object,a1
	jsr	GetOffObject
	bra.w	ObjPlatform_Destroy
; End of function ObjPlatform_Main

; ------------------------------------------------------------------------------
ObjPlatform_Subtypes:
	dc.w	ObjPlatform_Subtype0X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype1X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype2X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype3X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype4X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype5X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype6X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype7X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype8X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype9X-ObjPlatform_Subtypes
; ------------------------------------------------------------------------------

ObjPlatform_Subtype0X:
	addq.b	#1,obj.var_2A(a0)
	jsr	ObjPlatform_DoOsc(pc)
	add.w	obj.var_3A(a0),d0
	move.w	d0,obj.y(a0)
	jmp	ObjPlatform_SolidObj
; End of function ObjPlatform_Subtype0X

; ------------------------------------------------------------------------------

ObjPlatform_Subtype1X:
	move.l	obj.x(a0),-(sp)
	jsr	ObjPlatform_DoOsc(pc)
	add.w	obj.var_38(a0),d0
	move.w	d0,obj.x(a0)
	addq.b	#1,obj.var_2A(a0)
	moveq	#0,d0
	move.b	obj.var_2C(a0),d0
	asr.b	#1,d0
	add.w	obj.var_3A(a0),d0
	move.w	d0,obj.y(a0)

ObjPlatform_SetXSpdAndDrop:
	move.l	(sp)+,d0
	move.l	obj.x(a0),d1
	sub.l	d0,d1
	asr.l	#8,d1
	move.w	d1,obj.x_speed(a0)

ObjPlatform_DropWhenStoodOn:
	jsr	ObjPlatform_SolidObj(pc)
	beq.s	.Backup
	move.b	obj.var_2C(a0),d0
	cmpi.b	#8,d0
	bcc.s	.EndDropping
	addq.b	#1,obj.var_2C(a0)

.EndDropping:
	moveq	#1,d0
	rts

; ------------------------------------------------------------------------------

.Backup:
	moveq	#0,d0
	move.b	obj.var_2C(a0),d0
	beq.s	.EndRising
	subq.b	#1,obj.var_2C(a0)

.EndRising:
	moveq	#0,d0
	rts
; End of function ObjPlatform_Subtype1X

; ------------------------------------------------------------------------------

ObjPlatform_Subtype2X:
	move.l	obj.x(a0),-(sp)
	addq.b	#1,obj.var_2A(a0)
	jsr	ObjPlatform_DoOsc(pc)
	add.w	obj.var_3A(a0),d0
	move.w	d0,obj.y(a0)
	jsr	ObjPlatform_DoOsc(pc)
	add.w	obj.var_38(a0),d0
	move.w	d0,obj.x(a0)
	bra.w	ObjPlatform_SetXSpdAndDrop
; End of function ObjPlatform_Subtype2X

; ------------------------------------------------------------------------------

ObjPlatform_Subtype3X:
	move.l	obj.x(a0),-(sp)
	addq.b	#1,obj.var_2A(a0)
	jsr	ObjPlatform_DoOsc(pc)
	add.w	obj.var_3A(a0),d0
	move.w	d0,obj.y(a0)
	jsr	ObjPlatform_DoOsc(pc)
	neg.w	d0
	add.w	obj.var_38(a0),d0
	move.w	d0,obj.x(a0)
	bra.w	ObjPlatform_SetXSpdAndDrop
; End of function ObjPlatform_Subtype3X

; ------------------------------------------------------------------------------

ObjPlatform_Subtype4X:
	moveq	#0,d0
	move.b	obj.var_2C(a0),d0
	asr.b	#1,d0
	add.w	obj.var_3A(a0),d0
	move.w	d0,obj.y(a0)
	bra.w	ObjPlatform_DropWhenStoodOn
; End of function ObjPlatform_Subtype4X

; ------------------------------------------------------------------------------

ObjPlatform_Subtype5X:
	move.b	obj.var_2B(a0),d0
	bne.s	.RunTimer
	jsr	ObjPlatform_Subtype4X(pc)
	bne.s	.InitTimer
	rts

; ------------------------------------------------------------------------------

.InitTimer:
	move.b	#30,obj.var_2E(a0)
	addq.b	#2,obj.var_2B(a0)

.RunTimer:
	move.b	obj.var_2E(a0),d0
	beq.s	.Drop
	subq.b	#1,obj.var_2E(a0)
	bra.w	ObjPlatform_Subtype4X

; ------------------------------------------------------------------------------

.Drop:
	jsr	ObjPlatform_SolidObj(pc)
	move.l	obj.y(a0),d1
	move.w	obj.y_speed(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d1
	move.l	d1,obj.y(a0)
	move.w	obj.y_speed(a0),d0
	cmpi.w	#$400,d0
	bcc.s	.ChkDel
	addi.w	#$40,obj.y_speed(a0)

.ChkDel:
	move.w	camera_fg_y,d0
	addi.w	#256,d0
	cmp.w	obj.y(a0),d0
	bcc.s	.End
	lea	player_object,a1
	jsr	GetOffObject
	jmp	DeleteObject

; ------------------------------------------------------------------------------

.End:
	rts
; End of function ObjPlatform_Subtype5X

; ------------------------------------------------------------------------------

ObjPlatform_Subtype6X:
	move.b	obj.var_2B(a0),d0
	andi.w	#$FF,d0
	move.w	ObjPlatform_Subtype6X_Index(pc,d0.w),d0
	jmp	ObjPlatform_Subtype6X_Index(pc,d0.w)
; End of function ObjPlatform_Subtype6X

; ------------------------------------------------------------------------------
ObjPlatform_Subtype6X_Index:
	dc.w	ObjPlatform_Subtype6X_Stationary1-ObjPlatform_Subtype6X_Index
	dc.w	ObjPlatform_Subtype6X_MoveDown-ObjPlatform_Subtype6X_Index
	dc.w	ObjPlatform_Subtype6X_Stationary2-ObjPlatform_Subtype6X_Index
; ------------------------------------------------------------------------------

ObjPlatform_Subtype6X_Stationary1:
	jsr	ObjPlatform_Subtype4X(pc)
	bne.s	.StartMoving
	rts

; ------------------------------------------------------------------------------

.StartMoving:
	addq.b	#2,obj.var_2B(a0)
; End of function ObjPlatform_Subtype6X_Stationary1

; ------------------------------------------------------------------------------

ObjPlatform_Subtype6X_MoveDown:
	move.b	obj.var_2A(a0),d0
	cmpi.b	#$40,d0
	bcc.w	.StopMoving
	jsr	ObjPlatform_DoOsc(pc)
	neg.w	d0
	add.w	obj.var_3A(a0),d0
	move.w	d0,obj.y(a0)
	addq.b	#2,obj.var_2A(a0)
	jmp	ObjPlatform_SolidObj

; ------------------------------------------------------------------------------

.StopMoving:
	move.w	obj.y(a0),obj.var_3A(a0)
	addq.b	#2,obj.var_2B(a0)
; End of function ObjPlatform_Subtype6X_MoveDown

; ------------------------------------------------------------------------------

ObjPlatform_Subtype6X_Stationary2:
	bra.w	ObjPlatform_Subtype4X
; End of function ObjPlatform_Subtype6X_Stationary2

; ------------------------------------------------------------------------------

ObjPlatform_Subtype7X:
	move.b	obj.var_2B(a0),d0
	andi.w	#$FF,d0
	move.w	ObjPlatform_Subtype7X_Index(pc,d0.w),d0
	jmp	ObjPlatform_Subtype7X_Index(pc,d0.w)
; End of function ObjPlatform_Subtype7X

; ------------------------------------------------------------------------------
ObjPlatform_Subtype7X_Index:dc.w	ObjPlatform_Subtype7X_Stationary1-ObjPlatform_Subtype7X_Index
	dc.w	ObjPlatform_Subtype7X_Rising-ObjPlatform_Subtype7X_Index
	dc.w	ObjPlatform_Subtype7X_Stationary2-ObjPlatform_Subtype7X_Index
; ------------------------------------------------------------------------------

ObjPlatform_Subtype7X_Stationary1:
	jsr	ObjPlatform_Subtype4X(pc)
	bne.s	.StartMoving
	rts

; ------------------------------------------------------------------------------

.StartMoving:
	addq.b	#2,obj.var_2B(a0)
	move.b	#$3C,obj.var_2E(a0)
; End of function ObjPlatform_Subtype7X_Stationary1

; ------------------------------------------------------------------------------

ObjPlatform_Subtype7X_Rising:
	move.b	obj.var_2E(a0),d0
	beq.s	.RiseToCeiling
	subq.b	#1,obj.var_2E(a0)
	bra.w	ObjPlatform_Subtype4X

; ------------------------------------------------------------------------------

.RiseToCeiling:
	jsr	ObjMove
	subq.w	#8,obj.y_speed(a0)
	jsr	ObjGetCeilDist
	tst.w	d1
	bmi.s	.StopMoving
	bra.w	ObjPlatform_DropWhenStoodOn

; ------------------------------------------------------------------------------

.StopMoving:
	sub.w	d1,obj.y(a0)
	move.w	obj.y(a0),obj.var_3A(a0)
	addq.b	#2,obj.var_2B(a0)
; End of function ObjPlatform_Subtype7X_Rising

; ------------------------------------------------------------------------------

ObjPlatform_Subtype7X_Stationary2:
	bra.w	ObjPlatform_Subtype4X
; End of function ObjPlatform_Subtype7X_Stationary2

; ------------------------------------------------------------------------------

ObjPlatform_Subtype8X:
	move.b	obj.var_2B(a0),d0
	andi.w	#$FF,d0
	move.w	ObjPlatform_Subtype8X_Index(pc,d0.w),d0
	jmp	ObjPlatform_Subtype8X_Index(pc,d0.w)
; End of function ObjPlatform_Subtype8X

; ------------------------------------------------------------------------------
ObjPlatform_Subtype8X_Index:dc.w	ObjPlatform_Subtype8X_Stationary1-ObjPlatform_Subtype8X_Index
	dc.w	ObjPlatform_Subtype8X_MoveX-ObjPlatform_Subtype8X_Index
	dc.w	ObjPlatform_Subtype8X_Stationary2-ObjPlatform_Subtype8X_Index
; ------------------------------------------------------------------------------

ObjPlatform_Subtype8X_Stationary1:
	jsr	ObjPlatform_Subtype4X(pc)
	bne.s	.StartMoving
	rts

; ------------------------------------------------------------------------------

.StartMoving:
	addq.b	#2,obj.var_2B(a0)
	move.b	#$3C,obj.var_2E(a0)
; End of function ObjPlatform_Subtype8X_Stationary1

; ------------------------------------------------------------------------------

ObjPlatform_Subtype8X_MoveX:
	move.b	obj.var_2E(a0),d0
	beq.s	.DoMove
	subq.b	#1,obj.var_2E(a0)
	bra.w	ObjPlatform_Subtype4X

; ------------------------------------------------------------------------------

.DoMove:
	move.b	obj.var_2A(a0),d0
	cmpi.b	#$40,d0
	bcc.w	.StopMoving
	move.l	obj.x(a0),-(sp)
	jsr	ObjPlatform_DoOsc(pc)
	add.w	obj.var_38(a0),d0
	move.w	d0,obj.x(a0)
	addq.b	#1,obj.var_2A(a0)
	moveq	#0,d0
	move.b	obj.var_2C(a0),d0
	asr.b	#1,d0
	add.w	obj.var_3A(a0),d0
	move.w	d0,obj.y(a0)
	bra.w	ObjPlatform_SetXSpdAndDrop

; ------------------------------------------------------------------------------

.StopMoving:
	move.w	obj.x(a0),obj.var_38(a0)
	addq.b	#2,obj.var_2B(a0)
; End of function ObjPlatform_Subtype8X_MoveX

; ------------------------------------------------------------------------------

ObjPlatform_Subtype8X_Stationary2:
	bra.w	ObjPlatform_Subtype4X
; End of function ObjPlatform_Subtype8X_Stationary2

; ------------------------------------------------------------------------------

ObjPlatform_Subtype9X:
	move.b	obj.var_2B(a0),d0
	andi.w	#$FF,d0
	move.w	ObjPlatform_Subtype9X_Index(pc,d0.w),d0
	jmp	ObjPlatform_Subtype9X_Index(pc,d0.w)
; End of function ObjPlatform_Subtype9X

; ------------------------------------------------------------------------------
ObjPlatform_Subtype9X_Index:dc.w	ObjPlatform_Subtype9X_Stationary1-ObjPlatform_Subtype9X_Index
	dc.w	ObjPlatform_Subtype9X_MoveX-ObjPlatform_Subtype9X_Index
	dc.w	ObjPlatform_Subtype9X_Stationary2-ObjPlatform_Subtype9X_Index
; ------------------------------------------------------------------------------

ObjPlatform_Subtype9X_Stationary1:
	jsr	ObjPlatform_Subtype4X(pc)
	bne.s	.StartMoving
	rts

; ------------------------------------------------------------------------------

.StartMoving:
	addq.b	#2,obj.var_2B(a0)
	move.b	#$3C,obj.var_2E(a0)
; End of function ObjPlatform_Subtype9X_Stationary1

; ------------------------------------------------------------------------------

ObjPlatform_Subtype9X_MoveX:
	move.b	obj.var_2E(a0),d0
	beq.s	.DoMove
	subq.b	#1,obj.var_2E(a0)
	bra.w	ObjPlatform_Subtype4X

; ------------------------------------------------------------------------------

.DoMove:
	move.b	obj.var_2A(a0),d0
	cmpi.b	#$40,d0
	bcc.s	.StopMoving
	move.l	obj.x(a0),-(sp)
	jsr	ObjPlatform_DoOsc(pc)
	neg.w	d0
	add.w	obj.var_38(a0),d0
	move.w	d0,obj.x(a0)
	addq.b	#1,obj.var_2A(a0)
	moveq	#0,d0
	move.b	obj.var_2C(a0),d0
	asr.b	#1,d0
	add.w	obj.var_3A(a0),d0
	move.w	d0,obj.y(a0)
	bra.w	ObjPlatform_SetXSpdAndDrop

; ------------------------------------------------------------------------------

.StopMoving:
	move.w	obj.x(a0),obj.var_38(a0)
	addq.b	#2,obj.var_2B(a0)
; End of function ObjPlatform_Subtype9X_MoveX

; ------------------------------------------------------------------------------

ObjPlatform_Subtype9X_Stationary2:
	bra.w	ObjPlatform_Subtype4X
; End of function ObjPlatform_Subtype9X_Stationary2

; ------------------------------------------------------------------------------

ObjPlatform_DoOsc:
	moveq	#0,d0
	move.b	obj.var_2A(a0),d0
	jsr	CalcSine
	moveq	#0,d2
	move.b	obj.var_2D(a0),d2
	muls.w	d2,d0
	asr.w	#4,d0
	rts
; End of function ObjPlatform_DoOsc

; ------------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjPlatform_Init

ObjPlatform_Destroy:
	moveq	#0,d0
	move.b	obj.state_id(a0),d0
	beq.s	.Delete
	lea	map_object_states,a1
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	time_zone,d1
	add.w	d1,d0
	bclr	#7,2(a1,d0.w)

.Delete:
	jmp	DeleteObject
; END OF FUNCTION CHUNK	FOR ObjPlatform_Init

; ------------------------------------------------------------------------------
MapSpr_Platform:
	include	"Level/Palmtree Panic/Objects/Platform/Data/Mappings (Platform 1).asm"
	even
MapSpr_Platform2:
	include	"Level/Palmtree Panic/Objects/Platform/Data/Mappings (Platform 2).asm"
	even
	
; ------------------------------------------------------------------------------
