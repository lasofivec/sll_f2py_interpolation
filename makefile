# AUTHOR: Yaman Güçlü - IPP Garching
#
# NOTE:
# . This file is in "selalib/package"
# . At build time, "selalib.inc" is generated inside "<BUILD_DIR>/package"
# . Upon installation, both files are copied to "<INSTALL_DIR>/pkg_info/selalib"
#
# USAGE:
# . Build and install SeLaLib (see manual)
# . Copy "makefile_template" and "selalib.inc" to your project directory
# . Rename "makefile_template" as "makefile" (or "Makefile")
# . Update the variables SOURCES and EXECUTABLE, and possibly other flags
# . Upon "make", your project will be correctly built and linked against SeLaLib

#===============================================================================
# PROJECT information provided by user
#===============================================================================
SOURCES    =  selalib_wrapper.f90 # MANDATORY: Fortran sources
EXECUTABLE =  selalib_interpol # MANDATORY: Executable name
FCFLAGS    =  -fPIC -c # OPTIONAL : Fortran compiler flags
LDFLAGS    =  # OPTIONAL : Linker flags
LIBS       =  # OPTIONAL : Libraries to link
HOME = /home/u2/mendoza
SLLPATH = $(HOME)/repositories/selalib/
FTOPY = $(HOME)/.conda/envs/slmp/bin/f2py
FTOPYFLAGS = -c  --f90flags="-O3 -fPIC -cpp" --fcompiler=gfortran

#===============================================================================
# Link project to SELALIB: include path and library list (do not change this)
#===============================================================================
include selalib.inc
include all_out.inc

FCFLAGS := $(FCFLAGS) -I$(SLL_INCLUDE_PATH)
LIBS := $(LIBS) $(SLL_LIB) $(SLL_EXT) $(SLL_DEPS)

#==============================================================================
# Standard targets: make, make all, make clean
#==============================================================================
OBJECTS = $(SOURCES:.F90=.o)

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(FC) $(FCFLAGS) $(LDFLAGS) $(OBJECTS) $(LIBS) -o $@

%.o: %.F90
	$(FC) $(FCFLAGS) -c $<
%.o: %.f90
	$(FC) $(FCFLAGS) -c $<

print-%  : ; @echo $* = $($*)


mf2py: $(OBJECTS)
	python -m numpy.f2py -I/home/u2/mendoza/repositories/selalib/usr/include/selalib -L/home/u2/mendoza/repositories/selalib/usr/lib/libselalib.a -c --f90flags="-O3 -fPIC" -m selalib_interpol selalib_wrapper.f90 $(SLL_ALL_OUTS) $(SLL_DEPS)

.PHONY: clean
clean:
	$(RM) $(EXECUTABLE) *.o *.mod
