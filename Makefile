###############################################################################
#                                                                             #
# Makefile for glm                                                            #
#                                                                             #
#  Part of GLM (General Lake Model)                                           #
#                                                                             #
#  Developed by :                                                             #
#      AquaticEcoDynamics (AED) Group                                         #
#      School of Earth & Environment                                          #
#      The University of Western Australia                                    #
#                                                                             #
#      http://aed.see.uwa.edu.au/                                             #
#                                                                             #
#  Copyright 2013 - 2016 -  The University of Western Australia               #
#                                                                             #
#   GLM is free software: you can redistribute it and/or modify               #
#   it under the terms of the GNU General Public License as published by      #
#   the Free Software Foundation, either version 3 of the License, or         #
#   (at your option) any later version.                                       #
#                                                                             #
#   GLM is distributed in the hope that it will be useful,                    #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of            #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             #
#   GNU General Public License for more details.                              #
#                                                                             #
#   You should have received a copy of the GNU General Public License         #
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.     #
#                                                                             #
###############################################################################

OSTYPE=$(shell uname -s)

ifeq ($(WITH_PLOTS),)
  WITH_PLOTS=true
  ifeq ($(WITH_XPLOTS),)
    WITH_XPLOTS=true
  endif
  ifeq ($(PLOTDIR),)
    PLOTDIR=../libplot
  endif
endif

ifeq ($(UTILDIR),)
  UTILDIR=../libutil
endif

srcdir=src
incdir=src
objdir=obj
moddir=mod

TARGETS=glm
DEFINES=
FINCLUDES=-I$(UTILDIR)/include
CINCLUDES=-I$(UTILDIR)/include
LIBS=-L$(UTILDIR)/lib -lutil
GLM_DEPS=$(UTILDIR)/lib/libutil.a
ifeq ($(WITH_PLOTS),true)
  DEFINES+=-DPLOTS
  ifeq ($(WITH_XPLOTS),true)
    DEFINES+=-DXPLOTS
  endif
  GLM_DEPS+=$(PLOTDIR)/lib/libplot.a
  CINCLUDES+=-I$(PLOTDIR)/include
endif

ifeq ($(OSTYPE),Darwin)
  ifeq ($(HOMEBREW),true)
     FINCLUDES+=-I/usr/local/include
     CINCLUDES+=-I/usr/local/include
     LIBS+=-L/usr/local/lib
  else
     FINCLUDES+=-I/opt/local/include
     CINCLUDES+=-I/opt/local/include
     LIBS+=-L/opt/local/lib
  endif
  #EXTRALINKFLAGS=-Wl,-no_compact_unwind
  EXTRALINKFLAGS=-Wl,-no_compact_unwind,-headerpad_max_install_names
  SHARED=-dynamiclib -undefined dynamic_lookup
  so_ext=dylib
else
  EXTRALINKFLAGS=-Wl,--export-dynamic
  SHARED=-shared
  so_ext=so
endif

ifeq ($(FORTRAN_COMPILER),IFORT11)
  F90=ifort
endif
ifeq ($(FORTRAN_COMPILER),IFORT12)
  F90=ifort
endif
ifeq ($(FORTRAN_COMPILER),)
  FORTRAN_COMPILER=GFORTRAN
endif

ifeq ($(FABM),true)
  ifeq ($(DEBUG),true)
    COMPILATION_MODE=debug
  else
    COMPILATION_MODE=production
  endif
  ifeq ($(FABMDIR),)
    FABMDIR=../fabm-git
  endif
  DEFINES+=-DFABM

  ifeq ($(FABM_OLD_BUILD),true)
    ifeq ($(DEBUG),true)
      FABMLIB=fabm_debug
      WITH_CHECKS=true
    else
      FABMLIB=fabm_prod
      WITH_CHECKS=false
    endif

    FINCLUDES+=-I$(FABMDIR)/include -I$(FABMDIR)/src/drivers/glm -I$(FABMDIR)/modules/glm/$(FORTRAN_COMPILER)
    FABMLIBS=-L$(FABMDIR)/lib/glm/$(FORTRAN_COMPILER) -l$(FABMLIB)
  else
    ifeq ($(DEBUG),true)
      FABMLIB=fabm
      WITH_CHECKS=true
    else
      FABMLIB=fabm
      WITH_CHECKS=false
    endif

    FINCLUDES+=-I$(FABMDIR)/include -I$(FABMDIR)/src/drivers/glm -I$(FABMDIR)/build/modules
    FABMLIBS=-L$(FABMDIR)/build -l$(FABMLIB)
  endif

  ifeq ($(USE_DL),true)
    FABMTARGETS=libglm_wq_fabm.${so_ext}
  endif
endif

ifeq ($(AED2),true)
  DEFINES+=-DAED2

  ifeq ($(AED2DIR),)
    AED2DIR=../libaed2
  endif

  FINCLUDES+=-I$(AED2DIR)/include -I$(AED2DIR)/mod
  AED2LIBS=-L$(AED2DIR)/lib -laed2
  ifneq ("$(wildcard ${AED2PLS}/Makefile)","")
    AED2PLBS=-L${AED2PLS}/lib -laed2+
  endif

  ifeq ($(USE_DL),true)
    AED2TARGETS=libglm_wq_aed2.${so_ext}
  endif
endif


FLIBS=
# Select specific compiler bits
ifeq ($(F90),ifort)
  FINCLUDES+=-I/opt/intel/include
  DEBUG_FFLAGS=-g -traceback
  OPT_FFLAGS=-O3
  FFLAGS=-warn all -module ${moddir} -i-static -mp1 -stand f08 $(DEFINES) $(FINCLUDES)
  ifeq ($(WITH_CHECKS),true)
    FFLAGS+=-check
  endif
  FFLAGS+=-real-size 64
  FLIBS+=-L/opt/intel/lib
  FLIBS+=-lifcore -lsvml
  FLIBS+=-limf -lintlc
  ifneq ("$(AED2PLBS)", "")
    AED2PLBS+=-lifport
  endif
else
  F90=gfortran
  FINCLUDES+=-I/usr/include
  DEBUG_FFLAGS=-g -fbacktrace
  OPT_FFLAGS=-O3
  FFLAGS=-Wall -J ${moddir} -Wno-c-binding-type -ffree-line-length-none -std=f2008 $(DEFINES) $(FINCLUDES) -fall-intrinsics
  ifeq ($(WITH_CHECKS),true)
    FFLAGS+=-fcheck=all
  endif
  FFLAGS+=-fdefault-real-8 -fdefault-double-8
  ifeq ($(OSTYPE),Darwin)
    FLIBS+=-L/usr/local/gfortran/lib
  endif
  FLIBS+=-lgfortran
endif

ifneq ($(USE_DL),true)
  WQLIBS=$(AED2LIBS) $(FABMLIBS)
  WQPLIBS=$(AED2PLBS) $(FABMLIBS)
endif

ifeq ($(DEBUG),true)
  DEBUG_CFLAGS=-g -fbounds-check
  OPT_CFLAGS=
  OPT_FFLAGS=
else
  DEBUG_FFLAGS=
  DEBUG_CFLAGS=
  # OPT_CFLAGS=-O4 -Ofast -frounding-math
  OPT_CFLAGS=-O3
  # OPT_CFLAGS=
  # OPT_FFLAGS=
endif

LIBS+=-lnetcdf -lm
# If variable NETCDFLIB is not empty, use it to
# set path to the library
ifneq ($(NETCDFLIB),)
  LIBS+=-L$(NETCDFLIB)
endif


ifeq ($(PLOTDIR),)
  PLOTDIR=../../libplot
endif

ifeq ($(WITH_PLOTS),true)
  LIBS+=-L$(PLOTDIR)/lib -lplot -lgd -lpng -ljpeg
  ifeq ($(WITH_XPLOTS),true)
    ifeq ($(OSTYPE),Darwin)
      LIBS+=-framework Cocoa
    else
      LIBS+=-lX11
    endif
  endif
endif
ifeq ($(DEBUG),true)
  LIBS+=-lefence
endif

CFLAGS=-Wall -I$(UTILDIR) -I$(PLOTDIR) $(CINCLUDES) $(DEFINES) $(DEBUG_CFLAGS) $(OPT_CFLAGS)
FFLAGS+=$(DEBUG_FFLAGS) $(OPT_FFLAGS)

OBJS=${objdir}/glm_globals.o \
     ${objdir}/glm_util.o \
     ${objdir}/glm_csv.o \
     ${objdir}/glm_mobl.o \
     ${objdir}/glm_mixu.o \
     ${objdir}/glm_wqual.o \
     ${objdir}/glm_layers.o \
     ${objdir}/glm_surface.o \
     ${objdir}/glm_input.o \
     ${objdir}/glm_plot.o \
     ${objdir}/glm_output.o \
     ${objdir}/glm_ncdf.o \
     ${objdir}/glm_lnum.o \
     ${objdir}/glm_init.o \
     ${objdir}/glm_flow.o \
     ${objdir}/glm_mixer.o \
     ${objdir}/glm_deep.o \
     ${objdir}/glm_stress.o \
     ${objdir}/glm_bird.o \
     ${objdir}/glm_model.o \
     ${objdir}/glm_types.o \
     ${objdir}/glm_const.o \
     ${objdir}/glm_main.o

ifeq ($(USE_DL),true)
  LIBS+=-ldl
  CFLAGS+=-DUSE_DL_LOADER=1
  FFLAGS+=-DUSE_DL_LOADER=1
  TARGETS+=$(AED2TARGETS) $(FABMTARGETS)
else
  OBJS+=${objdir}/glm_zones.o
  ifeq ($(AED2),true)
    OBJS+=${objdir}/glm_aed2.o
  endif
  ifeq ($(FABM),true)
    OBJS+=${objdir}/glm_fabm.o ${objdir}/ode_solvers.o
  endif
endif


all: $(TARGETS)

lib:
	@mkdir lib

${objdir}:
	@mkdir ${objdir}

${moddir}:
	@mkdir ${moddir}

glm: ${objdir} ${moddir} $(OBJS) $(GLM_DEPS)
	$(CC) -o $@ $(EXTRALINKFLAGS) $(OBJS) $(LIBS) $(WQLIBS) $(FLIBS)

glm+: ${objdir} ${moddir} $(OBJS) $(GLM_DEPS)
	$(CC) -o $@ $(EXTRALINKFLAGS) $(OBJS) $(LIBS) $(WQPLIBS) $(FLIBS)

clean: ${objdir} ${moddir}
	@touch ${objdir}/1.o ${moddir}/1.mod 1.t 1__genmod.f90 glm 1.${so_ext} glm_test_bird
	@/bin/rm ${moddir}/*.mod ${objdir}/*.o *.t *__genmod.f90 *.${so_ext} glm_test_bird
	@echo Made clean

distclean: clean
	@/bin/rm -rf ${objdir} ${moddir} glm glm+

#${objdir}/%.o: ${srcdir}%.F90 ${incdir}/glm.h ${moddir} ${objdir}
#	$(F90) -fPIC $(FFLAGS) $(EXTRA_FFLAGS) -D_FORTRAN_SOURCE_ -c $< -o $@

${objdir}/%.o: ${srcdir}/%.c ${incdir}/glm.h
	$(CC) -fPIC $(CFLAGS) $(EXTRA_FLAGS) -D_C_VERSION_ -c $< -o $@

%.${so_ext}:
	$(LD) ${SHARED} $(LDFLAGS) \
                        -o $@ $^ -L/opt/intel/lib/intel64/ $(LIBS)

#                        -E -Bdynamic -undefined suppress -o $@ $^ -L/opt/intel/lib/intel64/ $(LIBS)

# Build rules

libglm_wq_aed2.${so_ext}: ${objdir}/glm_zones.o ${objdir}/glm_aed2.o ${objdir}/glm_plugin.o
	$(CC) ${SHARED} $(LDFLAGS) -o $@ $^ $(AED2LIBS)

libglm_wq_aed2+.${so_ext}: ${objdir}/glm_zones.o ${objdir}/glm_aed2.o ${objdir}/glm_plugin.o
	$(CC) ${SHARED} $(LDFLAGS) -o $@ $^ $(AED2PLBS)

libglm_wq_fabm.${so_ext}: ${objdir}/glm_zones.o ${objdir}/glm_fabm.o ${objdir}/ode_solvers.o ${objdir}/glm_plugin.o
	$(CC) ${SHARED} $(LDFLAGS) -o $@ $^ $(FABMLIBS)

# special needs dependancies

${objdir}/glm_aed2.o: ${srcdir}/glm_aed2.F90 ${objdir}/glm_types.o
	$(F90) -fPIC $(FFLAGS) $(EXTRA_FFLAGS) -D_FORTRAN_SOURCE_ -c $< -o $@

${objdir}/glm_zones.o: ${srcdir}/glm_zones.F90 ${objdir}/glm_types.o
	$(F90) -fPIC $(FFLAGS) $(EXTRA_FFLAGS) -D_FORTRAN_SOURCE_ -c $< -o $@

${objdir}/glm_fabm.o: ${srcdir}/glm_fabm.F90 ${objdir}/glm_types.o ${objdir}/ode_solvers.o
	$(F90) -fPIC $(FFLAGS) $(EXTRA_FFLAGS) -D_FORTRAN_SOURCE_ -c $< -o $@

${objdir}/glm_types.o: ${srcdir}/glm_types.F90 ${incdir}/glm.h
	$(F90) -fPIC $(FFLAGS) $(EXTRA_FFLAGS) -D_FORTRAN_SOURCE_ -c $< -o $@

${objdir}/ode_solvers.o: ${srcdir}/ode_solvers.F90
	$(F90) -fPIC $(FFLAGS) $(EXTRA_FFLAGS) -D_FORTRAN_SOURCE_ -c $< -o $@

${objdir}/glm_globals.o: ${srcdir}/glm_globals.c ${incdir}/glm_globals.h ${incdir}/glm.h
${objdir}/glm_plugin.o: ${srcdir}/glm_plugin.c ${incdir}/glm_plugin.h ${incdir}/glm.h

