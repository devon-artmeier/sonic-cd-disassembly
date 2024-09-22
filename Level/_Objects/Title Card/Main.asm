; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Title card object
; ------------------------------------------------------------------------------

ObjTitleCard:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjTitleCard_Index(pc,d0.w),d0
	jmp	ObjTitleCard_Index(pc,d0.w)
; End of function ObjTitleCard

; ------------------------------------------------------------------------------
ObjTitleCard_Index:dc.w	ObjTitleCard_Init-ObjTitleCard_Index
	dc.w	ObjTitleCard_SlideInVert-ObjTitleCard_Index
	dc.w	ObjTitleCard_SlideInHoriz-ObjTitleCard_Index
	dc.w	ObjTitleCard_SlideOutVert-ObjTitleCard_Index
	dc.w	ObjTitleCard_SlideOutHoriz-ObjTitleCard_Index
	dc.w	ObjTitleCard_WaitPLC-ObjTitleCard_Index
; ------------------------------------------------------------------------------

ObjTitleCard_Init:
	move.b	#2,obj.routine(a0)
	move.w	#$118,obj.screen_x(a0)
	move.w	#$30,obj.screen_y(a0)
	move.w	#$30,obj.var_30(a0)
	move.w	#$F0,obj.var_2E(a0)
	move.b	#$5A,obj.anim_time(a0)
	move.w	#$8360,obj.sprite_tile(a0)
	move.l	#MapSpr_TitleCard,obj.sprites(a0)
	move.b	#4,obj.sprite_layer(a0)
	moveq	#0,d1
	moveq	#7,d6
	lea	ObjTitleCard_Data,a2

.Loop:
	jsr	FindObjSlot
	move.b	#$3C,obj.id(a1)
	move.b	#4,obj.routine(a1)
	move.w	#$8360,obj.sprite_tile(a1)
	move.l	#MapSpr_TitleCard,obj.sprites(a1)
	move.w	d1,d2
	lsl.w	#3,d2
	move.w	(a2,d2.w),obj.screen_y(a1)
	move.w	2(a2,d2.w),obj.screen_x(a1)
	move.w	2(a2,d2.w),obj.var_2C(a1)
	move.w	4(a2,d2.w),obj.var_2A(a1)
	move.b	6(a2,d2.w),obj.sprite_frame(a1)
	cmpi.b	#5,d1
	bne.s	.NotActNum
	move.b	act,d3
	add.b	d3,obj.sprite_frame(a1)

.NotActNum:
	move.b	7(a2,d2.w),obj.anim_time(a1)
	addq.b	#1,d1
	dbf	d6,.Loop
	rts
; End of function ObjTitleCard_Init

; ------------------------------------------------------------------------------

ObjTitleCard_SlideInVert:
	moveq	#8,d0
	move.w	obj.var_2E(a0),d1
	cmp.w	obj.screen_y(a0),d1
	beq.s	.DidSlide
	bge.s	.Dobj.ySlide
	neg.w	d0

.Dobj.ySlide:
	add.w	d0,obj.screen_y(a0)
	jmp	DrawObject

; ------------------------------------------------------------------------------

.DidSlide:
	addq.b	#4,obj.routine(a0)
	jmp	DrawObject
; End of function ObjTitleCard_SlideInVert

; ------------------------------------------------------------------------------

ObjTitleCard_SlideInHoriz:
	moveq	#8,d0
	move.w	obj.var_2A(a0),d1
	cmp.w	obj.screen_x(a0),d1
	beq.s	.DidSlide
	bge.s	.DoXSlide
	neg.w	d0

.DoXSlide:
	add.w	d0,obj.x(a0)
	jmp	DrawObject

; ------------------------------------------------------------------------------

.DidSlide:
	addq.b	#4,obj.routine(a0)
	jmp	DrawObject
; End of function ObjTitleCard_SlideInHoriz

; ------------------------------------------------------------------------------

ObjTitleCard_SlideOutVert:
	tst.b	obj.anim_time(a0)
	beq.s	.SlideOut
	subq.b	#1,obj.anim_time(a0)
	jmp	DrawObject

; ------------------------------------------------------------------------------

.SlideOut:
	moveq	#$10,d0
	move.w	obj.var_30(a0),d1
	cmp.w	obj.screen_y(a0),d1
	beq.s	.DidSlide
	bge.s	.Dobj.ySlide
	neg.w	d0

.Dobj.ySlide:
	add.w	d0,obj.screen_y(a0)
	jmp	DrawObject

; ------------------------------------------------------------------------------

.DidSlide:
	addq.b	#4,obj.routine(a0)
	move.b	#1,scroll_lock
	moveq	#2,d0
	jmp	LoadPLC
; End of function ObjTitleCard_SlideOutVert

; ------------------------------------------------------------------------------

ObjTitleCard_SlideOutHoriz:
	tst.b	obj.anim_time(a0)
	beq.s	.SlideOut
	subq.b	#1,obj.anim_time(a0)
	jmp	DrawObject

; ------------------------------------------------------------------------------

.SlideOut:
	moveq	#$10,d0
	move.w	obj.var_2C(a0),d1
	cmp.w	obj.x(a0),d1
	beq.s	.DidSlide
	bge.s	.DoXSlide
	neg.w	d0

.DoXSlide:
	add.w	d0,obj.x(a0)
	jmp	DrawObject

; ------------------------------------------------------------------------------

.DidSlide:
	jmp	DeleteObject
; End of function ObjTitleCard_SlideOutHoriz

; ------------------------------------------------------------------------------

ObjTitleCard_WaitPLC:
	tst.l	nem_art_queue
	bne.s	.End
	clr.b	scroll_lock
	clr.b	ctrl_locked
	jmp	DeleteObject

; ------------------------------------------------------------------------------

.End:
	rts
	
; ------------------------------------------------------------------------------
