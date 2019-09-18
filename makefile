SLLPATH = /home/u2/mendoza/repositories/selalib/
FTOPY = /home/u2/mendoza/.conda/envs/slmp/bin/f2py
FTOPYFLAGS = -c  --f90flags="-O3 -fPIC -cpp" --fcompiler=gfortran

INCLUDE = -I$(SLLPATH)/build/include/
LIB_DIR =  -I$(SLLPATH)/build/modules/
LIB =  # -lselalib

all:
	$(FTOPY) $(FTOPYFLAGS) $(INCLUDE) $(LIB_DIR) $(LIB)  -m selalib_interpol selalib_wrapper.f90

cleanall:
	@rm -f *.o *~ *.mod *.a *.so
