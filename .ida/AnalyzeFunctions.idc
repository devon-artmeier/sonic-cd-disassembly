extern HUD_DrawPos;
extern HUD_DrawNum;
extern HUD_ResetScore;
extern HUD_DrawScore;
extern HUD_ResetRings;
extern HUD_DrawRings;
extern HUD_DrawMins;
extern HUD_DrawSecs;
extern HUD_DrawLives;
extern HUD_DrawBonus;
extern HUD_ResetNumber;
extern HUD_DrawHexNum;
extern HUD_DrawCounter;
extern ContScrCounter;
extern LoadCollision;

static DefineKnownFunctions(void)
{
	HUD_DrawPos = StartFuncFromOp(UpdateHUD + 8, "DrawHudPlayerPosition", 0);
	HUD_DrawNum = StartFuncFromOp(UpdateHUD + 0x4E, "DrawHudNumber", 0);
	HUD_ResetScore = StartFuncFromOp(UpdateHUD + 0x60, "ResetHudScore", 0);
	HUD_DrawScore = StartFuncFromOp(UpdateHUD + 0x76, "DrawHudScore", 0);
	HUD_ResetRings = StartFuncFromOp(UpdateHUD + 0x84, "ResetHudRings", 0);
	HUD_DrawRings = StartFuncFromOp(UpdateHUD + 0xAC, "DrawHudRings", 0);
	HUD_DrawMins = StartFuncFromOp(UpdateHUD + 0x114, "DrawHudMinutes", 0);
	HUD_DrawSecs = StartFuncFromOp(UpdateHUD + 0x126, "DrawHudSeconds", 0);
	HUD_DrawLives = StartFuncFromOp(UpdateHUD + 0x16A, "DrawHudLoves", 0);
	HUD_DrawBonus = StartFuncFromOp(UpdateHUD + 0x194, "DrawHudBonus", 0);
	HUD_ResetNumber = StartFuncFromOp(HUD_ResetRings + 0x12, "ResetHudNumber", 0);
	HUD_DrawHexNum = StartFuncFromOp(HUD_DrawPos + 0xC, "DrawHudHexNumber", 0);
	HUD_DrawCounter = StartFunction(HUD_DrawScore + 8, "DrawHudCounter");
	ContScrCounter = StartFunction(HUD_DrawCounter + 0x58, "DrawS1ContinueCount");
	
	if (zone == 2) {
		LoadCollision = StartFunction(UpdateGlobalAnims - 0xA, "LoadCollision");
	} else {
		LoadCollision = StartFunction(UpdateGlobalAnims - 0x32, "LoadCollision");
	}
}
