all: test-Res_ModSpec_Element
	#test-Res_ModSpec_Element_two test-Res_ModSpec_Element my_sacado_test

CXXFLAGS = -g -std=gnu++0x
CXXFLAGS = -g -fPIC # -fPIC is needed for creating .so files

TRILINC = -I/home/jr/local/pkgs/trilinos-10.6.4-x86_64/include/

TRILLDFLAGS = -L/home/jr/local/pkgs/trilinos-10.6.4-x86_64/lib

untyped.o: untyped.C untyped.h
	- g++ $(CXXFLAGS) -c untyped.C

eString.o: eString.h eString.C
	- g++ $(CXXFLAGS) -c eString.C

test_untyped: untyped.o eString.o test_untyped.C
	- g++ $(CXXFLAGS) -o test_untyped test_untyped.C untyped.o eString.o -lstdc++ -lm

Res_ModSpec_Element.o: ModSpec_Element.h Res_ModSpec_Element.h Res_ModSpec_Element.C
	- g++ $(CXXFLAGS) $(TRILINC) -c Res_ModSpec_Element.C

# this works, but now we are moving to using the shared lib
test-Res_ModSpec_Element:  untyped.o eString.o Res_ModSpec_Element.o test-Res_ModSpec_Element.C
	- g++ $(CXXFLAGS) $(TRILINC) -c test-Res_ModSpec_Element.C
	- g++ $(CXXFLAGS) $(TRILINC) $(TRILLDFLAGS) -o test-Res_ModSpec_Element test-Res_ModSpec_Element.o Res_ModSpec_Element.o untyped.o eString.o -lstdc++ -lm

test-Res_ModSpec_Element_two:  sharedlib test-Res_ModSpec_Element.C
	- g++ $(CXXFLAGS) $(TRILINC) -c test-Res_ModSpec_Element.C
	- g++ $(CXXFLAGS) $(TRILINC) $(TRILLDFLAGS) -o test-Res_ModSpec_Element test-Res_ModSpec_Element.o -L. -lModSpecDevices
	# run this as: LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH ldd  ./test-Res_ModSpec_Element
	# this does not need dlopen at all

test-Res_ModSpec_Element_three:  sharedlib test-Res_ModSpec_Element_using_dlopen.C
	- g++ $(CXXFLAGS) $(TRILINC) -c test-Res_ModSpec_Element_using_dlopen.C
	- g++ $(CXXFLAGS) $(TRILINC) $(TRILLDFLAGS) -o test-Res_ModSpec_Element_using_dlopen test-Res_ModSpec_Element_using_dlopen.o

my_sacado_test: my_sacado_test.C
	- g++ $(CXXFLAGS) $(TRILINC) $(TRILLDFLAGS) -o my_sacado_test my_sacado_test.C

sharedlib: libModSpecDevices.so.1.0
	- ln -s libModSpecDevices.so.1.0 libModSpecDevices.so.1
	- ln -s libModSpecDevices.so.1 libModSpecDevices.so

libModSpecDevices.so.1.0: eString.o untyped.o Res_ModSpec_Element.o
	- g++ -shared -Wl,-soname,libModSpecDevices.so.1 -o libModSpecDevices.so.1.0 eString.o untyped.o Res_ModSpec_Element.o

clean:
	- rm -f test-Res_ModSpec_Element test-Res_ModSpec_Element.o a.out Res_ModSpec_Element.o my_sacado_test
	- rm -f libModSpecDevices.so.1.0 libModSpecDevices.so.1 libModSpecDevices.so
	- rm -f test-Res_ModSpec_Element_using_dlopen.o test-Res_ModSpec_Element_using_dlopen
	- rm -f untyped.o eString.o test_untyped
