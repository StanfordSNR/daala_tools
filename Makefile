# Makefile for daala_tools, a standalone build for
# various utilities from Daala (https://github.com/xiph/daala)
#
# (C) 2016 Riad S. Wahby <rsw@cs.stanford.edu>
#     and the alfalfa project (https://github.com/alfalfa/)
#     See README.md for licensing information.

# configuration flags
#
# These are defaults; override them on the commandline.
STATIC ?= 0
DEBUG ?= 0
QUIET ?= 1

# C compiler flags
CC := gcc
CFLAGS := -m64 -pedantic -pedantic-errors -std=gnu99 -Werror -Wall -Wextra -Wshadow -Wpointer-arith -Wcast-qual -Wformat=2 -Wstrict-prototypes -Wno-missing-prototypes -Wno-format-nonliteral
CFLAGS += -I./include
LDLIBS := -lm

# configuration based on flags
## static compilation
ifeq ($(STATIC),1)
LDFLAGS += -static
endif
## debugging
ifeq ($(DEBUG),1)
CFLAGS += -Og -g
STRIP := echo "Debug mode; not stripping "
else
CFLAGS += -O2
STRIP := strip
endif
## quiet build
ifeq ($(QUIET),1)
QPFX := @
else
QPFX :=
endif

# build targets
TARGETS := dump_ssim dump_fastssim dump_psnr dump_psnrhvs png2y4m y4m2png dump_ssim_fast
dump_ssim_SOURCES := src/dump_ssim.c src/vidinput.c src/y4m_input.c
dump_fastssim_SOURCES := src/dump_fastssim.c src/vidinput.c src/y4m_input.c
dump_psnr_SOURCES := src/dump_psnr.c src/vidinput.c src/y4m_input.c
dump_psnrhvs_SOURCES := src/dump_psnrhvs.c src/vidinput.c src/y4m_input.c src/dct.c src/internal.c
png2y4m_SOURCES := src/kiss99.c src/png2y4m.c
y4m2png_SOURCES := src/vidinput.c src/y4m_input.c src/y4m2png.c

png2y4m_LDLIBS := -lpng -lz
y4m2png_LDLIBS := -lpng -lz

dump_ssim_fast_SOURCES := src/dump_ssim_fast.c src/vidinput.c src/y4m_input.c

# the following variable is used below to generate build rules
# for each of the executables in the TARGETS variable.
define GEN_TARGET_RULE
$(1): $$($(1)_SOURCES:c=o)
	@echo -n "Building $$@... "
	$(QPFX)$$(CC) $$(CPPFLAGS) $$(CFLAGS) $$(LDFLAGS) -o $$@ $$^ $$($(1)_LDLIBS) $$(LDLIBS)
	$(QPFX)$$(STRIP) $$@
	@echo "Done."
endef

all: $(TARGETS)

# override default .o.c target to incorporate $(QPFX)
%.o: %.c
	$(QPFX)echo " [cc] $@"
	$(QPFX)$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

$(foreach targ,$(TARGETS),$(eval $(call GEN_TARGET_RULE,$(targ))))

.PHONY: clean
clean:
	rm -f src/*.o
	rm -f $(TARGETS)
