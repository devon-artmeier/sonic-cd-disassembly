	include ../../make.rules

BUILD_PATH    := ../../build
FILES_PATH    := $(BUILD_PATH)/files

SRC_CORE_PATH := sub_core
SRC_EXT_PATH  := sub_extension

OBJ_PATH      := .obj
OBJ_PATH_CORE := $(OBJ_PATH)/$(SRC_CORE_PATH)
OBJ_PATH_EXT  := $(OBJ_PATH)/$(SRC_EXT_PATH)

OUT_CORE      := $(BUILD_PATH)/sp.bin
OUT_EXT       := $(FILES_PATH)/SPX___.BIN

SYSTEM_SYMS   := ../../include/system_symbols.inc

DEPEND        := ../../include/backup_ram.inc \
                 ../../include/cdda_ids.inc \
                 ../../include/da_garden.inc \
                 ../../include/mcd_sub.inc \
                 ../../include/pcm_driver.inc \
                 ../../include/pcm_sound_ids.inc \
                 ../../include/special_stage.inc \
                 ../../include/system.inc
DEPEND_EXT    := $(SYSTEM_SYMS)

SRC_CORE      := $(SRC_CORE_PATH)/header.asm \
                 $(SRC_CORE_PATH)/initialize.asm \
                 $(SRC_CORE_PATH)/temp_save.asm \
                 $(SRC_CORE_PATH)/interrupt.asm \
                 $(SRC_CORE_PATH)/load_file.asm \
                 $(SRC_CORE_PATH)/get_file_name.asm \
                 $(SRC_CORE_PATH)/file_engine.asm
OBJ_CORE      := $(patsubst %.asm,$(OBJ_PATH)/%.o,$(SRC_CORE))

SRC_EXT       := $(SRC_EXT_PATH)/file_name_table.asm \
                 $(SRC_EXT_PATH)/backup_ram_params.asm \
                 $(SRC_EXT_PATH)/main.asm \
                 $(SRC_EXT_PATH)/cmd_pencil_test.asm \
                 $(SRC_EXT_PATH)/cmd_backup_ram_manager.asm \
                 $(SRC_EXT_PATH)/cmd_thank_you.asm \
                 $(SRC_EXT_PATH)/cmd_special_stage_flags.asm \
                 $(SRC_EXT_PATH)/cmd_backup_ram_init.asm \
                 $(SRC_EXT_PATH)/cmd_save_data.asm \
                 $(SRC_EXT_PATH)/cmd_stage.asm \
                 $(SRC_EXT_PATH)/cmd_md_init.asm \
                 $(SRC_EXT_PATH)/cmd_title.asm \
                 $(SRC_EXT_PATH)/cmd_comin_soon.asm \
                 $(SRC_EXT_PATH)/cmd_easter_egg.asm \
                 $(SRC_EXT_PATH)/cmd_simple_file.asm \
                 $(SRC_EXT_PATH)/cmd_visual_mode.asm \
                 $(SRC_EXT_PATH)/cmd_warp.asm \
                 $(SRC_EXT_PATH)/cmd_time_attack.asm \
                 $(SRC_EXT_PATH)/cmd_da_garden.asm \
                 $(SRC_EXT_PATH)/cmd_fmv.asm \
                 $(SRC_EXT_PATH)/cmd_special_stage.asm \
                 $(SRC_EXT_PATH)/cmd_sound.asm \
                 $(SRC_EXT_PATH)/interrupt.asm \
                 $(SRC_EXT_PATH)/communication.asm \
                 $(SRC_EXT_PATH)/cdda_ids.asm \
                 $(SRC_EXT_PATH)/backup_ram_scratch.asm
OBJ_EXT       := $(patsubst %.asm,$(OBJ_PATH)/%.o,$(SRC_EXT))

.PHONY: all clean

all: $(OUT_CORE) $(OUT_EXT)
	
$(OUT_EXT): $(OBJ_EXT)
	$(VLINK) $(VLINK_FLAGS) -T link_extension.link -o $@ $^
	
$(OBJ_EXT): $(OBJ_PATH)/%.o: %.asm $(FILES_PATH) $(OBJ_PATH_EXT) $(DEPEND) $(DEPEND_EXT) $(OUT_CORE)
	$(VASM_M68K) $(VASM_M68K_FLAGS) -I../../include -o $@ $<
	
$(OUT_CORE): $(OBJ_CORE)
	$(VLINK) $(VLINK_FLAGS) -T link_core.link -symfile sp.sym -o $@ $^
	$(EXTRACT_SYM) $(EXTRACT_SYM_FLAGS) -o $(SYSTEM_SYMS) -iy "TempSaveData" -iy "MegaDriveIrq" -iy "LoadFile" -iy "GetFileName" -iy "FileFunction" sp.sym
	$(RM) "sp.sym"

$(OBJ_CORE): $(OBJ_PATH)/%.o: %.asm $(BUILD_PATH) $(OBJ_PATH_CORE) $(DEPEND)
	$(VASM_M68K) $(VASM_M68K_FLAGS) -I../../include -o $@ $<

$(OBJ_PATH_CORE): $(OBJ_PATH)
	$(MKDIR) "$@"

$(OBJ_PATH_EXT): $(OBJ_PATH)
	$(MKDIR) "$@"

$(OBJ_PATH):
	$(MKDIR) "$@"

$(FILES_PATH): $(BUILD_PATH)
	$(MKDIR) "$@"

$(BUILD_PATH):
	$(MKDIR) "$@"

clean:
	$(RM) "$(OUT_CORE)"
	$(RM) "$(OUT_EXT)"
	$(RM) "$(OBJ_PATH)"