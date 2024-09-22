; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Object time zone check functions
; ------------------------------------------------------------------------------

DestroyOnGoodFuture:
	tst.b	good_future
	beq.s	.End
	cmpi.b	#1,time_zone
	bne.s	.Destroy
	tst.b	obj.subtype(a0)
	beq.s	.End

.Destroy:
	move.w	obj.x(a0),d5
	move.w	obj.y(a0),d6
	jsr	DeleteObject
	move.w	d5,obj.x(a0)
	move.w	d6,obj.y(a0)
	move.b	#$18,obj.id(a0)
	tst.b	obj.sprite_flags(a0)
	bpl.s	.NoReturn
	move.w	#FM_EXPLODE,d0
	jsr	PlayFMSound

.NoReturn:
	addq.l	#4,sp

.End:
	rts

; ------------------------------------------------------------------------------

CheckAnimalPrescence:
	tst.b	obj.subtype(a0)
	bmi.s	.End
	cmpi.b	#2,time_zone
	bge.s	.ChkGoodFuture
	tst.b	projector_destroyed
	bne.s	.End
	addq.l	#4,sp
	jmp	CheckObjDespawn

.ChkGoodFuture:
	tst.b	good_future
	bne.s	.End
	addq.l	#4,sp
	jmp	DeleteObject

.End:
	rts

; ------------------------------------------------------------------------------
