# Author: JR, 2012/08/08
# definitions
CXX = g++
CXXFLAGS = -g -std=gnu++0x
CXXFLAGS = -g -fPIC # -fPIC is needed for creating .so files
INCLUDES = -I.
LIBFLAGS = 

##############
# targets don't come with their own .h files
SHAREDLIB_SRCS = 
TARGET_SRCS = test_untyped.C test_ublas_matrix_std_vector_ops.C
SRCS_W_HDRS = untyped.C eString.C vector_print.C ublas_matrix_std_vector_ops.C
# these below are not targets but don't come with their own .h files
OTHER_SRCS = 

DOT_O_ARCHIVE = utils.a

# headers on which everything depends
CORE_HDRS = eString.h untyped.h boost_ublas_includes_typedefs.h sacado_typedefs.h ublas_matrix_std_vector_ops.h

SUBDIRS = 
ARCHIVES_FROM_SUBDIRS =

EXTRACLEANS = 
##############
# end definitions

TARGETS = $(TARGET_SRCS:.C=)

SHAREDLIBS = $(SHAREDLIB_SRCS:.C=.so)

HDRS = $(SRCS_W_HDRS:.C=.h)

SHAREDLIB_OBJS = $(SHAREDLIB_SRCS:.C=.o)
OBJS_W_HDRS = $(SRCS_W_HDRS:.C=.o) 
OTHER_OBJS = $(OTHER_SRCS:.C=.o)


all: $(DOT_O_ARCHIVE) $(TARGETS)

do_subdirs:
	@for dir in $(SUBDIRS); do \
		$(MAKE) CXX="$(CXX)" CXXFLAGS="$(CXXFLAGS)" LIBFLAGS="$(LIBFLAGS)" -C $$dir; \
	done

subdirs_clean:
	@for dir in $(SUBDIRS); do \
		$(MAKE) CXX="$(CXX)" CXXFLAGS="$(CXXFLAGS)" LIBFLAGS="$(LIBFLAGS)" -C $$dir clean; \
	done

# static pattern rules to create all .o files
$(OBJS_W_HDRS): %.o: %.C %.h $(CORE_HDRS)
	$(CXX) -c $(CXXFLAGS) $(INCLUDES)  -o $@ $<

$(OTHER_OBJS): %.o: %.C $(CORE_HDRS)
	$(CXX) -c $(CXXFLAGS) $(INCLUDES) -o $@ $<

$(SHAREDLIB_OBJS): %.o: %.C %.h $(CORE_HDRS)
	$(CXX) -c $(CXXFLAGS) $(INCLUDES) -o $@ $<

# rule to create archive of .os
$(DOT_O_ARCHIVE): $(OTHER_OBJS) $(OBJS_W_HDRS)
	ar rs $@ $^

# static pattern rule to compile all targets
$(TARGETS): %: %.C $(CORE_HDRS) $(DOT_O_ARCHIVE)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -o $@ $< $(DOT_O_ARCHIVE) $(ARCHIVES_FROM_SUBDIRS) $(LIBFLAGS)

# static pattern rule to compile all shared libraries
$(SHAREDLIBS): %.so: %.o $(DOT_O_ARCHIVE)
	$(CXX) $(CXXFLAGS) -shared -Wl,-soname,$@ -o $@ $< $(ARCHIVES_FROM_SUBDIRS) $(DOT_O_ARCHIVE)

clean:	subdirs_clean
	- rm -f $(DOT_O_ARCHIVE) $(OBJS_W_HDRS) $(OTHER_OBJS) $(SHAREDLIB_OBJS) $(TARGETS) $(SHAREDLIBS) $(EXTRACLEANS)

#this is how you link shared libs at compile time:
#test-Res_ModSpec_Element_two:  sharedlib test-Res_ModSpec_Element.C
#	- g++ $(CXXFLAGS) $(INCLUDES) -c test-Res_ModSpec_Element.C
#	- g++ $(CXXFLAGS) $(INCLUDES) -o test-Res_ModSpec_Element test-Res_ModSpec_Element.o -L. -lModSpecDevices
#	# run this as: LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH ldd  ./test-Res_ModSpec_Element
#	# this does not need dlopen at all
