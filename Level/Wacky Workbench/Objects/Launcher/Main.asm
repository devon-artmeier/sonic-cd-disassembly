; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Launcher object
; ------------------------------------------------------------------------------

oLaunchParent	EQU	obj.var_2A
oLaunchX	EQU	obj.var_2E

; ------------------------------------------------------------------------------

ObjLauncher:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawn
	
; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjLauncher_Init-.Index
	dc.w	ObjLauncher_Main-.Index
	dc.w	ObjLauncher_Launch-.Index
	dc.w	ObjLauncher_Revert-.Index
	dc.w	ObjLauncher_SolidSide-.Index

; ------------------------------------------------------------------------------

ObjLauncher_Init:
	ori.b	#4,obj.sprite_flags(a0)
	move.w	#$400,obj.sprite_tile(a0)
	move.l	#MapSpr_Launcher,obj.sprites(a0)
	move.w	obj.x(a0),oLaunchX(a0)
	move.b	#28,obj.collide_width(a0)
	move.b	#28,obj.width(a0)
	move.b	#4,obj.collide_height(a0)
	addq.b	#2,obj.routine(a0)
	
	jsr	FindNextObjSlot
	move.b	#4,obj.id(a1)
	ori.b	#4,obj.sprite_flags(a1)
	move.w	#$400,obj.sprite_tile(a1)
	move.l	#MapSpr_Launcher,obj.sprites(a1)
	move.b	#4,obj.collide_width(a1)
	move.b	#12,obj.collide_height(a1)
	move.b	#1,obj.sprite_frame(a1)
	move.l	a0,oLaunchParent(a1)
	move.b	#8,obj.routine(a1)

; ------------------------------------------------------------------------------

ObjLauncher_Main:
	lea	player_object,a1
	jsr	TopSolidObject
	beq.s	.End
	bset	#0,oPlayerCtrl(a1)
	move.w	obj.x(a0),obj.x(a1)
	bclr	#0,obj.flags(a1)
	move.b	#$3A,obj.anim_id(a1)
	addq.b	#2,obj.routine(a0)
	move.w	#$C00,obj.x_speed(a0)
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjLauncher_Launch:
	move.w	obj.x_speed(a0),d0
	ext.l	d0
	asl.l	#8,d0
	move.l	obj.x(a0),d1
	add.l	d0,d1
	move.l	d1,obj.x(a0)
	
	lea	player_object,a1
	jsr	TopSolidObject
	
	move.w	p1_ctrl,d0
	andi.b	#$70,d0
	beq.s	.NoJump
	
	bclr	#0,oPlayerCtrl(a1)
	move.w	#-$680,obj.y_speed(a1)
	move.w	obj.x_speed(a0),obj.x_speed(a1)
	move.b	#$E,obj.collide_height(a1)
	move.b	#7,obj.collide_width(a1)
	addq.w	#5,obj.y(a1)
	bset	#2,obj.flags(a1)
	bclr	#5,obj.flags(a1)
	move.b	#2,obj.anim_id(a1)
	move.w	#FM_JUMP,d0
	jsr	PlayFMSound
	
.NoJump:
	move.w	oLaunchX(a0),d0
	addi.w	#912,d0
	cmp.w	obj.x(a0),d0
	bcc.s	.End
	move.w	d0,obj.x(a0)
	
	addq.b	#2,obj.routine(a0)
	btst	#3,obj.flags(a0)
	beq.s	.End
	bclr	#0,oPlayerCtrl(a1)
	move.w	obj.x_speed(a0),obj.x_speed(a1)
	move.b	#0,obj.anim_id(a1)
	bset	#1,obj.flags(a1)
	bclr	#3,obj.flags(a1)

.End:
	rts

; ------------------------------------------------------------------------------

ObjLauncher_Revert:
	subq.w	#4,obj.x(a0)
	move.w	oLaunchX(a0),d0
	cmp.w	obj.x(a0),d0
	bcs.s	.End
	move.w	oLaunchX(a0),obj.x(a0)
	move.b	#2,obj.routine(a0)
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjLauncher_SolidSide:
	movea.l	oLaunchParent(a0),a1
	cmpi.b	#4,obj.routine(a1)
	bcc.s	.End
	move.w	obj.x(a1),obj.x(a0)
	subi.w	#24,obj.x(a0)
	move.w	obj.y(a1),obj.y(a0)
	subi.w	#16,obj.y(a0)
	
	lea	player_object,a1
	jmp	SolidObject
	
.End:
	rts

; ------------------------------------------------------------------------------

MapSpr_Launcher:
	include	"Level/Wacky Workbench/Objects/Launcher/Data/Mappings.asm"
	even
	
; ------------------------------------------------------------------------------
