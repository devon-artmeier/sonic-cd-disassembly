static UndefineRange(addr, size)
{
	auto i;
	for (i = 0; i < size; i = i + 1) {
		MakeUnkn(addr + i, 0);
	}
}

static DefineVariable(addr, name, size)
{
	MakeName(addr, name);
	UndefineRange(addr, size);
	if (size == 1) {
		MakeByte(addr);
	} else if (size == 2) {
		MakeWord(addr);
	} else if (size == 4) {
		MakeDword(addr);
	} else {
		MakeArray(addr, size);
	}
}

static ForceByte(addr)
{
	MakeUnkn(addr, 0);
	MakeByte(addr);
}

static ForceWord(addr)
{
	UndefineRange(addr, 2);
	MakeWord(addr);
}

static ForceDword(addr)
{
	UndefineRange(addr, 4);
	MakeDword(addr);
}

static ForceArray(addr, size)
{
	UndefineRange(addr, size);
	MakeArray(addr, size);
}

static ForceWordArray(addr, size)
{
	UndefineRange(addr, size);
	ForceWord(addr);
	MakeArray(addr, size);
}

static ForceDwordArray(addr, size)
{
	UndefineRange(addr, size);
	ForceDword(addr);
	MakeArray(addr, size);
}

static ForceFormattedArray(addr, flags, size, line, align)
{
	UndefineRange(addr, size);
	SetArrayFormat(addr, flags, line, align);
	MakeArray(addr, size);
}

static ForceFormattedWordArray(addr, flags, size, line, align)
{
	UndefineRange(addr, size);
	ForceWord(addr);
	SetArrayFormat(addr, flags, line, align);
	MakeArray(addr, size);
}

static ForceFormattedDwordArray(addr, flags, size, line, align)
{
	UndefineRange(addr, size);
	ForceDword(addr);
	SetArrayFormat(addr, flags, line, align);
	MakeArray(addr, size);
}

static NameByte(addr, name)
{
	MakeName(addr, name);
	ForceByte(addr);
}

static NameWord(addr, name)
{
	MakeName(addr, name);
	ForceWord(addr);
}

static NameDword(addr, name)
{
	MakeName(addr, name);
	ForceDword(addr);
}

static NameArray(addr, size, name)
{
	MakeName(addr, name);
	ForceArray(addr, size);
}

static NameWordArray(addr, size, name)
{
	MakeName(addr, name);
	ForceWordArray(addr, size);
}

static NameDwordArray(addr, size, name)
{
	MakeName(addr, name);
	ForceDwordArray(addr, size);
}

static NameFormattedArray(addr, flags, size, line, align, name)
{
	MakeName(addr, name);
	ForceFormattedArray(addr, flags, size, line, align);
}

static NameFormattedWordArray(addr, flags, size, line, align, name)
{
	MakeName(addr, name);
	ForceFormattedWordArray(addr, flags, size, line, align);
}

static NameFormattedDwordArray(addr, flags, size, line, align, name)
{
	MakeName(addr, name);
	ForceFormattedDwordArray(addr, flags, size, line, align);
}

static FindStruct(name)
{
	auto idx;
	auto foundID = -1;
	for (idx = GetFirstStrucIdx(); idx != -1; idx = GetNextStrucIdx(idx)) {
		auto id = GetStrucId(idx);
		if (GetStrucName(id) == name) {
			foundID = id;
			break;
		}
	}
	return foundID;
}

static Rename(oldName, newName)
{
	auto addr = LocByName(oldName);
	if (addr != BADADDR) {
		MakeName(addr, newName);
	}
}

static GetFuncEnd(ea)
{
	return GetFunctionAttr(ea, FUNCATTR_END);
}

static GetFuncSize(ea)
{
	return GetFuncEnd(ea) - ea;
}

static SetTableOff(base, idx, name)
{
	ForceWord(base + idx);
	OpOffEx(base + idx, 0, REF_OFF32, -1, base, 0);
	auto val = base + Word(base + idx);
	if (name != "") {
		MakeName(val, name);
	}
	return val;
}

static SetTableOffFunc(base, idx, name)
{
	auto loc = SetTableOff(base, idx, name);
	MakeCode(loc);
	MakeFunction(loc, BADADDR);
	return loc;
}

static StartFunction(addr, name)
{
	if (name == "ChkObjOnScrWidth") {
		MakeUnkn(addr + 0x30, 0);
	}
	MakeUnkn(addr, 0);
	MakeName(addr, name);
	MakeCode(addr);
	MakeFunction(addr, BADADDR);
	return addr;
}

static NameFromOp(addr, name, op)
{
	auto val = GetOperandValue(addr, op);
	MakeName(val, name);
	return val;
}

static StartFuncFromOp(addr, name, op)
{
	auto val = LocByName(GetOpnd(addr, op));
	StartFunction(val, name);
	return val;
}

static StartFuncFromDword(addr, name)
{
	ForceDword(addr);
	OpOff(addr, 0, 0);
	auto val = Dword(addr);
	StartFunction(val, name);
	return val;
}

static SetDwordPointer(addr, name)
{
	auto val = Dword(addr);
	ForceDword(addr);
	OpOff(addr, 0, 0);
	if (name != "") {
		MakeName(val, name);
	}
	return val;
}

static SetMacro(addr, size, str)
{
	ForceArray(addr, size);
	SetManualInsn(addr, str);
}

static DefineFile(addr, size, file)
{
	SetMacro(addr, size, "\nincbin\t\"" + file + "\"\neven");
}
