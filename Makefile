MCU = attiny816
MCU_CLOCK = 16000000
FORMAT = ihex
TARGET = hub6_attiny
INC_DIR = src
SRC_DIR = src
SRC = $(wildcard $(SRC_DIR)/*.c)
ASRC = 
OPT = s
PROG_TOOL = updiprog
PROG_TARGET = tiny81x
CPORT = COM5
TRACE_TOOL = D:/xmd.exe
TRACE_BAUDRATE = 450000

OUTDIR = build

DEBUG =

CSTANDARD = -std=gnu99

# Place -D or -U options here
CDEFS =

# Place -I options here
CINCS =

CDEBUG = -D$(DEBUG)
CWARN = -Wall --param=min-pagesize=0
CTUNING = -ffunction-sections -fdata-sections -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
CEXTRA = -Wa,-adhlns=$(addprefix $(OUTDIR)/,$(notdir $(<:.c=.lst)))
CFLAGS = $(CDEBUG) $(CDEFS) $(CINCS) -O$(OPT) $(CWARN) $(CSTANDARD) $(CEXTRA)

ASFLAGS = -Wa,-adhlns=$(addprefix $(OUTDIR)/,$(notdir $(<:.s=.lst)))

#Additional libraries.

# Minimalistic printf version
PRINTF_LIB_MIN = -Wl,-u,vfprintf -lprintf_min

# Floating point printf version (requires MATH_LIB = -lm below)
PRINTF_LIB_FLOAT = -Wl,-u,vfprintf -lprintf_flt

PRINTF_LIB = 

MATH_LIB = -lm

# External memory options
EXTMEMOPTS =

LDMAP = -Wl,-Map=$(OUTDIR)/$(TARGET).map,--cref
LDFLAGS = $(EXTMEMOPTS) $(LDMAP) $(PRINTF_LIB) $(MATH_LIB)

CC = avr-gcc
OBJCOPY = avr-objcopy
OBJDUMP = D:/Downloads/avr-gcc-12/bin/avr-objdump
SIZE = avr-size
NM = avr-nm
REMOVE = rm -f
MV = mv -f

# Define all object files.
OBJ = $(addprefix $(OUTDIR)/,$(notdir $(SRC:.c=.o))) $(addprefix $(OUTDIR)/,$(notdir $(ASRC:.s=.o))) 
ASM = $(addprefix $(OUTDIR)/,$(notdir $(SRC:.c=.asm)))  

# Define all listing files.
LST = $(addprefix $(OUTDIR)/,$(notdir $(SRC:.c=.lst))) $(addprefix $(OUTDIR)/,$(notdir $(ASRC:.s=.lst)))

# Combine all necessary flags and optional flags.
# Add target processor to flags.
ALL_CFLAGS = -mmcu=$(MCU) -DF_CPU=$(MCU_CLOCK) -I$(INC_DIR) $(CFLAGS)
ALL_ASFLAGS = -mmcu=$(MCU) -DF_CPU=$(MCU_CLOCK) -I$(INC_DIR) -x assembler-with-cpp $(ASFLAGS)

# Start device debugging via trace
trace:
	$(TRACE_TOOL) -p $(CPORT) -b $(TRACE_BAUDRATE)

# Program the device. 
flash: hex
	$(PROG_TOOL) -c $(CPORT) -d $(PROG_TARGET) -e
	$(PROG_TOOL) -c $(CPORT) -d $(PROG_TARGET) -w $(OUTDIR)/$(TARGET).hex

# Debug version of the program
debug:
	make DEBUG=__DEBUG all

# Release version of the program
release:
	make DEBUG=nDEBUG all

# Default target.
all: elf hex lss

elf: $(OUTDIR)/$(TARGET).elf
hex: $(OUTDIR)/$(TARGET).hex
eep: $(OUTDIR)/$(TARGET).eep
lss: $(OUTDIR)/$(TARGET).lss 
sym: $(OUTDIR)/$(TARGET).sym 


$(OUTDIR)/$(TARGET).hex: $(OUTDIR)/$(TARGET).elf
	$(OBJCOPY) -O $(FORMAT) -R .eeprom $< $@

$(OUTDIR)/$(TARGET).eep: $(OUTDIR)/$(TARGET).elf
	-$(OBJCOPY) -j .eeprom --set-section-flags=.eeprom="alloc,load" \
	--change-section-lma .eeprom=0 -O $(FORMAT) $< $@

# Create extended listing file from ELF output file.
$(OUTDIR)/$(TARGET).lss: $(OUTDIR)/$(TARGET).elf
	$(OBJDUMP) -h -S -masm=intel $< > $@

# Create a symbol table from ELF output file.
$(OUTDIR)/$(TARGET).sym: $(OUTDIR)/$(TARGET).elf
	$(NM) -n $< > $@

# Link: create ELF output file from object files.
$(OUTDIR)/$(TARGET).elf: makedir $(OBJ) $(ASM)
	$(CC) $(ALL_CFLAGS) $(OBJ) -o $@ $(LDFLAGS)


# Compile: create assembler files from C source files.
$(OUTDIR)/%.asm: $(OUTDIR)/%.o
	$(OBJDUMP) -d -Mintel -S $< > $@

# Compile: create object files from C source files.
$(OUTDIR)/%.o: $(SRC_DIR)/%.c
	$(CC) -c $(ALL_CFLAGS) $< -o $@ 

# Assemble: create object files from assembler source files.
$(OUTDIR)/%.o: $(SRC_DIR)/%.s
	$(CC) -c $(ALL_ASFLAGS) $< -o $@

makedir: | $(OUTDIR)
$(OUTDIR):
	mkdir -p $@

# Target: clean project.
clean:
	$(REMOVE) $(OUTDIR)/$(TARGET).hex $(OUTDIR)/$(TARGET).eep $(OUTDIR)/$(TARGET).cof $(OUTDIR)/$(TARGET).elf \
	$(OUTDIR)/$(TARGET).map $(OUTDIR)/$(TARGET).sym $(OUTDIR)/$(TARGET).lss \
	$(OBJ) $(ASM) $(LST) $(OUTDIR)/$(SRC:.c=.s) $(OUTDIR)/$(SRC:.c=.d)

