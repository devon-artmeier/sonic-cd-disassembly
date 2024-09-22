static AnalyzeMappings(addr, name, entryCount)
{
	auto idx, off;
	if (entryCount == 0) {
		entryCount = 256;
	}
	for (idx = 0; idx < entryCount * 2; idx = idx + 2) {
		if (idx > 0 && strlen(Name(addr + idx)) > 0) {
			entryCount = idx / 2;
			break;
		}
		off = SetTableOffset(addr, idx);
		if (substr(Name(off), 0, strlen(name)) != name) {
			MakeName(off, name + "_" + sprintf("%X", idx / 2));
		}
	}

	for (idx = 0; idx < entryCount * 2; idx = idx + 2) {
		off = addr + Word(addr + idx);
		auto count = Byte(off);
		if (count >= 0x80 || count < 0) {
			count = 0;
		}
		ForceByte(off);
		auto spr;
		for (spr = off + 1; spr < off + 1 + (5 * count); spr = spr + 5) {
			ForceFormattedArray(spr, 0, 5, 5, -1);
		}
	}
}

static AnalyzeDPLCs(addr, name, entryCount)
{
	auto idx, off;
	if (entryCount == 0) {
		entryCount = 256;
	}
	for (idx = 0; idx < entryCount * 2; idx = idx + 2) {
		if (idx > 0 && strlen(Name(addr + idx)) > 0) {
			entryCount = idx / 2;
			break;
		}
		off = SetTableOffset(addr, idx);
		if (substr(Name(off), 0, strlen(name)) != name) {
			MakeName(off, name + "_" + sprintf("%X", idx / 2));
		}
	}

	for (idx = 0; idx < entryCount * 2; idx = idx + 2) {
		off = addr + Word(addr + idx);
		auto count = Word(off);
		ForceWord(off);
		auto tile;
		for (tile = off + 2; tile < off + 2 + (2 * count); tile = tile + 2) {
			ForceWord(tile);
		}
	}
}

static AnalyzeAnimations(addr, name, entryCount)
{
	auto idx, off;
	if (entryCount == 0) {
		entryCount = 256;
	}
	for (idx = 0; idx < entryCount * 2; idx = idx + 2) {
		if (idx > 0 && strlen(Name(addr + idx)) > 0) {
			entryCount = idx / 2;
			break;
		}
		off = SetTableOffset(addr, idx);
		if (substr(Name(off), 0, strlen(name)) != name) {
			MakeName(off, name + "_" + sprintf("%X", idx / 2));
		}
	}

	for (idx = 0; idx < entryCount * 2; idx = idx + 2) {
		off = addr + Word(addr + idx);
		ForceByte(off);
		auto size;
		auto frame = Byte(off + 1);
		for (size = 0; frame < 0xFC; size = size + 1) {
			if ((fileID == 18 && (off + size + 2) == 0x20EA92) ||
			    (fileID == 19 && (off + size + 2) == 0x20EA5A) ||
			    Name(off + size + 2) != "") {
				break;
			    }
			frame = Byte(off + size + 2);
		}

		if (frame == 0xFD || frame == 0xFE) {
			ForceArray(off + 1 + size, 2);
		} else if (frame >= 0xF0) {
			ForceByte(off + 1 + size);
		} else {
			size = size + 1;
		}

		ForceFormattedArray(off + 1, 0, size, 8, -1);
	}
}

static DefineKnownData(void)
{
	auto Hud_100000;
	
	NameFromOp(HUD_ResetRings + 0xA, "HudRingsTiles", 0);
	NameFromOp(HUD_ResetScore + 0x14, "HudScoreTiles", 0);
	NameFromOp(HUD_ResetNumber, "Art_HudNumbers", 0);
	Hud_100000 = NameFromOp(HUD_DrawScore, "Hud_100000", 0);
	
	ForceDword(Hud_100000);
	NameDword(Hud_100000 + 4, "Hud_10000");
	NameDword(Hud_100000 + 8, "Hud_1000");
	NameDword(Hud_100000 + 0xC, "Hud_100");
	NameDword(Hud_100000 + 0x10, "Hud_10");
	NameDword(Hud_100000 + 0x14, "Hud_1");
	NameDword(Hud_100000 + 0x18, "Hud_1000h");
	NameDword(Hud_100000 + 0x1C, "Hud_100h");
	NameDword(Hud_100000 + 0x20, "Hud_10h");
	NameDword(Hud_100000 + 0x24, "Hud_1h");
	
	if (zone != 2) {
		ForceDword(LoadCollision + 0x12);
		ForceDword(LoadCollision + 0x16);
		ForceDword(LoadCollision + 0x1A);
		ForceDword(LoadCollision + 0x1E);
		ForceDword(LoadCollision + 0x22);
		ForceDword(LoadCollision + 0x26);
		ForceDword(LoadCollision + 0x2A);
		ForceDword(LoadCollision + 0x2E);
	}

	auto kama = LocByName("ObjKamaKama_0_Routine0");
	if (kama != BADADDR) {
		MakeName(Dword(kama + 2), "Spr_KamaKama1");
		AnalyzeMappings(Dword(kama + 2), "@Spr_KamaKama1", 8);
		MakeName(Dword(kama + 0x14), "Spr_KamaKama2");
		AnalyzeMappings(Dword(kama + 0x14), "@Spr_KamaKama2", 8);
	}
	
	auto sine = LocByName("CalcSine");
	if (sine != BADADDR) {
		NameFormattedWordArray(sine + 0x18, AP_SIGNED, 0x140, 8, 5, "SineTable");
	}
	
	auto angle = LocByName("CalcAngle");
	if (angle != BADADDR) {
		NameFormattedArray(angle + 0x66, 0, 0x101, 8, 4, "ATanTable");
	}
}
