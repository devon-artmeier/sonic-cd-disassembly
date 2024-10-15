; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; CDDA IDs
; ------------------------------------------------------------------------------

	rsset 2
CDDA_PROTO_WARP		rs.b 1					; Prototype warp
CDDA_ROUND_1A		rs.b 1					; Palmtree Panic present
CDDA_ROUND_1C		rs.b 1					; Palmtree Panic good future
CDDA_ROUND_1D		rs.b 1					; Palmtree Panic bad future
CDDA_ROUND_3A		rs.b 1					; Collision Chaos present
CDDA_ROUND_3C		rs.b 1					; Collision Chaos good future
CDDA_ROUND_3D		rs.b 1					; Collision Chaos bad future
CDDA_ROUND_4A		rs.b 1					; Tidal Tempest present
CDDA_ROUND_4C		rs.b 1					; Tidal Tempest good future
CDDA_ROUND_4D		rs.b 1					; Tidal Tempest bad future
CDDA_ROUND_5A		rs.b 1					; Quartz Quadrant present
CDDA_ROUND_5C		rs.b 1					; Quartz Quadrant good future
CDDA_ROUND_5D		rs.b 1					; Quartz Quadrant bad future
CDDA_ROUND_6A		rs.b 1					; Wacky Workbench present
CDDA_ROUND_6C		rs.b 1					; Wacky Workbench good future
CDDA_ROUND_6D		rs.b 1					; Wacky Workbench bad future
CDDA_ROUND_7A		rs.b 1					; Stardust Speedway present
CDDA_ROUND_7C		rs.b 1					; Stardust Speedway good future
CDDA_ROUND_7D		rs.b 1					; Stardust Speedway bad future
CDDA_ROUND_8A		rs.b 1					; Metallic Madness present
CDDA_ROUND_8C		rs.b 1					; Metallic Madness good future
CDDA_ROUND_8D		rs.b 1					; Metallic Madness bad future
CDDA_BOSS		rs.b 1					; Boss
CDDA_FINAL		rs.b 1					; Final boss
CDDA_TITLE		rs.b 1					; Title screen
CDDA_TIME_ATTACK	rs.b 1					; Time attack menu
CDDA_RESULTS		rs.b 1					; Results
CDDA_SPEED_SHOES	rs.b 1					; Speed shoes
CDDA_INVINCIBILE	rs.b 1					; Invincibility
CDDA_GAME_OVER		rs.b 1					; Game over
CDDA_SPECIAL_STAGE	rs.b 1					; Special stage
CDDA_DA_GARDEN		rs.b 1					; D.A. Garden
CDDA_OPENING		rs.b 1					; Opening
CDDA_ENDING		rs.b 1					; Ending

; ------------------------------------------------------------------------------
