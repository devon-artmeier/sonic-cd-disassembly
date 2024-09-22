; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Goddess statue object
; ------------------------------------------------------------------------------

oGoddessTime	EQU	obj.var_2A
oGoddessCount	EQU	obj.var_2B

; ------------------------------------------------------------------------------

ObjGoddessStatue:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	jmp	CheckObjDespawn
	
; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjGoddessStatue_Init-.Index
	dc.w	ObjGoddessStatue_Main-.Index
	dc.w	ObjGoddessStatue_SpitRings-.Index
	dc.w	ObjGoddessStatue_Done-.Index

; ------------------------------------------------------------------------------

ObjGoddessStatue_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#50,oGoddessCount(a0)

; ------------------------------------------------------------------------------

ObjGoddessStatue_Main:
	move.w	player_object+obj.x,d0
	sub.w	obj.x(a0),d0
	addi.w	#16,d0
	bcs.s	.End
	cmpi.w	#32,d0
	bcc.s	.End
	
	move.w	player_object+obj.y,d0
	sub.w	obj.y(a0),d0
	addi.w	#32,d0
	bcs.s	.End
	cmpi.w	#64,d0
	bcc.s	.End
	
	addq.b	#2,obj.routine(a0)
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjGoddessStatue_SpitRings:
	subq.b	#1,oGoddessTime(a0)
	bpl.s	ObjGoddessStatue_Done
	move.b	#10,oGoddessTime(a0)
	
	subq.b	#1,oGoddessCount(a0)
	bpl.s	ObjGoddessStatue_SpawnRing
	addq.b	#2,obj.routine(a0)

ObjGoddessStatue_Done:
	rts

; ------------------------------------------------------------------------------

ObjGoddessStatue_SpawnRing:
	jsr	FindObjSlot
	bne.s	.End
	
	move.b	#$11,obj.id(a1)
	addq.b	#2,obj.routine(a1)
	move.b	#8,obj.collide_height(a1)
	move.b	#8,obj.collide_width(a1)
	move.w	obj.x(a0),obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)
	addi.w	#24,obj.x(a1)
	subi.w	#16,obj.y(a1)
	move.l	#MapSpr_Ring,obj.sprites(a1)
	move.w	#$A7AE,obj.sprite_tile(a1)
	move.b	#3,obj.sprite_layer(a1)
	move.b	#4,obj.sprite_flags(a1)
	move.b	#$47,obj.collide_type(a1)
	move.b	#8,obj.width(a1)
	move.b	#8,obj.collide_height(a1)
	move.b	#$FF,ring_loss_anim_timer
	
	move.w	#-$200,obj.y_speed(a1)
	jsr	Random
	lsl.w	#1,d0
	andi.w	#$E,d0
	move.w	.XVels(pc,d0.w),obj.x_speed(a1)
	
.End:
	rts

; ------------------------------------------------------------------------------

.XVels:
	dc.w	-$100
	dc.w	-$80
	dc.w	0
	dc.w	$80
	dc.w	$100
	dc.w	$180
	dc.w	$200
	dc.w	$280

; ------------------------------------------------------------------------------
