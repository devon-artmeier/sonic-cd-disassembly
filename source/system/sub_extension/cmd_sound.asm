; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"
	include	"system_symbols.inc"
	include	"pcm_sound_ids.inc"
	include	"pcm_driver.inc"

	section code
	
	xref FinishCommand, Round1ASong, Round1CSong, Round1DSong
	xref Round3ASong, Round3CSong, Round3DSong, Round4ASong
	xref Round4CSong, Round4DSong, Round5ASong, Round5CSong
	xref Round5DSong, Round6ASong, Round6CSong, Round6DSong
	xref Round7ASong, Round7CSong, Round7DSong, Round8ASong
	xref Round8CSong, Round8DSong, BossSong, FinalBossSong
	xref TimeAttackSong, SpecialStageSong, DaGardenSong, ProtoWarpSound
	xref OpeningSong, EndingSong, TitleScreenSong, ResultsSong
	xref SpeedShoesSong, InvincibleSong, GameOverSong, PcmDriverR1BFile
	xref PcmDriverR3BFile, PcmDriverR4BFile, PcmDriverR5BFile, PcmDriverR6BFile
	xref PcmDriverR7BFile, PcmDriverR8BFile

; ------------------------------------------------------------------------------
; Play "Future" voice clip
; ------------------------------------------------------------------------------

	xdef PlayFutureVoiceSfx
PlayFutureVoiceSfx:
	move.b	#PCM_SFX_FUTURE,PcmSoundQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Past" voice clip
; ------------------------------------------------------------------------------

	xdef PlayPastVoiceSfx
PlayPastVoiceSfx:
	move.b	#PCM_SFX_PAST,PcmSoundQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Alright" voice clip
; ------------------------------------------------------------------------------

	xdef PlayAlrightSfx
PlayAlrightSfx:
	move.b	#PCM_SFX_ALRIGHT,PcmSoundQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "I'm outta here" voice clip
; ------------------------------------------------------------------------------

	xdef PlayOuttaHereSfx
PlayOuttaHereSfx:
	move.b	#PCM_SFX_OUTTA_HERE,PcmSoundQueue		; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Yes" voice clip
; ------------------------------------------------------------------------------

	xdef PlayYesSfx
PlayYesSfx:
	move.b	#PCM_SFX_YES,PcmSoundQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Yeah" voice clip
; ------------------------------------------------------------------------------

	xdef PlayYeahSfx
PlayYeahSfx:
	move.b	#PCM_SFX_YEAH,PcmSoundQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Amy giggle voice clip
; ------------------------------------------------------------------------------

	xdef PlayAmyGiggleSfx
PlayAmyGiggleSfx:
	move.b	#PCM_SFX_AMY_GIGGLE,PcmSoundQueue		; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Amy yelp voice clip
; ------------------------------------------------------------------------------

	xdef PlayAmyYelpSfx
PlayAmyYelpSfx:
	move.b	#PCM_SFX_AMY_YELP,PcmSoundQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play mech stomp sound
; ------------------------------------------------------------------------------

	xdef PlayStompSfx
PlayStompSfx:
	move.b	#PCM_SFX_STOMP,PcmSoundQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play bumper sound
; ------------------------------------------------------------------------------

	xdef PlayBumperSfx
PlayBumperSfx:
	move.b	#PCM_SFX_BUMPER,PcmSoundQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play glass break sound
; ------------------------------------------------------------------------------

	xdef PlayBreakSfx
PlayBreakSfx:
	move.b	#PCM_SFX_BREAK,PcmSoundQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play past music
; ------------------------------------------------------------------------------

	xdef PlayPastSong
PlayPastSong:
	move.b	#PCM_SONG_PAST,PcmSoundQueue			; Play music
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Fade out PCM
; ------------------------------------------------------------------------------

	xdef FadeOutPcm
FadeOutPcm:
	move.b	#PCM_CMD_FADE_OUT,PcmSoundQueue			; Fade out PCM
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Stop PCM
; ------------------------------------------------------------------------------

	xdef StopPcm
StopPcm:
	move.b	#PCM_CMD_STOP,PcmSoundQueue			; Stop PCM
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Pause PCM
; ------------------------------------------------------------------------------

	xdef PausePcm
PausePcm:
	move.b	#PCM_CMD_PAUSE,PcmSoundQueue			; Pause PCM
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Unpause PCM
; ------------------------------------------------------------------------------

	xdef UnpausePcm
UnpausePcm:
	move.b	#PCM_CMD_UNPAUSE,PcmSoundQueue			; Unpause PCM
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Reset CD audio volume
; ------------------------------------------------------------------------------

	xdef ResetCddaVolumeCmd
ResetCddaVolumeCmd:
	bsr.w	ResetCddaVolume					; Reset CD audio volume
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Fade out CD audio
; ------------------------------------------------------------------------------

	xdef FadeOutCdda
FadeOutCdda:
	move.w	#FDRCHG,d0					; Fade out CD audio
	moveq	#$20,d1
	jsr	_CDBIOS
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Stop CD audio
; ------------------------------------------------------------------------------

	xdef StopCdda
StopCdda:
	move.w	#MSCSTOP,d0					; Stop CD audio
	jsr	_CDBIOS
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Pause CD audio
; ------------------------------------------------------------------------------

	xdef PauseCdda
PauseCdda:
	move.w	#MSCPAUSEON,d0					; Pause CD audio
	jsr	_CDBIOS
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Unpause CD audio
; ------------------------------------------------------------------------------

	xdef UnpauseCdda
UnpauseCdda:
	move.w	#MSCPAUSEOFF,d0					; Unpause CD audio
	jsr	_CDBIOS
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Reset CD audio volume
; ------------------------------------------------------------------------------

	xdef ResetCddaVolume
ResetCddaVolume:
	move.l	a0,-(sp)					; Save registers
	
	move.w	#FDRSET,d0					; Set CD audio volume
	move.w	#$380,d1
	jsr	_CDBIOS

	move.w	#FDRSET,d0					; Set CD audio master volume
	move.w	#$8380,d1
	jsr	_CDBIOS

	movea.l	(sp)+,a0					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Play Palmtree Panic Present music
; ------------------------------------------------------------------------------

	xdef PlayRound1ASong
PlayRound1ASong:
	lea	Round1ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Palmtree Panic Good Future music
; ------------------------------------------------------------------------------

	xdef PlayRound1CSong
PlayRound1CSong:
	lea	Round1CSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Palmtree Panic Bad Future music
; ------------------------------------------------------------------------------

	xdef PlayRound1DSong
PlayRound1DSong:
	lea	Round1DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Collision Chaos Present music
; ------------------------------------------------------------------------------

	xdef PlayRound3ASong
PlayRound3ASong:
	lea	Round3ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Collision Chaos Good Future music
; ------------------------------------------------------------------------------

	xdef PlayRound3CSong
PlayRound3CSong:
	lea	Round3CSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Collision Chaos Bad Future music
; ------------------------------------------------------------------------------

	xdef PlayRound3DSong
PlayRound3DSong:
	lea	Round3DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Tidal Tempest Present music
; ------------------------------------------------------------------------------

	xdef PlayRound4ASong
PlayRound4ASong:
	lea	Round4ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Tidal Tempest Good Future music
; ------------------------------------------------------------------------------

	xdef PlayRound4CSong
PlayRound4CSong:
	lea	Round4CSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Tidal Tempest Bad Future music
; ------------------------------------------------------------------------------

	xdef PlayRound4DSong
PlayRound4DSong:
	lea	Round4DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Quartz Quadrant Present music
; ------------------------------------------------------------------------------

	xdef PlayRound5ASong
PlayRound5ASong:
	lea	Round5ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Quartz Quadrant Good Future music
; ------------------------------------------------------------------------------

	xdef PlayRound5CSong
PlayRound5CSong:
	lea	Round5CSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Quartz Quadrant Bad Future music
; ------------------------------------------------------------------------------

	xdef PlayRound5DSong
PlayRound5DSong:
	lea	Round5DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Wacky Workbench Present music
; ------------------------------------------------------------------------------

	xdef PlayRound6ASong
PlayRound6ASong:
	lea	Round6ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Wacky Workbench Good Future music
; ------------------------------------------------------------------------------

	xdef PlayRound6CSong
PlayRound6CSong:
	lea	Round6CSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Wacky Workbench Bad Future music
; ------------------------------------------------------------------------------

	xdef PlayRound6DSong
PlayRound6DSong:
	lea	Round6DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Stardust Speedway Present music
; ------------------------------------------------------------------------------

	xdef PlayRound7ASong
PlayRound7ASong:
	lea	Round7ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Stardust Speedway Good Future music
; ------------------------------------------------------------------------------

	xdef PlayRound7CSong
PlayRound7CSong:
	lea	Round7CSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Stardust Speedway Bad Future music
; ------------------------------------------------------------------------------

	xdef PlayRound7DSong
PlayRound7DSong:
	lea	Round7DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Metallic Madness Present music
; ------------------------------------------------------------------------------

	xdef PlayRound8ASong
PlayRound8ASong:
	lea	Round8ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Metallic Madness Good Future music
; ------------------------------------------------------------------------------

	xdef PlayRound8CSong
PlayRound8CSong:
	lea	Round8CSong(pc),a0				; Play music

; ------------------------------------------------------------------------------
; Loop CD audio
; ------------------------------------------------------------------------------
; PARAMETERS
;	a0.l - Pointer to music ID
; ------------------------------------------------------------------------------

	xdef LoopCdda
LoopCdda:
	bsr.w	ResetCddaVolume					; Reset CD audio volume
	move.w	#MSCPLAYR,d0					; Play track on loop
	jsr	_CDBIOS
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Metallic Madness Bad Future music
; ------------------------------------------------------------------------------

	xdef PlayRound8DSong
PlayRound8DSong:
	lea	Round8DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play boss music
; ------------------------------------------------------------------------------

	xdef PlayBossSong
PlayBossSong:
	lea	BossSong(pc),a0					; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play final boss music
; ------------------------------------------------------------------------------

	xdef PlayFinalBossSong
PlayFinalBossSong:
	lea	FinalBossSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play time attack menu music
; ------------------------------------------------------------------------------

	xdef PlayTimeAttackSong
PlayTimeAttackSong:
	lea	TimeAttackSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play special stage music
; ------------------------------------------------------------------------------

	xdef PlaySpecialStageSong
PlaySpecialStageSong:
	lea	SpecialStageSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play D.A. Garden music
; ------------------------------------------------------------------------------

	xdef PlayDaGardenSong
PlayDaGardenSong:
	lea	DaGardenSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play prototype time warp sound
; ------------------------------------------------------------------------------

	xdef PlayProtoWarpSound
PlayProtoWarpSound:
	lea	ProtoWarpSound(pc),a0				; Play sound
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play opening music
; ------------------------------------------------------------------------------

	xdef PlayOpeningSong
PlayOpeningSong:
	lea	OpeningSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play ending music
; ------------------------------------------------------------------------------

	xdef PlayEndingSong
PlayEndingSong:
	lea	EndingSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play title screen music
; ------------------------------------------------------------------------------

	xdef PlayTitleSong
PlayTitleSong:
	lea	TitleScreenSong(pc),a0				; Play music
	bra.s	PlayCdda

; ------------------------------------------------------------------------------
; Play results music
; ------------------------------------------------------------------------------

	xdef PlayResultsSong
PlayResultsSong:
	lea	ResultsSong(pc),a0				; Play music
	bra.s	PlayCdda

; ------------------------------------------------------------------------------
; Play speed shoes music
; ------------------------------------------------------------------------------

	xdef PlaySpeedShoesSong
PlaySpeedShoesSong:
	lea	SpeedShoesSong(pc),a0				; Play music
	bra.s	PlayCdda

; ------------------------------------------------------------------------------
; Play invincibility music
; ------------------------------------------------------------------------------

	xdef PlayInvincibleSong
PlayInvincibleSong:
	lea	InvincibleSong(pc),a0				; Play music
	bra.s	PlayCdda

; ------------------------------------------------------------------------------
; Play game over music
; ------------------------------------------------------------------------------

	xdef PlayGameOverSong
PlayGameOverSong:
	lea	GameOverSong(pc),a0				; Play music

; ------------------------------------------------------------------------------
; Play CD audio
; ------------------------------------------------------------------------------
; PARAMETERS
;	a0.l - Pointer to music ID
; ------------------------------------------------------------------------------

	xdef PlayCdda
PlayCdda:
	bsr.w	ResetCddaVolume					; Reset CD audio volume
	move.w	#MSCPLAY1,d0					; Play track once
	jsr	_CDBIOS
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Palmtree Panic Present music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound1ASong
TestRound1ASong:
	lea	Round1ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Palmtree Panic Good Future music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound1CSong
TestRound1CSong:
	lea	Round1CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Palmtree Panic Bad Future music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound1DSong
TestRound1DSong:
	lea	Round1DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Collision Chaos Present music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound3ASong
TestRound3ASong:
	lea	Round3ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Collision Chaos Good Future music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound3CSong
TestRound3CSong:
	lea	Round3CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Collision Chaos Bad Future music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound3DSong
TestRound3DSong:
	lea	Round3DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Tidal Tempest Present music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound4ASong
TestRound4ASong:
	lea	Round4ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Tidal Tempest Good Future music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound4CSong
TestRound4CSong:
	lea	Round4CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Tidal Tempest Bad Future music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound4DSong
TestRound4DSong:
	lea	Round4DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Quartz Quadrant Present music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound5ASong
TestRound5ASong:
	lea	Round5ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Quartz Quadrant Good Future music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound5CSong
TestRound5CSong:
	lea	Round5CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Quartz Quadrant Bad Future music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound5DSong
TestRound5DSong:
	lea	Round5DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Wacky Workbench Present music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound6ASong
TestRound6ASong:
	lea	Round6ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Wacky Workbench Good Future music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound6CSong
TestRound6CSong:
	lea	Round6CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Wacky Workbench Bad Future music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound6DSong
TestRound6DSong:
	lea	Round6DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Stardust Speedway Present music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound7ASong
TestRound7ASong:
	lea	Round7ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Stardust Speedway Good Future music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound7CSong
TestRound7CSong:
	lea	Round7CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Stardust Speedway Bad Future music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound7DSong
TestRound7DSong:
	lea	Round7DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Metallic Madness Present music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound8ASong
TestRound8ASong:
	lea	Round8ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Metallic Madness Good Future music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound8CSong
TestRound8CSong:
	lea	Round8CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Metallic Madness Bad Future music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound8DSong
TestRound8DSong:
	lea	Round8DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play boss music (sound test)
; ------------------------------------------------------------------------------

	xdef TestBossSong
TestBossSong:
	lea	BossSong(pc),a0					; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play final boss music (sound test)
; ------------------------------------------------------------------------------

	xdef TestFinalSong
TestFinalSong:
	lea	FinalBossSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play title screen music (sound test)
; ------------------------------------------------------------------------------

	xdef TestTitleSong
TestTitleSong:
	lea	TitleScreenSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play time attack menu music (sound test)
; ------------------------------------------------------------------------------

	xdef TestTimeAttackSong
TestTimeAttackSong:
	lea	TimeAttackSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play results music (sound test)
; ------------------------------------------------------------------------------

	xdef TestResultsSong
TestResultsSong:
	lea	ResultsSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play speed shoes music (sound test)
; ------------------------------------------------------------------------------

	xdef TestSpeedShoesSong
TestSpeedShoesSong:
	lea	SpeedShoesSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play invincibility music (sound test)
; ------------------------------------------------------------------------------

	xdef TestInvincibleSong
TestInvincibleSong:
	lea	InvincibleSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play game over music (sound test)
; ------------------------------------------------------------------------------

	xdef TestGameOverSong
TestGameOverSong:
	lea	GameOverSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play special stage music (sound test)
; ------------------------------------------------------------------------------

	xdef TestSpecialStageSong
TestSpecialStageSong:
	lea	SpecialStageSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play D.A. Garden music (sound test)
; ------------------------------------------------------------------------------

	xdef TestDaGardenSong
TestDaGardenSong:
	lea	DaGardenSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play prototype warp sound (sound test)
; ------------------------------------------------------------------------------

	xdef TestProtoWarpSound
TestProtoWarpSound:
	lea	ProtoWarpSound(pc),a0				; Play sound
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play opening music (sound test)
; ------------------------------------------------------------------------------

	xdef TestOpeningSong
TestOpeningSong:
	lea	OpeningSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play ending music (sound test)
; ------------------------------------------------------------------------------

	xdef TestEndingSong
TestEndingSong:
	lea	EndingSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play "Future" voice clip (sound test)
; ------------------------------------------------------------------------------

	xdef TestFutureVoiceSfx
TestFutureVoiceSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_FUTURE,PcmSoundQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Past" voice clip (sound test)
; ------------------------------------------------------------------------------

	xdef TestPastVoiceSfx
TestPastVoiceSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_PAST,PcmSoundQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Alright" voice clip (sound test)
; ------------------------------------------------------------------------------

	xdef TestAlrightSfx
TestAlrightSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_ALRIGHT,PcmSoundQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "I'm outta here" voice clip (sound test)
; ------------------------------------------------------------------------------

	xdef TestOuttaHereSfx
TestOuttaHereSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_OUTTA_HERE,PcmSoundQueue		; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Yes" voice clip (sound test)
; ------------------------------------------------------------------------------

	xdef TestYesSfx
TestYesSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_YES,PcmSoundQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Yeah" voice clip (sound test)
; ------------------------------------------------------------------------------

	xdef TestYeahSfx
TestYeahSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_YEAH,PcmSoundQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Amy giggle voice clip (sound test)
; ------------------------------------------------------------------------------

	xdef TestAmyGiggleSfx
TestAmyGiggleSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_AMY_GIGGLE,PcmSoundQueue		; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Amy yelp voice clip (sound test)
; ------------------------------------------------------------------------------

	xdef TestAmyYelpSfx
TestAmyYelpSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_AMY_YELP,PcmSoundQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play mech stomp sound (sound test)
; ------------------------------------------------------------------------------

	xdef TestStompSfx
TestStompSfx:
	lea	PcmDriverR3BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_STOMP,PcmSoundQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play bumper sound (sound test)
; ------------------------------------------------------------------------------

	xdef TestBumperSfx
TestBumperSfx:
	lea	PcmDriverR3BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_BUMPER,PcmSoundQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Palmtree Panic past music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound1BSong
TestRound1BSong:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SONG_PAST,PcmSoundQueue			; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Collision Chaos past music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound3BSong
TestRound3BSong:
	lea	PcmDriverR3BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SONG_PAST,PcmSoundQueue			; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Tidal Tempest past music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound4BSong
TestRound4BSong:
	lea	PcmDriverR4BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SONG_PAST,PcmSoundQueue			; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Quartz Quadrant past music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound5BSong
TestRound5BSong:
	lea	PcmDriverR5BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SONG_PAST,PcmSoundQueue			; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Wacky Workbench past music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound6BSong
TestRound6BSong:
	lea	PcmDriverR6BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SONG_PAST,PcmSoundQueue			; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Stardust Speedway past music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound7BSong
TestRound7BSong:
	lea	PcmDriverR7BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SONG_PAST,PcmSoundQueue			; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Metallic Madness past music (sound test)
; ------------------------------------------------------------------------------

	xdef TestRound8BSong
TestRound8BSong:
	lea	PcmDriverR8BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SONG_PAST,PcmSoundQueue			; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Load PCM driver for sound test
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to file name
; ------------------------------------------------------------------------------

LoadPcmDriver:
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	move.l	cur_pcm_driver,d0				; Is this driver already loaded?
	move.l	a0,cur_pcm_driver
	cmp.l	a0,d0
	beq.s	.End						; If so, branch
	
	lea	PcmDriver,a1					; Load driver
	jsr	LoadFile

.End:
	bset	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Enable timer interrupt
	rts

; ------------------------------------------------------------------------------
