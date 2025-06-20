MF=	Makefile-archer2

# You will need to load some modules:
# 
# module use /work/z19/shared/sfarr/modulefiles
# module load adios/2.8.3
#
# module load cray-hdf5-parallel
# module load cray-netcdf-hdf5parallel
#


FC=	ftn	
#FFLAGS=-O3 $(shell adios2-config --fortran-flags)
#LFLAGS = -lnetcdff -lnetcdf $(shell adios2-config --fortran-libs)

# Get install paths from Spack
NETCDF_FORTRAN_PATH := $(shell spack location -i netcdf-fortran)
NETCDF_C_PATH := $(shell spack location -i netcdf-c)
HDF5_PATH := $(shell spack location -i hdf5)

# Compiler flags
FFLAGS = -O3 \
         -I$(NETCDF_FORTRAN_PATH)/include \
         -I$(HDF5_PATH)/include \
         $(shell adios2-config --fortran-flags)

# Linker flags
LFLAGS = -L$(NETCDF_FORTRAN_PATH)/lib \
	 -L$(NETCDF_C_PATH)/lib \
         -L$(HDF5_PATH)/lib \
	 -Wl,-rpath=$(NETCDF_FORTRAN_PATH)/lib:$(NETCDF_C_PATH)/lib:$(HDF5_PATH)/lib \
         -lnetcdff -lnetcdf -lhdf5_fortran -lhdf5 \
         $(shell adios2-config --fortran-libs)

EXE=	benchio

SRC= \
	benchio.f90 \
	mpiio.f90 \
	serial.f90 \
	netcdf.f90 \
        hdf5.f90 \
        adios.f90 \
	benchutil.f90 \


#
# No need to edit below this line
#

.SUFFIXES:
.SUFFIXES: .f90 .o

OBJ=	$(SRC:.f90=.o)

.f90.o:
	$(FC) $(FFLAGS) -c $<

all:	$(EXE)

$(EXE):	$(OBJ)
	$(FC) $(FFLAGS) -o $@ $(OBJ) $(LFLAGS)

$(OBJ):	$(MF)

benchio.o: serial.o mpiio.o benchutil.o netcdf.o hdf5.o adios.o

clean:
	rm -f $(OBJ) $(EXE) *.mod core

tar:
	tar --exclude-vcs -cvf $(EXE).tar $(MF) $(SRC) benchio.pbs \
		defstriped/README striped/README unstriped/README
