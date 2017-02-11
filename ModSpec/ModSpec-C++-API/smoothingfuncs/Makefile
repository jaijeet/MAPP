# Author: JR, 2012/08/11
# definitions - these should get overwritten if make called as make CXX="somthing" CXXFLAGS=something
CXX = g++
CXXFLAGS = -g -fPIC # -fPIC is needed for creating .so files
INCLUDES = -I. -I../utils/ 
LIBFLAGS = 

##############
# targets don't come with their own .h files
SHAREDLIB_SRCS = 
TARGET_SRCS = 
SRCS_W_HDRS = 
# these below are not targets but don't come with their own .h files
OTHER_SRCS = dsmoothabs.C \
	     dsmoothclip.C \
	     safeexp.C \
	     safelog.C \
	     safesqrt.C \
	     smoothabs.C \
	     smoothclip.C \
	     smoothmax.C \
	     smoothmin.C \
	     smoothsign.C \
	     smoothstep.C \
	     smoothswitch.C

# headers on which everything depends
CORE_HDRS = smoothingfuncs.h

DOT_O_ARCHIVE = smoothingfuncs.a
##############
# end definitions

TARGETS = $(TARGET_SRCS:.C=)

SHAREDLIBS = $(SHAREDLIB_SRCS:.C=.so)

HDRS = $(SRCS_W_HDRS:.C=.h)

SHAREDLIB_OBJS = $(SHAREDLIB_SRCS:.C=.o)
OBJS_W_HDRS = $(SRCS_W_HDRS:.C=.o) 
OTHER_OBJS = $(OTHER_SRCS:.C=.o)


all: $(DOT_O_ARCHIVE)

# static pattern rules to create all .o files
$(OBJS_W_HDRS): %.o: %.C %.h $(CORE_HDRS)
	$(CXX) -c $(CXXFLAGS) $(INCLUDES) $(TRILIINC) $(TRILLDFLAGS) -o $@ $<

$(OTHER_OBJS): %.o: %.C $(CORE_HDRS)
	$(CXX) -c $(CXXFLAGS) $(INCLUDES) $(TRILIINC) $(TRILLDFLAGS) -o $@ $<

$(SHAREDLIB_OBJS): %.o: %.C %.h $(CORE_HDRS)
	$(CXX) -c $(CXXFLAGS) $(INCLUDES) $(TRILIINC) $(TRILLDFLAGS) -o $@ $<

# rule to create archive of .os
$(DOT_O_ARCHIVE): $(OTHER_OBJS) $(OBJS_W_HDRS)
	ar rs $@ $^

# static pattern rule to compile all targets
$(TARGETS): %: %.C $(CORE_HDRS) $(DOT_O_ARCHIVE)
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(TRILIINC) $(TRILLDFLAGS) -o $@ $< $(DOT_O_ARCHIVE) $(LIBFLAGS)

# static pattern rule to compile all shared libraries
$(SHAREDLIBS): %.so: %.o $(DOT_O_ARCHIVE)
	$(CXX) $(CXXFLAGS) -shared -Wl,-soname,$@ -o $@ $< $(DOT_O_ARCHIVE)

clean:
	- rm -f $(DOT_O_ARCHIVE) $(OBJS_W_HDRS) $(OTHER_OBJS) $(SHAREDLIB_OBJS) $(TARGETS) $(SHAREDLIBS)

#this is how you link shared libs at compile time:
#test-Res_ModSpec_Element_two:  sharedlib test-Res_ModSpec_Element.C
#	- g++ $(CXXFLAGS) $(INCLUDES) $(TRILINC) -c test-Res_ModSpec_Element.C
#	- g++ $(CXXFLAGS) $(INCLUDES) $(TRILINC) $(TRILLDFLAGS) -o test-Res_ModSpec_Element test-Res_ModSpec_Element.o -L. -lModSpecDevices
#	# run this as: LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH ldd  ./test-Res_ModSpec_Element
#	# this does not need dlopen at all
