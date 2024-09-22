extern tableID, addrs, tables;
extern startAddr, endAddr, addrRanges, curObjIdx, objSpawn;

extern SpecialCollision;
extern ObjectCollision;
extern ObjBigRingFlash;
extern ObjMonitor;
extern ObjTimePostTimeIcon;
extern ObjTimePost;
extern ObjTimeIcon;
extern ObjHUD;
extern ObjPoints;
extern ObjSpringUnk;
extern CheckObjDespawn2;

static CheckObjAddr(addr1, addr2)
{
	if (addr1 < startAddr) {
		startAddr = addr1;
		SetArrayLong(addrRanges, (curObjIdx * 3) + 0, startAddr);
	}
	if (addr2 > endAddr) {
		endAddr = addr2;
		SetArrayLong(addrRanges, (curObjIdx * 3) + 1, endAddr);
	}
}

static CheckObjOpObj(addr, op, opID)
{
	if (strlen(op) > 4) {
		auto opIndir = substr(op, strlen(op) - 4, strlen(op));
		if (opIndir == "(a0)") {
			OpStroff(addr, opID, objStruct);
		} else if (objSpawn != 0 && opIndir == "(a1)") {
			OpStroff(addr, opID, objStruct);
		}
	}
}

static CheckObjFunction(addr) {
	return  (addr < ObjectIndex) ||
		(addr == PlaceBlock) ||
		(addr == AddPLCs) ||
		(addr == LoadPLCs) ||
		(addr == LoadPLCsNow) ||
		(addr == NemDec) ||
		(addr == NemDecToRAM) ||
		(addr == EniDec);
}

static SetTableOffset(addr, idx)
{
	ForceWord(addr + idx);
	OpOffEx(addr + idx, 0, REF_OFF32, -1, addr, 0);
	return addr + Word(addr + idx);
}

static AnalyzeObjTable(addr, name, id)
{
	if (GetArrayElement(AR_LONG, tables, addr) != 69) {
		SetArrayLong(tables, addr, 69);
		
		auto idx = 0;
		auto done = 0;
		
		while (done == 0) {
			if (idx > 0 && Name(addr + idx) != "") {
				done = 1;
			} else if ((name == "ObjRing" && idx >= 0xA) ||
			           (name == "ObjTunnelDoorV" && idx >= 6)) {
				done = 1;
			} else {
				if (Word(addr + idx) < 0x8000) {
					auto off = SetTableOffset(addr, idx);
					if (substr(Name(off), 0, strlen(name)) != name) {
						StartFunction(off, name + "_" + sprintf("%X", id) + "_Routine" + sprintf("%X", idx));
					}
					AnalyzeObjCode(off, name);
					idx = idx + 2;
				} else {
					done = 1;
				}
			}
		}
	}
}

static AnalyzeDataTable(addr, name)
{
	auto idx = 0;
	auto done = 0;
	
	while (done == 0) {
		if (idx > 0 && Name(addr + idx) != "") {
			done = 1;
		} else {
			auto off = SetTableOffset(addr, idx);
			if (substr(Name(off), 0, strlen(name)) != name) {
				MakeName(off, name + "_" + sprintf("%X", idx));
			}
			idx = idx + 2;
		}
	}
}

static AnalyzeObjCode(addr, name)
{
	auto done = 0;
	if (addr < 0x200000 || addr >= 0x210000) {
		done = 1;
	}
	
	while (done == 0) {
		auto insLen = MakeCode(addr);
		auto ins = GetMnem(addr);
		auto op1 = GetOpnd(addr, 0);
		auto op2 = GetOpnd(addr, 1);
		auto branch;
		Wait();
		CheckObjAddr(addr, addr + insLen);
		
		SetArrayLong(addrs, addr, 69);
	
		CheckObjOpObj(addr, op1, 0);
		CheckObjOpObj(addr, op2, 1);
		
		if (ins == "bra" || ins == "jmp" || ins == "bra.s" || ins == "bra.w") {
			if (GetOpType(addr, 0) != o_displ) {
				branch = LocByName(GetOpnd(addr, 0));
				if (branch != BADADDR) {
					if (!CheckObjFunction(branch) && GetArrayElement(AR_LONG, addrs, branch) != 69) {
						addr = branch - insLen;
					} else {
						done = 1;
					}
				}
			} else {
				tableID = tableID + 1;
				AnalyzeObjTable(LocByName(GetOpnd(addr, 0)), name, tableID);
				done = 1;
			}
		} else if (ins == "rts" || ins == "rte" || ins == "rtr") {
			done = 1;
		} else  {
			// I hate this, but I'm lazy.
			auto branchType = 0;
			if (ins == "b" || ins == "bsr" || ins == "jsr" || ins == "bsr.s" || ins == "bsr.w" ||
				ins == "bcc.s" || ins == "bcs.s" || ins == "beq.s" || ins == "bge.s" ||
				ins == "bgt.s" || ins == "bhi.s" || ins == "ble.s" || ins == "bls.s" ||
				ins == "blt.s" || ins == "bmi.s" || ins == "bne.s" || ins == "bpl.s" ||
				ins == "bvc.s" || ins == "bvs.s" || ins == "bhs.s" || ins == "blo.s" ||
				ins == "bcc.w" || ins == "bcs.w" || ins == "beq.w" || ins == "bge.w" ||
				ins == "bgt.w" || ins == "bhi.w" || ins == "ble.w" || ins == "bls.w" ||
				ins == "blt.w" || ins == "bmi.w" || ins == "bne.w" || ins == "bpl.w" ||
				ins == "bvc.w" || ins == "bvs.w" || ins == "bhs.w" || ins == "blo.w") {
				branchType = 1;
			} else if (ins == "db" ||
				ins == "dbcc" || ins == "dbcs" || ins == "dbeq" || ins == "dbge" ||
				ins == "dbgt" || ins == "dbhi" || ins == "dble" || ins == "dbls" ||
				ins == "dblt" || ins == "dbmi" || ins == "dbne" || ins == "dbpl" ||
				ins == "dbvc" || ins == "dbvs" || ins == "dbf" || ins == "dbt" ||
				ins == "dbhs" || ins == "dblo" || ins == "dbra") {
				branchType = 2;
			}
			
			if (branchType > 0) {
				if (GetOpType(addr, 0) != o_displ) {
					if (branchType == 2) {
						branch = LocByName(GetOpnd(addr, 1));
					} else {
						branch = LocByName(GetOpnd(addr, 0));
					}
					if (branch != BADADDR) {
						if (!CheckObjFunction(branch) && GetArrayElement(AR_LONG, addrs, branch) != 69) {
							AnalyzeObjCode(branch, name);
						}
						if (branch == SpawnObject || branch == SpawnObjectAfter) {
							objSpawn = 1;
						}
					}
				} else {
					tableID = tableID + 1;
					AnalyzeObjTable(LocByName(GetOpnd(addr, 0)), name, tableID);
				}
			}
		}
		
		addr = addr + insLen;
	}
}

static AnalyzeObject(addr, name)
{
	tableID = -1;
	objSpawn = 0;
	
	DeleteArray(GetArrayId("addrs"));
	DeleteArray(GetArrayId("tables"));
	addrs = CreateArray("addrs");
	tables = CreateArray("tables");
	
	startAddr = addr;
	endAddr = addr;
	
	SetArrayLong(addrRanges, (curObjIdx * 3) + 0, startAddr);
	SetArrayLong(addrRanges, (curObjIdx * 3) + 1, endAddr);
	SetArrayString(addrRanges, (curObjIdx * 3) + 2, name);
	
	MakeName(addr, name);
	AnalyzeObjCode(addr, name);
	
	DeleteArray(addrs);
	DeleteArray(tables);
	
	curObjIdx = curObjIdx + 1;
	
	return addr;
}

static InitObjectDefine(void)
{
	SpecialCollision = 0;
	ObjectCollision = 0;
	ObjBigRingFlash = 0;
	ObjMonitor = 0;
	ObjTimePostTimeIcon = 0;
	ObjTimePost = 0;
	ObjTimeIcon = 0;
	ObjHUD = 0;
	ObjPoints = 0;
	ObjSpringUnk = 0;
	CheckObjDespawn2 = 0;
	
	CheckObjDespawn2 = CheckObjDespawn + 4;
	MakeName(CheckObjDespawn2, "CheckObjectDespawn2");
	
	curObjIdx = 0;
	DeleteArray(GetArrayId("addrRanges"));
	addrRanges = CreateArray("addrRanges");
}

static FinishObjectDefine(void)
{
	DeleteArray(addrRanges);
}

static AnalyzeSonic(void)
{
	auto ObjSonic_Init, ObjSonic_Main, ObjSonic_Hurt, ObjSonic_Dead, ObjSonic_Restart;
	auto ObjSonic_MdGround, ObjSonic_MdAir, ObjSonic_MdRoll, ObjSonic_MdJump;
	auto ObjSonic_TimeWarp, ObjSonic_ModeIndex, ObjSonic_MoveGround, ObjSonic_Animate;
	auto ObjSonic_MoveRoll, ObjSonic_CheckJump, PlayerAirCollision;
	
	auto indexLoc;
	indexLoc = 0x54;
	
	ObjSonic_Init = ObjSonic + indexLoc + Word(ObjSonic + indexLoc + 0);
	ObjSonic_Main = ObjSonic + indexLoc + Word(ObjSonic + indexLoc + 2);
	ObjSonic_Hurt = ObjSonic + indexLoc + Word(ObjSonic + indexLoc + 4);
	ObjSonic_Dead = ObjSonic + indexLoc + Word(ObjSonic + indexLoc + 6);
	ObjSonic_Restart = ObjSonic + indexLoc + Word(ObjSonic + indexLoc + 8);
	
	StartFuncFromOp(ObjSonic_Main, "ExtendedCamera", 0);
	StartFuncFromOp(ObjSonic_Main + 2, "MakeWaterfallSplash", 0);
	
	if (zone != 4) {
		ObjSonic_TimeWarp = StartFuncFromOp(ObjSonic_Main + 0x4A, "ObjPlayer_TimeWarp", 0);
		ObjSonic_ModeIndex = NameFromOp(ObjSonic_Main + 0x5A, "ObjPlayer_Modes", 0);
		SpecialCollision = StartFuncFromOp(ObjSonic_Main + 0x62, "SpecialCollision", 0);
		StartFuncFromOp(ObjSonic_Main + 0x68, "ObjPlayer_Draw", 0);
		StartFuncFromOp(ObjSonic_Main + 0x6A, "ObjPlayer_TrackPosition", 0);
		StartFuncFromOp(ObjSonic_Main + 0x6E, "ObjPlayer_Water", 0);
		ObjSonic_Animate = StartFuncFromOp(ObjSonic_Main + 0x90, "ObjPlayer_Animate", 0);
		ObjectCollision = StartFuncFromOp(ObjSonic_Main + 0xA2, "ObjectCollision", 0);
		StartFuncFromOp(ObjSonic_Main + 0xA8, "ObjPlayer_CheckChunk", 0);
	} else {
		ObjSonic_TimeWarp = StartFuncFromOp(ObjSonic_Main + 0x34, "ObjPlayer_TimeWarp", 0);
		ObjSonic_ModeIndex = NameFromOp(ObjSonic_Main + 0x44, "ObjPlayer_Modes", 0);
		StartFuncFromOp(ObjSonic_Main + 0x4C, "ObjPlayer_CheckBouncyFloor", 0);
		StartFuncFromOp(ObjSonic_Main + 0x50, "ObjPlayer_CheckSparks", 0);
		StartFuncFromOp(ObjSonic_Main + 0x54, "ObjPlayer_CheckElectricBeam", 0);
		StartFuncFromOp(ObjSonic_Main + 0x58, "ObjPlayer_CheckHangBar", 0);
		StartFuncFromOp(ObjSonic_Main + 0x5C, "ObjPlayer_CheckRotatingPole", 0);
		
		StartFuncFromOp(ObjSonic_Main + 0x60, "ObjPlayer_Draw", 0);
		StartFuncFromOp(ObjSonic_Main + 0x62, "ObjPlayer_TrackPosition", 0);
		ObjSonic_Animate = StartFuncFromOp(ObjSonic_Main + 0x72, "ObjPlayer_Animate", 0);
		ObjectCollision = StartFuncFromOp(ObjSonic_Main + 0x84, "ObjectCollision", 0);
		StartFuncFromOp(ObjSonic_Main + 0x8A, "ObjPlayer_CheckChunk", 0);
	}
	
	ObjSonic_MdGround = ObjSonic_ModeIndex + Word(ObjSonic_ModeIndex + 0);
	ObjSonic_MdAir = ObjSonic_ModeIndex + Word(ObjSonic_ModeIndex + 2);
	ObjSonic_MdRoll = ObjSonic_ModeIndex + Word(ObjSonic_ModeIndex + 4);
	ObjSonic_MdJump = ObjSonic_ModeIndex + Word(ObjSonic_ModeIndex + 6);

	if (zone != 4) {
		StartFuncFromOp(ObjSonic_MdGround, "ObjPlayer_CheckBoredom", 0);
		StartFuncFromOp(ObjSonic_MdGround + 0x26, "ObjPlayer_StageBoundaries", 0);
		StartFuncFromOp(ObjSonic_MdGround + 0x30, "ObjPlayer_Handle3dRamp", 0);
		ObjSonic_CheckJump = StartFuncFromOp(ObjSonic_MdGround + 0x38, "ObjPlayer_CheckJump", 0);
		StartFuncFromOp(ObjSonic_MdGround + 0x3C, "ObjPlayer_SlopeResist", 0);
		ObjSonic_MoveGround = StartFuncFromOp(ObjSonic_MdGround + 0x40, "ObjPlayer_MoveGround", 0);
		StartFuncFromOp(ObjSonic_MdGround + 0x44, "ObjPlayer_CheckRoll", 0);
		StartFuncFromOp(ObjSonic_MdGround + 0x56, "ObjPlayer_CheckFall", 0);
		
		StartFuncFromOp(ObjSonic_MdAir + 0x22, "ObjPlayer_JumpHeight", 0);
		StartFuncFromOp(ObjSonic_MdAir + 0x26, "ObjPlayer_MoveAir", 0);
		StartFuncFromOp(ObjSonic_MdAir + 0x42, "ObjPlayer_JumpAngle", 0);
		PlayerAirCollision = StartFuncFromOp(ObjSonic_MdAir + 0x46, "PlayerAirCollision", 0);
		
		StartFuncFromOp(ObjSonic_TimeWarp + 0xAC, "SaveTimeWarpData", 0);
		StartFuncFromOp(ObjSonic_TimeWarp + 0xC2, "ObjPlayer_MakeTimeWarpStars", 0);
		
		StartFuncFromOp(ObjSonic_MoveGround + 0x2B8, "ObjPlayer_StartRoll", 0);
		StartFunction(ObjSonic_MoveGround + 0x348, "ObjPlayer_CheckWallCollide");
	} else {
		StartFuncFromOp(ObjSonic_MdGround + 0x12, "ObjPlayer_CheckBoredom", 0);
		StartFuncFromOp(ObjSonic_MdGround + 0x38, "ObjPlayer_StageBoundaries", 0);
		StartFuncFromOp(ObjSonic_MdGround + 0x42, "ObjPlayer_Handle3dRamp", 0);
		ObjSonic_CheckJump = StartFuncFromOp(ObjSonic_MdGround + 0x4A, "ObjPlayer_CheckJump", 0);
		StartFuncFromOp(ObjSonic_MdGround + 0x4E, "ObjPlayer_SlopeResist", 0);
		ObjSonic_MoveGround = StartFuncFromOp(ObjSonic_MdGround + 0x52, "ObjPlayer_MoveGround", 0);
		StartFuncFromOp(ObjSonic_MdGround + 0x56, "ObjPlayer_CheckRoll", 0);
		StartFuncFromOp(ObjSonic_MdGround + 0x68, "ObjPlayer_CheckFall", 0);
		
		StartFuncFromOp(ObjSonic_MdAir + 0x1C, "ObjPlayer_HangBar", 0);
		StartFuncFromOp(ObjSonic_MdAir + 0x2A, "ObjPlayer_JumpHeight", 0);
		StartFuncFromOp(ObjSonic_MdAir + 0x2E, "ObjPlayer_MoveAir", 0);
		StartFuncFromOp(ObjSonic_MdAir + 0x4A, "ObjPlayer_JumpAngle", 0);
		PlayerAirCollision = StartFuncFromOp(ObjSonic_MdAir + 0x4E, "PlayerAirCollision", 0);
		
		StartFuncFromOp(ObjSonic_MdJump + 8, "ObjPlayer_RotatingPole", 0);
	
		StartFuncFromOp(ObjSonic_TimeWarp + 0x86, "SaveTimeWarpData", 0);
		StartFuncFromOp(ObjSonic_TimeWarp + 0x98, "ObjPlayer_MakeTimeWarpStars", 0);
		
		StartFuncFromOp(ObjSonic_MoveGround + 0x2A0, "ObjPlayer_StartRoll", 0);
		StartFunction(ObjSonic_MoveGround + 0x348, "ObjPlayer_CheckWallCollide");
	}
	
	StartFuncFromOp(ObjSonic_MdRoll + 0xC, "ObjPlayer_SlopeResistRoll", 0);
	ObjSonic_MoveRoll = StartFuncFromOp(ObjSonic_MdRoll + 0x10, "ObjPlayer_MoveRoll", 0);
	
	StartFuncFromOp(ObjSonic_MoveGround + 0x24, "ObjPlayer_MoveGroundLeft", 0);
	StartFuncFromOp(ObjSonic_MoveGround + 0x30, "ObjPlayer_MoveGroundRight", 0);
	
	StartFuncFromOp(ObjSonic_MoveRoll + 0x28, "ObjPlayer_MoveRollLeft", 0);
	StartFuncFromOp(ObjSonic_MoveRoll + 0x34, "ObjPlayer_MoveRollRight", 0);
	
	StartFuncFromOp(ObjSonic_CheckJump + 0x2E, "ObjPlayer_CheckFlipper", 0);
	StartFuncFromOp(PlayerAirCollision + 0x64, "PlayerCheckBlockDownWide", 0);
	StartFuncFromOp(PlayerAirCollision + 0xFE, "PlayerCheckBlockUpWide", 0);
	StartFuncFromOp(PlayerAirCollision + 0x18E, "GroundPlayerSteep", 0);
	StartFuncFromOp(PlayerChkBlockAbove + 0x14, "PlayerCheckBlockLeftWide", 0);
	StartFuncFromOp(PlayerChkBlockAbove + 0x24, "PlayerCheckBlockRightWide", 0);
	
	Rename("@Ani_Sonic_0", "SonAni_Walk");
	Rename("@Ani_Sonic_1", "SonAni_Run");
	Rename("@Ani_Sonic_2", "SonAni_Roll");
	Rename("@Ani_Sonic_3", "SonAni_RollFast");
	Rename("@Ani_Sonic_4", "SonAni_Push");
	Rename("@Ani_Sonic_5", "SonAni_Idle");
	Rename("@Ani_Sonic_6", "SonAni_Balance");
	Rename("@Ani_Sonic_7", "SonAni_LookUp");
	Rename("@Ani_Sonic_8", "SonAni_Duck");
	Rename("@Ani_Sonic_9", "SonAni_S1Warp1");
	Rename("@Ani_Sonic_A", "SonAni_S1Warp2");
	Rename("@Ani_Sonic_B", "SonAni_S1Warp3");
	Rename("@Ani_Sonic_C", "SonAni_S1Warp4");
	Rename("@Ani_Sonic_D", "SonAni_Skid");
	Rename("@Ani_Sonic_E", "SonAni_S1Float1");
	Rename("@Ani_Sonic_F", "SonAni_Float");
	Rename("@Ani_Sonic_10", "SonAni_Spring");
	Rename("@Ani_Sonic_11", "SonAni_Hang");
	Rename("@Ani_Sonic_12", "SonAni_S1Leap1");
	Rename("@Ani_Sonic_13", "SonAni_S1Leap2");
	Rename("@Ani_Sonic_14", "SonAni_S1Surf");
	Rename("@Ani_Sonic_15", "SonAni_Bubble");
	Rename("@Ani_Sonic_16", "SonAni_DeathBW");
	Rename("@Ani_Sonic_17", "SonAni_Drown");
	Rename("@Ani_Sonic_18", "SonAni_Death");
	Rename("@Ani_Sonic_19", "SonAni_S1Shrink");
	Rename("@Ani_Sonic_1A", "SonAni_Hurt");
	Rename("@Ani_Sonic_1B", "SonAni_Slide");
	Rename("@Ani_Sonic_1C", "SonAni_Blank");
	Rename("@Ani_Sonic_1D", "SonAni_S1Float3");
	Rename("@Ani_Sonic_1E", "SonAni_S1Float4");
	Rename("@Ani_Sonic_1F", "SonAni_IdleMini");
	Rename("@Ani_Sonic_20", "SonAni_DuckMini");
	Rename("@Ani_Sonic_21", "SonAni_WalkMini");
	Rename("@Ani_Sonic_22", "SonAni_RunMini");
	Rename("@Ani_Sonic_23", "SonAni_RollMini");
	Rename("@Ani_Sonic_24", "SonAni_SkidMini");
	Rename("@Ani_Sonic_25", "SonAni_HurtMini");
	Rename("@Ani_Sonic_26", "SonAni_BalanceMini");
	Rename("@Ani_Sonic_27", "SonAni_PushMini");
	Rename("@Ani_Sonic_28", "SonAni_StandMini");
	Rename("@Ani_Sonic_29", "SonAni_LookBack");
	Rename("@Ani_Sonic_2A", "SonAni_Sneeze");
	Rename("@Ani_Sonic_2B", "SonAni_GiveUp");
	Rename("@Ani_Sonic_2C", "SonAni_Hang2");
	Rename("@Ani_Sonic_2D", "SonAni_StandRotate");
	Rename("@Ani_Sonic_2E", "SonAni_Wade");
	Rename("@Ani_Sonic_2F", "SonAni_Float2");
	Rename("@Ani_Sonic_30", "SonAni_GiveUpMini");
	Rename("@Ani_Sonic_31", "SonAni_Peelout");
	Rename("@Ani_Sonic_32", "SonAni_Balance2");
	Rename("@Ani_Sonic_33", "SonAni_RotateBack");
	Rename("@Ani_Sonic_34", "SonAni_RotateFront");
	Rename("@Ani_Sonic_35", "SonAni_Run3D");
	Rename("@Ani_Sonic_36", "SonAni_Roll3D");
	Rename("@Ani_Sonic_37", "SonAni_FallAway");
	Rename("@Ani_Sonic_38", "SonAni_Grow");
	Rename("@Ani_Sonic_39", "SonAni_Shrink");
	if (zone != 4) {
		Rename("@Ani_Sonic_3A", "SonAni_Roll3D");
	} else {
		Rename("@Ani_Sonic_3A", "SonAni_Booster");
	}
}

static DefineKnownObjects(void)
{
	// Sonic
	Rename("ObjPlayer_0_Routine0", "ObjPlayer_Init");
	Rename("ObjPlayer_0_Routine2", "ObjPlayer_Main");
	Rename("ObjPlayer_0_Routine4", "ObjPlayer_Hurt");
	Rename("ObjPlayer_0_Routine6", "ObjPlayer_Dead");
	Rename("ObjPlayer_0_Routine8", "ObjPlayer_Restart");
	Rename("ObjPlayer_1_Routine0", "ObjPlayer_MdGround");
	Rename("ObjPlayer_1_Routine2", "ObjPlayer_MdAir");
	Rename("ObjPlayer_1_Routine4", "ObjPlayer_MdRoll");
	Rename("ObjPlayer_1_Routine6", "ObjPlayer_MdJump");
	AnalyzeSonic();
	
	// HUD/Points
	Rename("ObjHUDPoints_0_Routine0", "ObjPoints_Init");
	Rename("ObjHUDPoints_0_Routine2", "ObjPoints_Main");
	Rename("ObjHUDPoints_1_Routine0", "ObjHud_Init");
	Rename("ObjHUDPoints_1_Routine2", "ObjHud_Main");
	if (ObjHUDPoints > 0) {
		ObjPoints = StartFuncFromOp(ObjHUDPoints + 4, "ObjPoints", 0);
		ObjHUD = StartFunction(ObjHUDPoints + 8, "ObjHud");
	}
	
	// Results
	Rename("ObjResults_0_Routine0", "ObjResults_Init");
	Rename("ObjResults_0_Routine2", "ObjResults_WaitPlc");
	Rename("ObjResults_0_Routine4", "ObjResults_Move");
	Rename("ObjResults_0_Routine6", "ObjResults_Bonus");
	Rename("ObjResults_0_Routine8", "ObjResults_NextStage");
	
	// Powerup
	Rename("ObjPowerup_0_Routine0", "ObjPowerup_Init");
	Rename("ObjPowerup_0_Routine2", "ObjPowerup_Shield");
	Rename("ObjPowerup_0_Routine4", "ObjPowerup_InvStars");
	Rename("ObjPowerup_0_Routine6", "ObjPowerup_TimeStars");
	
	// Ring
	Rename("ObjRing_0_Routine0", "ObjRing_Init");
	Rename("ObjRing_0_Routine2", "ObjRing_Main");
	Rename("ObjRing_0_Routine4", "ObjRing_Collect");
	Rename("ObjRing_0_Routine6", "ObjRing_Sparkle");
	Rename("ObjRing_0_Routine8", "ObjRing_Destroy");
	
	// Lost ring
	Rename("ObjLostRing_0_Routine0", "ObjLostRing_Init");
	Rename("ObjLostRing_0_Routine2", "ObjLostRing_Main");
	Rename("ObjLostRing_0_Routine4", "ObjLostRing_Collect");
	Rename("ObjLostRing_0_Routine6", "ObjLostRing_Sparkle");
	Rename("ObjLostRing_0_Routine8", "ObjLostRing_Destroy");
	
	// Monitor/Time post
	Rename("ObjMonitorTimePost_0_Routine0", "ObjTimeIcon_Init");
	Rename("ObjMonitorTimePost_0_Routine2", "ObjTimeIcon_Main");
	Rename("ObjMonitorTimePost_1_Routine0", "ObjTimePost_Init");
	Rename("ObjMonitorTimePost_1_Routine2", "ObjTimePost_Main");
	Rename("ObjMonitorTimePost_1_Routine4", "ObjTimePost_Spin");
	Rename("ObjMonitorTimePost_1_Routine6", "ObjTimePost_Done");
	Rename("ObjMonitorTimePost_2_Routine0", "ObjMonitor_Init");
	Rename("ObjMonitorTimePost_2_Routine2", "ObjMonitor_Main");
	Rename("ObjMonitorTimePost_2_Routine4", "ObjMonitor_Break");
	Rename("ObjMonitorTimePost_2_Routine6", "ObjMonitor_Animate");
	Rename("ObjMonitorTimePost_2_Routine8", "ObjMonitor_Draw");
	if (ObjMonitorTimePost > 0) {
		ObjMonitor = StartFuncFromOp(ObjMonitorTimePost + 4, "ObjMonitor", 0);
		ObjTimePostTimeIcon = StartFuncFromOp(ObjMonitor + 6, "ObjTimePostTimeIcon", 0);
		ObjTimeIcon = StartFuncFromOp(ObjTimePostTimeIcon + 0x14, "ObjTimeIcon", 0);
		ObjTimePost = StartFunction(ObjTimePostTimeIcon + 0x18, "ObjTimePost");
	}
	
	// Monitor item
	Rename("ObjMonitorItem_0_Routine0", "ObjMonitorItem_Init");
	Rename("ObjMonitorItem_0_Routine2", "ObjMonitorItem_Main");
	Rename("ObjMonitorItem_0_Routine4", "ObjMonitorItem_Destroy");
	
	// Moving spring
	Rename("ObjMovingSpring_0_Routine0", "ObjMovingSpring_Init");
	Rename("ObjMovingSpring_0_Routine2", "ObjMovingSpring_Fall");
	Rename("ObjMovingSpring_0_Routine4", "ObjMovingSpring_Main");
	
	// Spring
	Rename("ObjSpring_0_Routine0", "ObjSpringUnk_Init");
	Rename("ObjSpring_0_Routine2", "ObjSpringUnk_Main");
	Rename("ObjSpring_1_Routine0", "ObjSpring_Init");
	Rename("ObjSpring_1_Routine2", "ObjSpring_UpMain");
	Rename("ObjSpring_1_Routine4", "ObjSpring_UpAnim");
	Rename("ObjSpring_1_Routine6", "ObjSpring_UpReset");
	Rename("ObjSpring_1_Routine8", "ObjSpring_SideMain");
	Rename("ObjSpring_1_RoutineA", "ObjSpring_SideAnim");
	Rename("ObjSpring_1_RoutineC", "ObjSpring_SideReset");
	Rename("ObjSpring_1_RoutineE", "ObjSpring_DownMain");
	Rename("ObjSpring_1_Routine10", "ObjSpring_DownAnim");
	Rename("ObjSpring_1_Routine12", "ObjSpring_DownReset");
	Rename("ObjSpring_1_Routine14", "ObjSpring_DiagonalMain");
	Rename("ObjSpring_1_Routine16", "ObjSpring_DiagonalAnim");
	Rename("ObjSpring_1_Routine18", "ObjSpring_DiagonalReset");
	if (ObjSpring > 0) {
		ObjSpringUnk = StartFuncFromOp(ObjSpring + 6, "ObjSpringUnk", 0);
	}
	
	// Test badnik
	Rename("ObjTestBadnik_0_Routine0", "ObjTestBadnik_Init");
	Rename("ObjTestBadnik_0_Routine2", "ObjTestBadnik_Main");
	
	// Boulder
	Rename("ObjBoulder_0_Routine0", "ObjBoulder_Init");
	Rename("ObjBoulder_0_Routine2", "ObjBoulder_Main");
	
	// Checkpoint
	Rename("ObjCheckpoint_0_Routine0", "ObjCheckpoint_Init");
	Rename("ObjCheckpoint_0_Routine2", "ObjCheckpoint_Main");
	Rename("ObjCheckpoint_0_Routine4", "ObjCheckpoint_Ball");
	Rename("ObjCheckpoint_0_Routine6", "ObjCheckpoint_Animate");

	// Explosion
	Rename("ObjExplosion_0_Routine0", "ObjExplosion_Init");
	Rename("ObjExplosion_0_Routine2", "ObjExplosion_Main");
	Rename("ObjExplosion_0_Routine4", "ObjExplosion_Done");

	// Flower
	Rename("ObjFlower_0_Routine0", "ObjFlower_Init");
	Rename("ObjFlower_0_Routine2", "ObjFlower_Seed");
	Rename("ObjFlower_0_Routine4", "ObjFlower_Animate");
	Rename("ObjFlower_0_Routine6", "ObjFlower_Growing");
	Rename("ObjFlower_0_Routine8", "ObjFlower_Done");
	
	// Flower capsule
	Rename("ObjCapsule_0_Routine0", "ObjCapsule_Init");
	Rename("ObjCapsule_0_Routine2", "ObjCapsule_Main");
	Rename("ObjCapsule_0_Routine4", "ObjCapsule_Spin");
	Rename("ObjCapsule_0_RoutineA", "ObjCapsule_Seed");
	
	// Big ring
	Rename("ObjBigRing_0_Routine0", "ObjBigRingFlash_Init");
	Rename("ObjBigRing_0_Routine2", "ObjBigRingFlash_Animate");
	Rename("ObjBigRing_0_Routine4", "ObjBigRingFlash_Destroy");
	Rename("ObjBigRing_1_Routine0", "ObjBigRing_Init");
	Rename("ObjBigRing_1_Routine2", "ObjBigRing_Main");
	Rename("ObjBigRing_1_Routine4", "ObjBigRing_Animate");
	if (ObjBigRing > 0) {
		ObjBigRingFlash = StartFuncFromOp(ObjBigRing + 4, "ObjBigRingFlash", 0);
	}
	
	// Goal post
	Rename("ObjGoalPost_0_Routine0", "ObjGoalPost_Init");
	Rename("ObjGoalPost_0_Routine2", "ObjGoalPost_Main");
	Rename("ObjGoalPost_0_Routine4", "ObjGoalPost_Done");
	
	// Signpost
	Rename("ObjSignpost_0_Routine0", "ObjSignpost_Init");
	Rename("ObjSignpost_0_Routine2", "ObjSignpost_Main");
	Rename("ObjSignpost_0_Routine4", "ObjSignpost_Spin");
	Rename("ObjSignpost_0_Routine6", "StartResults");
	Rename("ObjSignpost_0_Routine8", "ResultsActive");

	// Robot generator
	Rename("ObjRobotGenerator_0_Routine0", "ObjRobotGen_Init");
	Rename("ObjRobotGenerator_0_Routine2", "ObjRobotGen_Main");
	Rename("ObjRobotGenerator_0_Routine4", "ObjRobotGen_Explode");
	Rename("ObjRobotGenerator_0_Routine6", "ObjRobotGen_Destroyed");

	// Game over
	Rename("ObjGameOver_0_Routine0", "ObjGameOver_Init");
	Rename("ObjGameOver_0_Routine2", "ObjGameOver_Main");
	
	// Title card
	Rename("ObjTitleCard_0_Routine0", "ObjTitleCard_Init");
	Rename("ObjTitleCard_0_Routine2", "ObjTitleCard_SlideInV");
	Rename("ObjTitleCard_0_Routine4", "ObjTitleCard_SlideInH");
	Rename("ObjTitleCard_0_Routine6", "ObjTitleCard_SlideOutV");
	Rename("ObjTitleCard_0_Routine8", "ObjTitleCard_SlideOutH");
	Rename("ObjTitleCard_0_RoutineA", "ObjTitleCard_WaitPlc");
}
