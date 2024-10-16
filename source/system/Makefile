# Root folder path
ROOT_PATH          := ../..

# Common rules
	include $(ROOT_PATH)/make.rules

# Source folder paths
SRC_SUB_CORE_PATH  := sub_core
SRC_SUB_EXT_PATH   := sub_extension
SRC_MAIN_BOOT_PATH := main_boot
SRC_MAIN_CORE_PATH := main_core

# Object folder paths
OBJ_PATH_SUB_CORE  := $(OBJ_PATH)/$(SRC_SUB_CORE_PATH)
OBJ_PATH_SUB_EXT   := $(OBJ_PATH)/$(SRC_SUB_EXT_PATH)
OBJ_PATH_MAIN_BOOT := $(OBJ_PATH)/$(SRC_MAIN_BOOT_PATH)
OBJ_PATH_MAIN_CORE := $(OBJ_PATH)/$(SRC_MAIN_CORE_PATH)

# Output files
OUT_SUB_CORE       := $(BUILD_PATH)/sp.bin
OUT_SUB_EXT        := $(FILES_PATH)/SPX___.BIN
OUT_MAIN_BOOT      := $(BUILD_PATH)/ip.bin
OUT_MAIN_CORE      := $(FILES_PATH)/IPX___.MMD

# Sub CPU core files
SRC_SUB_CORE       := $(SRC_SUB_CORE_PATH)/header.asm \
                      $(SRC_SUB_CORE_PATH)/initialize.asm \
                      $(SRC_SUB_CORE_PATH)/temp_save.asm \
                      $(SRC_SUB_CORE_PATH)/interrupt.asm \
                      $(SRC_SUB_CORE_PATH)/load_file.asm \
                      $(SRC_SUB_CORE_PATH)/get_file_name.asm \
                      $(SRC_SUB_CORE_PATH)/file_engine.asm
OBJ_SUB_CORE       := $(patsubst %.asm,$(OBJ_PATH)/%.o,$(SRC_SUB_CORE))

DEPEND_SUB_CORE    := $(INCLUDE_PATH)/backup_ram.inc \
                      $(INCLUDE_PATH)/mcd_sub.inc \
                      $(INCLUDE_PATH)/system.inc

# Sub CPU extension files
SRC_SUB_EXT        := $(SRC_SUB_EXT_PATH)/file_name_table.asm \
                      $(SRC_SUB_EXT_PATH)/backup_ram_params.asm \
                      $(SRC_SUB_EXT_PATH)/main.asm \
                      $(SRC_SUB_EXT_PATH)/cmd_pencil_test.asm \
                      $(SRC_SUB_EXT_PATH)/cmd_backup_ram_manager.asm \
                      $(SRC_SUB_EXT_PATH)/cmd_thank_you.asm \
                      $(SRC_SUB_EXT_PATH)/cmd_special_stage_flags.asm \
                      $(SRC_SUB_EXT_PATH)/cmd_backup_ram_init.asm \
                      $(SRC_SUB_EXT_PATH)/cmd_save_data.asm \
                      $(SRC_SUB_EXT_PATH)/cmd_stage.asm \
                      $(SRC_SUB_EXT_PATH)/cmd_md_init.asm \
                      $(SRC_SUB_EXT_PATH)/cmd_title.asm \
                      $(SRC_SUB_EXT_PATH)/cmd_comin_soon.asm \
                      $(SRC_SUB_EXT_PATH)/cmd_easter_egg.asm \
                      $(SRC_SUB_EXT_PATH)/cmd_simple_file.asm \
                      $(SRC_SUB_EXT_PATH)/cmd_visual_mode.asm \
                      $(SRC_SUB_EXT_PATH)/cmd_warp.asm \
                      $(SRC_SUB_EXT_PATH)/cmd_time_attack.asm \
                      $(SRC_SUB_EXT_PATH)/cmd_da_garden.asm \
                      $(SRC_SUB_EXT_PATH)/cmd_fmv.asm \
                      $(SRC_SUB_EXT_PATH)/cmd_special_stage.asm \
                      $(SRC_SUB_EXT_PATH)/cmd_sound.asm \
                      $(SRC_SUB_EXT_PATH)/interrupt.asm \
                      $(SRC_SUB_EXT_PATH)/communication.asm \
                      $(SRC_SUB_EXT_PATH)/cdda_ids.asm \
                      $(SRC_SUB_EXT_PATH)/backup_ram_scratch.asm
OBJ_SUB_EXT        := $(patsubst %.asm,$(OBJ_PATH)/%.o,$(SRC_SUB_EXT))

DEPEND_SUB_EXT     := $(INCLUDE_PATH)/backup_ram.inc \
                      $(INCLUDE_PATH)/cdda_ids.inc \
                      $(INCLUDE_PATH)/da_garden.inc \
                      $(INCLUDE_PATH)/mcd_sub.inc \
                      $(INCLUDE_PATH)/pcm_driver.inc \
                      $(INCLUDE_PATH)/pcm_sound_ids.inc \
                      $(INCLUDE_PATH)/special_stage.inc \
                      $(INCLUDE_PATH)/system.inc \
                      $(INCLUDE_PATH)/system_symbols.inc

# Main CPU bootloader files
SRC_MAIN_BOOT      := $(SRC_MAIN_BOOT_PATH)/security_usa.asm \
                      $(SRC_MAIN_BOOT_PATH)/boot.asm
OBJ_MAIN_BOOT      := $(patsubst %.asm,$(OBJ_PATH)/%.o,$(SRC_MAIN_BOOT))

# Main CPU core files
SRC_MAIN_CORE      := $(SRC_MAIN_CORE_PATH)/main.asm \
                      $(SRC_MAIN_CORE_PATH)/best_staff_times.asm \
                      $(SRC_MAIN_CORE_PATH)/backup_ram_manager.asm \
                      $(SRC_MAIN_CORE_PATH)/special_stage_demo.asm \
                      $(SRC_MAIN_CORE_PATH)/game.asm \
                      $(SRC_MAIN_CORE_PATH)/stage_select.asm \
                      $(SRC_MAIN_CORE_PATH)/demo.asm \
                      $(SRC_MAIN_CORE_PATH)/sound_test.asm \
                      $(SRC_MAIN_CORE_PATH)/visual_mode.asm \
                      $(SRC_MAIN_CORE_PATH)/da_garden.asm \
                      $(SRC_MAIN_CORE_PATH)/time_attack.asm \
                      $(SRC_MAIN_CORE_PATH)/mmd.asm \
                      $(SRC_MAIN_CORE_PATH)/interrupt.asm \
                      $(SRC_MAIN_CORE_PATH)/save_data.asm \
                      $(SRC_MAIN_CORE_PATH)/functions.asm
OBJ_MAIN_CORE      := $(patsubst %.asm,$(OBJ_PATH)/%.o,$(SRC_MAIN_CORE))

# Reserved rules
.PHONY: all clean

# All
all: $(OUT_SUB_CORE) $(OUT_SUB_EXT) $(OUT_MAIN_BOOT) $(OUT_MAIN_CORE)

# Link Main CPU core files
$(OUT_MAIN_CORE): $(OBJ_MAIN_CORE)
	$(VLINK) $(VLINK_FLAGS) -T link_main_core.link -o $@ $^

# Assemble Main CPU core files
$(OBJ_MAIN_CORE): $(OBJ_PATH)/%.o: %.asm $(BUILD_PATH) $(OBJ_PATH_MAIN_CORE) $(DEPEND_MAIN) $(OUT_SUB_EXT)
	$(VASM_M68K) $(VASM_M68K_FLAGS) -o $@ $<

# Link Main CPU bootloader files
$(OUT_MAIN_BOOT): $(OBJ_MAIN_BOOT)
	$(VLINK) $(VLINK_FLAGS) -T link_main_boot.link -o $@ $^

# Assemble Main CPU bootloader files
$(OBJ_MAIN_BOOT): $(OBJ_PATH)/%.o: %.asm $(BUILD_PATH) $(OBJ_PATH_MAIN_BOOT) $(DEPEND_MAIN) $(OUT_SUB_EXT)
	$(VASM_M68K) $(VASM_M68K_FLAGS) -o $@ $<
	
# Link Sub CPU extension files
$(OUT_SUB_EXT): $(OBJ_SUB_EXT)
	$(VLINK) $(VLINK_FLAGS) -T link_sub_extension.link -o $@ $^
	$(EXTRACT_SYM) $(EXTRACT_SYM_FLAGS) -o $(INCLUDE_PATH)/system_ids.inc -ip "FILE_" -ip "SYS_" -xp "FILE_STATUS_" $(OBJ_PATH_SUB_EXT)/file_name_table.o $(OBJ_PATH_SUB_EXT)/main.o
	$(RM) "spx.sym"

# Assemble Sub CPU extension files
$(OBJ_SUB_EXT): $(OBJ_PATH)/%.o: %.asm $(FILES_PATH) $(OBJ_PATH_SUB_EXT) $(DEPEND_SUB_EXT) $(OUT_SUB_CORE)
	$(VASM_M68K) $(VASM_M68K_FLAGS) -o $@ $<

# Link Sub CPU core files
$(OUT_SUB_CORE): $(OBJ_SUB_CORE)
	$(VLINK) $(VLINK_FLAGS) -T link_sub_core.link -symfile sp.sym -o $@ $^
	$(EXTRACT_SYM) $(EXTRACT_SYM_FLAGS) -o $(INCLUDE_PATH)/system_symbols.inc -iy "TempSaveData" -iy "MegaDriveIrq" -iy "LoadFile" -iy "GetFileName" -iy "FileFunction" sp.sym
	$(RM) "sp.sym"

# Assemble Sub CPU core files
$(OBJ_SUB_CORE): $(OBJ_PATH)/%.o: %.asm $(BUILD_PATH) $(OBJ_PATH_SUB_CORE) $(DEPEND_SUB_CORE)
	$(VASM_M68K) $(VASM_M68K_FLAGS) -o $@ $<

# Create Sub CPU core object folder
$(OBJ_PATH_SUB_CORE): $(OBJ_PATH)
	$(MKDIR) "$@"

# Create Sub CPU extension object folder
$(OBJ_PATH_SUB_EXT): $(OBJ_PATH)
	$(MKDIR) "$@"

# Create Main CPU bootloader object folder
$(OBJ_PATH_MAIN_BOOT): $(OBJ_PATH)
	$(MKDIR) "$@"

# Create Main CPU core object folder
$(OBJ_PATH_MAIN_CORE): $(OBJ_PATH)
	$(MKDIR) "$@"
        
# Create object folder
$(OBJ_PATH):
	$(MKDIR) "$@"

# Create files folder
$(FILES_PATH): $(BUILD_PATH)
	$(MKDIR) "$@"

# Create build folder
$(BUILD_PATH):
	$(MKDIR) "$@"

# Clean
clean:
	$(RM) "$(OBJ_PATH)"
	$(RM) "$(OUT_SUB_CORE)"
	$(RM) "$(OUT_SUB_EXT)"
	$(RM) "$(OUT_MAIN_BOOT)"
	$(RM) "$(OUT_MAIN_CORE)"