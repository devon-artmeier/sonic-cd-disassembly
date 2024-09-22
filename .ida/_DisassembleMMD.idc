#include <idc.idc>

extern zone, act, time, fileID;
extern addrMask;

#include "IDAHelpers.idc"
#include "DefineData.idc"
#include "AnalyzeFunctions.idc"
#include "AnalyzeData.idc"
#include "DefineVariables.idc"
#include "DefineMisc.idc"
#include "AnalyzeObject.idc"

static DisassembleMMD(void)
{
	XrefShow(0);
	Indent(8);
	
	DefineMemory();	
	Wait();
	DefineVariables();
	Wait();
	DefineData();
	Wait();
	DefineKnownFunctions();
	Wait();
	DefineMisc();
	Wait();
	DefineKnownData();
	Wait();
	InitObjectDefine();
	Wait();
	
	DefineKnownObjects();
	Wait();
	FinishObjectDefine();
	
	XrefShow(1);
}

static main(void)
{
	auto inFile = GetInputFile();
	
	zone = atol(substr(inFile, 1, 2)) - 1;
	if (zone >= 2) {
		zone = zone - 1;
	}
	act = atol(substr(inFile, 2, 3)) - 1;
	time = (substr(inFile, 3, 4));
	if (time == "A") {
		time = 0;
	} else if (time == "B") {
		time = 1;
	} else if (time == "C") {
		time = 2;
	} else if (time == "D") {
		time = 3;
	}
	fileID = (zone * 10) + (act * 4) + time;
	if (act == 2) {
		fileID = fileID - 2;
	}
	Message("Zone: %i, Act: %i, Time: %i, File: %i\n", zone, act, time, fileID);
	
	// Hack to check if word addresses expand as 24-bit or 32-bit
	MakeCode(0x200174);
	Wait();
	auto op = GetOpnd(0x200174, 0);
	addrMask = 0xFFFFFF;
	if (strlen(op) == 13) {
		addrMask = 0xFFFFFFFF;
	}
	
	auto addr;
	for (addr = 0x200000; addr < 0x240000; addr = addr + 1) {
		MakeUnkn(addr, 0);
		MakeName(addr, "");
		SetManualInsn(addr, "");
	}
	
	DisassembleMMD();
}