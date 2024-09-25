; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; System definitions
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; File IDs
; ------------------------------------------------------------------------------

	rsreset
FID_R11A		rs.b 1				; Palmtree Panic Act 1 Present
FID_R11B		rs.b 1				; Palmtree Panic Act 1 Past
FID_R11C		rs.b 1				; Palmtree Panic Act 1 Good Future
FID_R11D		rs.b 1				; Palmtree Panic Act 1 Bad Future
FID_MDINIT		rs.b 1				; Mega Drive initialization
FID_SNDTEST		rs.b 1				; Sound test
FID_STAGESEL		rs.b 1				; Stage select
FID_R12A		rs.b 1				; Palmtree Panic Act 2 Present
FID_R12B		rs.b 1				; Palmtree Panic Act 2 Past
FID_R12C		rs.b 1				; Palmtree Panic Act 2 Good Future
FID_R12D		rs.b 1				; Palmtree Panic Act 2 Bad Future
FID_TITLEMAIN		rs.b 1				; Title screen (Main CPU)
FID_TITLESUB		rs.b 1				; Title screen (Sub CPU)
FID_WARP		rs.b 1				; Warp sequence
FID_TIMEATKMAIN		rs.b 1				; Time attack menu (Main CPU)
FID_TIMEATKSUB		rs.b 1				; Time attack menu (Sub CPU)
FID_IPX			rs.b 1				; Main program
FID_PENCILSTM		rs.b 1				; Pencil test FMV data
FID_OPENSTM		rs.b 1				; Opening FMV data
FID_BADENDSTM		rs.b 1				; Bad ending FMV data
FID_GOODENDSTM		rs.b 1				; Good ending FMV data
FID_OPENMAIN		rs.b 1				; Opening FMV (Main CPU)
FID_OPENSUB		rs.b 1				; Opening FMV (Sub CPU)
FID_COMINSOON		rs.b 1				; "Comin' Soon" screen
FID_DAGARDMAIN		rs.b 1				; D.A. Garden (Main CPU)
FID_DAGARDSUB		rs.b 1				; D.A. Garden (Sub CPU)
FID_R31A		rs.b 1				; Collision Chaos Act 1 Present
FID_R31B		rs.b 1				; Collision Chaos Act 1 Past
FID_R31C		rs.b 1				; Collision Chaos Act 1 Good Future
FID_R31D		rs.b 1				; Collision Chaos Act 1 Bad Future
FID_R32A		rs.b 1				; Collision Chaos Act 2 Present 
FID_R32B		rs.b 1				; Collision Chaos Act 2 Past 
FID_R32C		rs.b 1				; Collision Chaos Act 2 Good Future 
FID_R32D		rs.b 1				; Collision Chaos Act 2 Bad Future 
FID_R33C		rs.b 1				; Collision Chaos Act 3 Good Future 
FID_R33D		rs.b 1				; Collision Chaos Act 3 Bad Future 
FID_R13C		rs.b 1				; Palmtree Panic Act 3 Good Future
FID_R13D		rs.b 1				; Palmtree Panic Act 3 Bad Future 
FID_R41A		rs.b 1				; Tidal Tempest Act 1 Present
FID_R41B		rs.b 1				; Tidal Tempest Act 1 Past
FID_R41C		rs.b 1				; Tidal Tempest Act 1 Good Future
FID_R41D		rs.b 1				; Tidal Tempest Act 1 Bad Future
FID_R42A		rs.b 1				; Tidal Tempest Act 2 Present 
FID_R42B		rs.b 1				; Tidal Tempest Act 2 Past 
FID_R42C		rs.b 1				; Tidal Tempest Act 2 Good Future 
FID_R42D		rs.b 1				; Tidal Tempest Act 2 Bad Future 
FID_R43C		rs.b 1				; Tidal Tempest Act 3 Good Future 
FID_R43D		rs.b 1				; Tidal Tempest Act 3 Bad Future 
FID_R51A		rs.b 1				; Quartz Quadrant Act 1 Present
FID_R51B		rs.b 1				; Quartz Quadrant Act 1 Past
FID_R51C		rs.b 1				; Quartz Quadrant Act 1 Good Future
FID_R51D		rs.b 1				; Quartz Quadrant Act 1 Bad Future
FID_R52A		rs.b 1				; Quartz Quadrant Act 2 Present 
FID_R52B		rs.b 1				; Quartz Quadrant Act 2 Past 
FID_R52C		rs.b 1				; Quartz Quadrant Act 2 Good Future 
FID_R52D		rs.b 1				; Quartz Quadrant Act 2 Bad Future 
FID_R53C		rs.b 1				; Quartz Quadrant Act 3 Good Future 
FID_R53D		rs.b 1				; Quartz Quadrant Act 3 Bad Future 
FID_R61A		rs.b 1				; Wacky Workbench Act 1 Present
FID_R61B		rs.b 1				; Wacky Workbench Act 1 Past
FID_R61C		rs.b 1				; Wacky Workbench Act 1 Good Future
FID_R61D		rs.b 1				; Wacky Workbench Act 1 Bad Future
FID_R62A		rs.b 1				; Wacky Workbench Act 2 Present 
FID_R62B		rs.b 1				; Wacky Workbench Act 2 Past 
FID_R62C		rs.b 1				; Wacky Workbench Act 2 Good Future 
FID_R62D		rs.b 1				; Wacky Workbench Act 2 Bad Future 
FID_R63C		rs.b 1				; Wacky Workbench Act 3 Good Future 
FID_R63D		rs.b 1				; Wacky Workbench Act 3 Bad Future 
FID_R71A		rs.b 1				; Stardust Speedway Act 1 Present
FID_R71B		rs.b 1				; Stardust Speedway Act 1 Past
FID_R71C		rs.b 1				; Stardust Speedway Act 1 Good Future
FID_R71D		rs.b 1				; Stardust Speedway Act 1 Bad Future
FID_R72A		rs.b 1				; Stardust Speedway Act 2 Present 
FID_R72B		rs.b 1				; Stardust Speedway Act 2 Past 
FID_R72C		rs.b 1				; Stardust Speedway Act 2 Good Future 
FID_R72D		rs.b 1				; Stardust Speedway Act 2 Bad Future 
FID_R73C		rs.b 1				; Stardust Speedway Act 3 Good Future 
FID_R73D		rs.b 1				; Stardust Speedway Act 3 Bad Future 
FID_R81A		rs.b 1				; Metallic Madness Act 1 Present
FID_R81B		rs.b 1				; Metallic Madness Act 1 Past
FID_R81C		rs.b 1				; Metallic Madness Act 1 Good Future
FID_R81D		rs.b 1				; Metallic Madness Act 1 Bad Future
FID_R82A		rs.b 1				; Metallic Madness Act 2 Present 
FID_R82B		rs.b 1				; Metallic Madness Act 2 Past 
FID_R82C		rs.b 1				; Metallic Madness Act 2 Good Future 
FID_R82D		rs.b 1				; Metallic Madness Act 2 Bad Future 
FID_R83C		rs.b 1				; Metallic Madness Act 3 Good Future 
FID_R83D		rs.b 1				; Metallic Madness Act 3 Bad Future 
FID_SPECMAIN		rs.b 1				; Special Stage (Main CPU)
FID_SPECSUB		rs.b 1				; Special Stage (Sub CPU)
FID_R1PCM		rs.b 1				; PCM driver (Palmtree Panic)
FID_R3PCM		rs.b 1				; PCM driver (Collision Chaos)
FID_R4PCM		rs.b 1				; PCM driver (Tidal Tempest)
FID_R5PCM		rs.b 1				; PCM driver (Quartz Quadrant)
FID_R6PCM		rs.b 1				; PCM driver (Wacky Workbench)
FID_R7PCM		rs.b 1				; PCM driver (Stardust Speedway)
FID_R8PCM		rs.b 1				; PCM driver (Metallic Madness)
FID_BOSSPCM		rs.b 1				; PCM driver (Boss)
FID_FINALPCM		rs.b 1				; PCM driver (Final boss)
FID_DAGARDDATA		rs.b 1				; D.A. Garden data
FID_R11ADEMO		rs.b 1				; Palmtree Panic Act 1 Good Future demo
FID_VISMODE		rs.b 1				; Visual Mode
FID_BURAMINIT		rs.b 1				; Backup RAM initialization
FID_BURAMSUB		rs.b 1				; Backup RAM functions
FID_BURAMMAIN		rs.b 1				; Backup RAM manager
FID_THANKSMAIN		rs.b 1				; "Thank You" screen (Main CPU)
FID_THANKSSUB		rs.b 1				; "Thank You" screen (Sub CPU)
FID_THANKSDATA		rs.b 1				; "Thank You" screen  data
FID_ENDMAIN		rs.b 1				; Ending FMV (Main CPU)
FID_BADENDSUB		rs.b 1				; Bad ending FMV (Sub CPU, not a typo)
FID_GOODENDSUB		rs.b 1				; Good ending FMV (Sub CPU, not a typo)
FID_FUNISINF		rs.b 1				; "Fun is infinite" screen
FID_SS8CREDS		rs.b 1				; Special stage 8 credits
FID_MCSONIC		rs.b 1				; M.C. Sonic screen
FID_TAILS		rs.b 1				; Tails screen
FID_BATMAN		rs.b 1				; Batman Sonic screen
FID_CUTESONIC		rs.b 1				; Cute Sonic screen
FID_STAFFTIMES		rs.b 1				; Best staff times screen
FID_DUMMY5		rs.b 1				; Copy of sound test (Unused)
FID_DUMMY6		rs.b 1				; Copy of sound test (Unused)
FID_DUMMY7		rs.b 1				; Copy of sound test (Unused)
FID_DUMMY8		rs.b 1				; Copy of sound test (Unused)
FID_DUMMY9		rs.b 1				; Copy of sound test (Unused)
FID_PENCILMAIN		rs.b 1				; Pencil test FMV (Main CPU)
FID_PENCILSUB		rs.b 1				; Pencil test FMV (Sub CPU)
FID_R43CDEMO		rs.b 1				; Tidal Tempest Act 3 Good Future demo
FID_R82ADEMO		rs.b 1				; Metallic Madness Act 2 Present demo

; ------------------------------------------------------------------------------
; Sub CPU commands
; ------------------------------------------------------------------------------

	rsset 1
SCMD_R11A		rs.b 1				; Load Palmtree Panic Act 1 Present
SCMD_R11B		rs.b 1				; Load Palmtree Panic Act 1 Past
SCMD_R11C		rs.b 1				; Load Palmtree Panic Act 1 Good Future
SCMD_R11D		rs.b 1				; Load Palmtree Panic Act 1 Bad Future
SCMD_MDINIT		rs.b 1				; Load Mega Drive initialization
SCMD_STAGESEL		rs.b 1				; Load stage select
SCMD_R12A		rs.b 1				; Load Palmtree Panic Act 2 Present
SCMD_R12B		rs.b 1				; Load Palmtree Panic Act 2 Past
SCMD_R12C		rs.b 1				; Load Palmtree Panic Act 2 Good Future
SCMD_R12D		rs.b 1				; Load Palmtree Panic Act 2 Bad Future
SCMD_TITLE		rs.b 1				; Load title screen
SCMD_WARP		rs.b 1				; Load warp sequence
SCMD_TIMEATK		rs.b 1				; Load time attack menu
SCMD_FADECDA		rs.b 1				; Fade out CDDA music
SCMD_R1AMUS		rs.b 1				; Play Palmtree Panic Present music
SCMD_R1CMUS		rs.b 1				; Play Palmtree Panic Good Future music
SCMD_R1DMUS		rs.b 1				; Play Palmtree Panic Bad Future music
SCMD_R3AMUS		rs.b 1				; Play Collision Chaos Present music
SCMD_R3CMUS		rs.b 1				; Play Collision Chaos Good Future music
SCMD_R3DMUS		rs.b 1				; Play Collision Chaos Bad Future music
SCMD_R4AMUS		rs.b 1				; Play Tidal Tempest Present music
SCMD_R4CMUS		rs.b 1				; Play Tidal Tempest Good Future music
SCMD_R4DMUS		rs.b 1				; Play Tidal Tempest Bad Future music
SCMD_R5AMUS		rs.b 1				; Play Quartz Quadrant Present music
SCMD_R5CMUS		rs.b 1				; Play Quartz Quadrant Good Future music
SCMD_R5DMUS		rs.b 1				; Play Quartz Quadrant Bad Future music
SCMD_R6AMUS		rs.b 1				; Play Wacky Workbench Present music
SCMD_R6CMUS		rs.b 1				; Play Wacky Workbench Good Future music
SCMD_R6DMUS		rs.b 1				; Play Wacky Workbench Bad Future music
SCMD_R7AMUS		rs.b 1				; Play Stardust Speedway Present music
SCMD_R7CMUS		rs.b 1				; Play Stardust Speedway Good Future music
SCMD_R7DMUS		rs.b 1				; Play Stardust Speedway Bad Future music
SCMD_R8AMUS		rs.b 1				; Play Metallic Madness Present music
SCMD_R8CMUS		rs.b 1				; Play Metallic Madness Good Future music
SCMD_IPX		rs.b 1				; Load main program
SCMD_R43CDEMO		rs.b 1				; Load Tidal Tempest Act 3 Good Future demo
SCMD_R82ADEMO		rs.b 1				; Load Metallic Madness Act 2 Present demo
SCMD_SNDTEST		rs.b 1				; Load sound test
			rs.b 1				; Invalid
SCMD_R31A		rs.b 1				; Load Collision Chaos Act 1 Present
SCMD_R31B		rs.b 1				; Load Collision Chaos Act 1 Past
SCMD_R31C		rs.b 1				; Load Collision Chaos Act 1 Good Future
SCMD_R31D		rs.b 1				; Load Collision Chaos Act 1 Bad Future
SCMD_R32A		rs.b 1				; Load Collision Chaos Act 2 Present 
SCMD_R32B		rs.b 1				; Load Collision Chaos Act 2 Past 
SCMD_R32C		rs.b 1				; Load Collision Chaos Act 2 Good Future 
SCMD_R32D		rs.b 1				; Load Collision Chaos Act 2 Bad Future 
SCMD_R33C		rs.b 1				; Load Collision Chaos Act 3 Good Future 
SCMD_R33D		rs.b 1				; Load Collision Chaos Act 3 Bad Future 
SCMD_R13C		rs.b 1				; Load Palmtree Panic Act 3 Good Future
SCMD_R13D		rs.b 1				; Load Palmtree Panic Act 3 Bad Future 
SCMD_R41A		rs.b 1				; Load Tidal Tempest Act 1 Present
SCMD_R41B		rs.b 1				; Load Tidal Tempest Act 1 Past
SCMD_R41C		rs.b 1				; Load Tidal Tempest Act 1 Good Future
SCMD_R41D		rs.b 1				; Load Tidal Tempest Act 1 Bad Future
SCMD_R42A		rs.b 1				; Load Tidal Tempest Act 2 Present 
SCMD_R42B		rs.b 1				; Load Tidal Tempest Act 2 Past 
SCMD_R42C		rs.b 1				; Load Tidal Tempest Act 2 Good Future 
SCMD_R42D		rs.b 1				; Load Tidal Tempest Act 2 Bad Future 
SCMD_R43C		rs.b 1				; Load Tidal Tempest Act 3 Good Future 
SCMD_R43D		rs.b 1				; Load Tidal Tempest Act 3 Bad Future 
SCMD_R51A		rs.b 1				; Load Quartz Quadrant Act 1 Present
SCMD_R51B		rs.b 1				; Load Quartz Quadrant Act 1 Past
SCMD_R51C		rs.b 1				; Load Quartz Quadrant Act 1 Good Future
SCMD_R51D		rs.b 1				; Load Quartz Quadrant Act 1 Bad Future
SCMD_R52A		rs.b 1				; Load Quartz Quadrant Act 2 Present 
SCMD_R52B		rs.b 1				; Load Quartz Quadrant Act 2 Past 
SCMD_R52C		rs.b 1				; Load Quartz Quadrant Act 2 Good Future 
SCMD_R52D		rs.b 1				; Load Quartz Quadrant Act 2 Bad Future 
SCMD_R53C		rs.b 1				; Load Quartz Quadrant Act 3 Good Future 
SCMD_R53D		rs.b 1				; Load Quartz Quadrant Act 3 Bad Future 
SCMD_R61A		rs.b 1				; Load Wacky Workbench Act 1 Present
SCMD_R61B		rs.b 1				; Load Wacky Workbench Act 1 Past
SCMD_R61C		rs.b 1				; Load Wacky Workbench Act 1 Good Future
SCMD_R61D		rs.b 1				; Load Wacky Workbench Act 1 Bad Future
SCMD_R62A		rs.b 1				; Load Wacky Workbench Act 2 Present 
SCMD_R62B		rs.b 1				; Load Wacky Workbench Act 2 Past 
SCMD_R62C		rs.b 1				; Load Wacky Workbench Act 2 Good Future 
SCMD_R62D		rs.b 1				; Load Wacky Workbench Act 2 Bad Future 
SCMD_R63C		rs.b 1				; Load Wacky Workbench Act 3 Good Future 
SCMD_R63D		rs.b 1				; Load Wacky Workbench Act 3 Bad Future 
SCMD_R71A		rs.b 1				; Load Stardust Speedway Act 1 Present
SCMD_R71B		rs.b 1				; Load Stardust Speedway Act 1 Past
SCMD_R71C		rs.b 1				; Load Stardust Speedway Act 1 Good Future
SCMD_R71D		rs.b 1				; Load Stardust Speedway Act 1 Bad Future
SCMD_R72A		rs.b 1				; Load Stardust Speedway Act 2 Present 
SCMD_R72B		rs.b 1				; Load Stardust Speedway Act 2 Past 
SCMD_R72C		rs.b 1				; Load Stardust Speedway Act 2 Good Future 
SCMD_R72D		rs.b 1				; Load Stardust Speedway Act 2 Bad Future 
SCMD_R73C		rs.b 1				; Load Stardust Speedway Act 3 Good Future 
SCMD_R73D		rs.b 1				; Load Stardust Speedway Act 3 Bad Future 
SCMD_R81A		rs.b 1				; Load Metallic Madness Act 1 Present
SCMD_R81B		rs.b 1				; Load Metallic Madness Act 1 Past
SCMD_R81C		rs.b 1				; Load Metallic Madness Act 1 Good Future
SCMD_R81D		rs.b 1				; Load Metallic Madness Act 1 Bad Future
SCMD_R82A		rs.b 1				; Load Metallic Madness Act 2 Present 
SCMD_R82B		rs.b 1				; Load Metallic Madness Act 2 Past 
SCMD_R82C		rs.b 1				; Load Metallic Madness Act 2 Good Future 
SCMD_R82D		rs.b 1				; Load Metallic Madness Act 2 Bad Future 
SCMD_R83C		rs.b 1				; Load Metallic Madness Act 3 Good Future 
SCMD_R83D		rs.b 1				; Load Metallic Madness Act 3 Bad Future 
SCMD_R8DMUS		rs.b 1				; Play Metallic Madness Bad Future music
SCMD_BOSSMUS		rs.b 1				; Play boss music
SCMD_FINALMUS		rs.b 1				; Play final boss music
SCMD_TITLEMUS		rs.b 1				; Play title screen music
SCMD_TMATKMUS		rs.b 1				; Play time attack menu music
SCMD_RESULTMUS		rs.b 1				; Play results music
SCMD_SHOESMUS		rs.b 1				; Play speed shoes music
SCMD_INVINCMUS		rs.b 1				; Play invincibility music
SCMD_GMOVERMUS		rs.b 1				; Play game over music
SCMD_SPECMUS		rs.b 1				; Play special stage music
SCMD_DAGRDNMUS		rs.b 1				; Play D.A. Garden music
SCMD_PROTOWARP		rs.b 1				; Play prototype warp sound
SCMD_INTROMUS		rs.b 1				; Play opening music
SCMD_ENDINGMUS		rs.b 1				; Play ending music
SCMD_STOPCDDA		rs.b 1				; Stop CDDA music
SCMD_SPECSTAGE		rs.b 1				; Load special stage
SCMD_FUTURESFX		rs.b 1				; Play "Future" voice clip
SCMD_PASTSFX		rs.b 1				; Play "Past" voice clip
SCMD_ALRIGHTSFX		rs.b 1				; Play "Alright" voice clip
SCMD_GIVEUPSFX		rs.b 1				; Play "I'm outta here" voice clip
SCMD_YESSFX		rs.b 1				; Play "Yes" voice clip
SCMD_YEAHSFX		rs.b 1				; Play "Yeah" voice clip
SCMD_GIGGLESFX		rs.b 1				; Play Amy giggle voice clip
SCMD_YELPSFX		rs.b 1				; Play Amy yelp voice clip
SCMD_STOMPSFX		rs.b 1				; Play mech stomp sound
SCMD_BUMPERSFX		rs.b 1				; Play bumper sound
SCMD_PASTMUS		rs.b 1				; Play Past music
SCMD_DAGARDEN		rs.b 1				; Load D.A. Garden
SCMD_FADEPCM		rs.b 1				; Fade out PCM
SCMD_STOPPCM		rs.b 1				; Stop PCM
SCMD_R11ADEMO		rs.b 1				; Load Palmtree Panic Act 1 Present demo
SCMD_VISMODE		rs.b 1				; Load Visual Mode menu
SCMD_INITSS2		rs.b 1				; Reset special stage flags
SCMD_READSAVE		rs.b 1				; Read save data
SCMD_WRITESAVE		rs.b 1				; Write save data
SCMD_BURAMINIT		rs.b 1				; Load Backup RAM initialization
SCMD_INITSS		rs.b 1				; Reset special stage flags
SCMD_RDTEMPSAVE		rs.b 1				; Read temporary save data
SCMD_WRTEMPSAVE		rs.b 1				; Write temporary save data
SCMD_THANKYOU		rs.b 1				; Load "Thank You" screen
SCMD_BURAMMGR		rs.b 1				; Load Backup RAM manager
SCMD_RESETVOL		rs.b 1				; Reset CDDA music volume
SCMD_PAUSEPCM		rs.b 1				; Pause PCM
SCMD_UNPAUSEPCM		rs.b 1				; Unpause PCM
SCMD_BREAKSFX		rs.b 1				; Play glass break sound
SCMD_BADEND		rs.b 1				; Load bad ending FMV
SCMD_GOODEND		rs.b 1				; Load good ending FMV
SCMD_R1AMUST		rs.b 1				; Play Palmtree Panic Present music (sound test)
SCMD_R1CMUST		rs.b 1				; Play Palmtree Panic Good Future music (sound test)
SCMD_R1DMUST		rs.b 1				; Play Palmtree Panic Bad Future music (sound test)
SCMD_R3AMUST		rs.b 1				; Play Collision Chaos Present music (sound test)
SCMD_R3CMUST		rs.b 1				; Play Collision Chaos Good Future music (sound test)
SCMD_R3DMUST		rs.b 1				; Play Collision Chaos Bad Future music (sound test)
SCMD_R4AMUST		rs.b 1				; Play Tidal Tempest Present music (sound test)
SCMD_R4CMUST		rs.b 1				; Play Tidal Tempest Good Future music (sound test)
SCMD_R4DMUST		rs.b 1				; Play Tidal Tempest Bad Future music (sound test)
SCMD_R5AMUST		rs.b 1				; Play Quartz Quadrant Present music (sound test)
SCMD_R5CMUST		rs.b 1				; Play Quartz Quadrant Good Future music (sound test)
SCMD_R5DMUST		rs.b 1				; Play Quartz Quadrant Bad Future music (sound test)
SCMD_R6AMUST		rs.b 1				; Play Wacky Workbench Present music (sound test)
SCMD_R6CMUST		rs.b 1				; Play Wacky Workbench Good Future music (sound test)
SCMD_R6DMUST		rs.b 1				; Play Wacky Workbench Bad Future music (sound test)
SCMD_R7AMUST		rs.b 1				; Play Stardust Speedway Present music (sound test)
SCMD_R7CMUST		rs.b 1				; Play Stardust Speedway Good Future music (sound test)
SCMD_R7DMUST		rs.b 1				; Play Stardust Speedway Bad Future music (sound test)
SCMD_R8AMUST		rs.b 1				; Play Metallic Madness Present music (sound test)
SCMD_R8CMUST		rs.b 1				; Play Metallic Madness Good Future music (sound test)
SCMD_R8DMUST		rs.b 1				; Play Metallic Madness Bad Future music (sound test)
SCMD_BOSSMUST		rs.b 1				; Play boss music (sound test)
SCMD_FINALMUST		rs.b 1				; Play final boss music (sound test)
SCMD_TITLEMUST		rs.b 1				; Play title screen music (sound test)
SCMD_TMATKMUST		rs.b 1				; Play time attack music (sound test)
SCMD_RESULTMUST		rs.b 1				; Play results music (sound test)
SCMD_SHOESMUST		rs.b 1				; Play speed shoes music (sound test)
SCMD_INVINCMUST		rs.b 1				; Play invincibility music (sound test)
SCMD_GMOVERMUST		rs.b 1				; Play game over music (sound test)
SCMD_SPECMUST		rs.b 1				; Play special stage music (sound test)
SCMD_DAGRDNMUST		rs.b 1				; Play D.A. Garden music (sound test)
SCMD_PROTOWARPT		rs.b 1				; Play prototype warp sound (sound test)
SCMD_INTROMUST		rs.b 1				; Play opening music (sound test)
SCMD_ENDINGMUST		rs.b 1				; Play ending music (sound test)
SCMD_FUTURESFXT		rs.b 1				; Play "Future" voice clip (sound test)
SCMD_PASTSFXT		rs.b 1				; Play "Past" voice clip (sound test)
SCMD_ALRGHTSFXT		rs.b 1				; Play "Alright" voice clip (sound test)
SCMD_GIVEUPSFXT		rs.b 1				; Play "I'm outta here" voice clip (sound test)
SCMD_YESSFXT		rs.b 1				; Play "Yes" voice clip (sound test)
SCMD_YEAHSFXT		rs.b 1				; Play "Yeah" voice clip (sound test)
SCMD_GIGGLESFXT		rs.b 1				; Play Amy giggle voice clip (sound test)
SCMD_YELPSFXT		rs.b 1				; Play Amy yelp voice clip (sound test)
SCMD_STOMPSFXT		rs.b 1				; Play mech stomp sound (sound test)
SCMD_BUMPERSFXT		rs.b 1				; Play bumper sound (sound test)
SCMD_R1BMUST		rs.b 1				; Play Palmtree Panic Past music (sound test)
SCMD_R3BMUST		rs.b 1				; Play Collision Chaos Past music (sound test)
SCMD_R4BMUST		rs.b 1				; Play Tidal Tempest Past music (sound test)
SCMD_R5BMUST		rs.b 1				; Play Quartz Quadrant Past music (sound test)
SCMD_R6BMUST		rs.b 1				; Play Palmtree Panic Past music (sound test)
SCMD_R7BMUST		rs.b 1				; Play Palmtree Panic Past music (sound test)
SCMD_R8BMUST		rs.b 1				; Play Palmtree Panic Past music (sound test)
SCMD_FUNISINF		rs.b 1				; Load "Fun is infinite" screen
SCMD_SS8CREDS		rs.b 1				; Load special stage 8 credits
SCMD_MCSONIC		rs.b 1				; Load M.C. Sonic screen
SCMD_TAILS		rs.b 1				; Load Tails screen
SCMD_BATMAN		rs.b 1				; Load Batman Sonic screen
SCMD_CUTESONIC		rs.b 1				; Load cute Sonic screen
SCMD_STAFFTIMES		rs.b 1				; Load best staff times screen
SCMD_DUMMY1		rs.b 1				; Load dummy file (unused)
SCMD_DUMMY2		rs.b 1				; Load dummy file (unused)
SCMD_DUMMY3		rs.b 1				; Load dummy file (unused)
SCMD_DUMMY4		rs.b 1				; Load dummy file (unused)
SCMD_DUMMY5		rs.b 1				; Load dummy file (unused)
SCMD_PENCILTEST		rs.b 1				; Load pencil test FMV
SCMD_PAUSECDA		rs.b 1				; Pause CDDA music
SCMD_UNPAUSECDA		rs.b 1				; Unpause CDDA music
SCMD_OPENING		rs.b 1				; Load opening FMV
SCMD_COMINSOON		rs.b 1				; Load "Comin' Soon" screen

; ------------------------------------------------------------------------------

	if def(SUB_CPU)

; ------------------------------------------------------------------------------
; Addresses
; ------------------------------------------------------------------------------

; System program
SpVariables		equ $7000			; Variables
SaveDataTemp		equ $7400			; Temporary save data buffer
MegaDriveIrq		equ $7700			; IRQ2 handler
LoadFile		equ $7800			; Load file
GetFileName		equ $7840			; Get file name
FileFunction		equ $7880			; File engine function handler
FileVariables		equ $8C00			; File engine variables

; System program extension
Spx			equ $B800			; SPX start location
SpxFileTable		equ SPX				; SPX file table
SpxStart		equ SPX+$800			; SPX code start
Stack			equ $10000			; Stack base

; FMV
FMV_PCM_BUFFER		equ PRG_RAM+$40000		; PCM data buffer
FMV_GFX_BUFFER		equ WORD_RAM_1M			; Graphics data buffer

; ------------------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------------------

; File engine functions
	rsreset
FILE_INIT		rs.b 1					; Initialize
FILE_OPERATION		rs.b 1					; Perform operation
FILE_STATUS		rs.b 1					; Get status
FILE_GET_FILES		rs.b 1					; Get files
FILE_LOAD_FILE		rs.b 1					; Load file
FILE_FIND_FILE		rs.b 1					; Find file
FILE_FMV		rs.b 1					; Load FMV
FILE_RESET		rs.b 1					; Reset
FILE_MUTE_FMV		rs.b 1					; Load mute FMV

; File engine operation modes
	rsreset
FILE_OPERATE_NONE	rs.b 1					; No function
FILE_OPERATE_GET_FILES	rs.b 1					; Get files
FILE_OPERATE_LOAD_FILE	rs.b 1					; Load file
FILE_OPERATE_FMV	rs.b 1					; Load FMV
FILE_OPERATE_FMV_MUTE	rs.b 1					; Load mute FMV

; File engine statuses
FILE_STATUS_OK		equ 100					; OK
FILE_STATUS_GET_FAIL	equ -1					; File get failed
FILE_STATUS_NOT_FOUND	equ -2					; File not found
FILE_STATUS_LOAD_FAIL	equ -3					; File load failed
FILE_STATUS_READ_FAIL	equ -100				; Failed
FILE_STATUS_FMV_FAIL	equ -111				; FMV load failed

; FMV data types
FMV_DATA_PCM		equ 0					; PCM data type
FMV_DATA_GFX		equ 1					; Graphics data type

; FMV flags
FMV_INIT_BIT		equ 3					; Initialized flag
FMV_INIT		equ 1<<FMV_INIT_BIT
FMV_PCM_BUFFER_ID_BIT	equ 4					; PCM buffer ID
FMV_PCM_BUFFER_ID	equ 1<<FMV_PCM_BUFFER_ID_BIT
FMV_READY_BIT		equ 5					; Ready flag
FMV_READY		equ 1<<FMV_READY_BIT
FMV_SECTION_1_BIT	equ 7					; Reading data section 1 flag
FMV_SECTION_1		equ 1<<FMV_SECTION_1_BIT

; File data
FILE_NAME_SIZE		equ 12					; File name size

; ------------------------------------------------------------------------------
; SP variables
; ------------------------------------------------------------------------------

	rsset SpVariables
curPCMDriver	rs.l	1					; Current PCM driver
ssFlagsCopy		rs.b 1					; Special stage flags copy
pcmDrvFlags		rs.b 1					; PCM driver flags
			rs.b $400-__rs
SPVARSSZ		rs.b 1					; Size of structure

; ------------------------------------------------------------------------------
; File engine variables structure
; ------------------------------------------------------------------------------

	rsreset
file.bookmark		rs.l 1					; Operation bookmark
file.sector		rs.l 1					; Sector to read from
file.sector_count	rs.l 1					; Number of sectors to read
file.return		rs.l 1					; Return address for CD read functions
file.read_buffer	rs.l 1					; Read buffer address
file.read_time		rs.b 0					; Time of read sector
file.read_minute	rs.b 1					; Read sector minute
file.read_second	rs.b 1					; Read sector second
file.read_frame		rs.b 1					; Read sector frame
			rs.b 1
file.dir_sector_count	rs.b 0					; Directory sector count
file.size		rs.l 1					; File size buffer
file.operation_mode	rs.w 1					; Operation mode
file.status		rs.w 1					; Status code
file.count		rs.w 1					; File count
file.wait_time		rs.w 1					; Wait timer
file.retries		rs.w 1					; Retry counter
file.sectors_read	rs.w 1					; Number of sectors read
file.cdc_device		rs.b 1					; CDC mode
file.sector_frame	rs.b 1					; Sector frame
file.name		rs.b FILE_NAME_SIZE			; File name buffer
			rs.b $100-__rs
file.list		rs.b $2000				; File list
file.directory		rs.b $900				; Directory read buffer
file.fmv_frame		rs.w 1					; FMV frame
file.fmv_data_type	rs.b 1					; FMV read data type
file.fmv_flags		rs.b 1					; FMV flags
file.fmv_fail_count	rs.b 1					; FMV fail counter
file.struct_size	rs.b 0					; Size of structure

; ------------------------------------------------------------------------------
; File entry structure
; ------------------------------------------------------------------------------

	rsreset
file_entry.name		rs.b FILE_NAME_SIZE			; File name
			rs.b $17-__rs
file_entry.flags	rs.b 1					; File flags
file_entry.sector	rs.l 1					; File sector
file_entry.length	rs.l 1					; File size
file_entry.struct_len	rs.b 0					; Size of structure
	endif

; ------------------------------------------------------------------------------
