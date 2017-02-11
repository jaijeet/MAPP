AC_INIT([.])
THEVERSION=`head -n 1 ./00-VERSION | sed -e 's/ /_/g'`
#echo THEVERSION=$THEVERSION


#AM_INIT_AUTOMAKE
#AC_CANONICAL_SYSTEM
#AC_CANONICAL_HOST
# sets:
# $build, $host, $target
#     the canonical system names; 
# $build_alias, $host_alias, $target_alias
#     the names the user specified, or the canonical names if config.guess was used; 
# $build_cpu, $build_vendor, $build_os
# $host_cpu, $host_vendor, $host_os
# $target_cpu, $target_vendor, $target_os
#     the individual parts of the canonical names (for convenience). 
# see http://www.nondot.org/sabre/Mirrored/autoconf-2.12/autoconf_8.html

#AC_MSG_RESULT([build=$build, host=$host, target=$target])
#AC_MSG_RESULT([build_alias=$build_alias, host_alias=$host_alias, target_alias=$target_alias])
#AC_MSG_RESULT([build_cpu=$build_cpu, build_vendor=$build_vendor, build_os=$build_os])
#AC_MSG_RESULT([host_cpu=$host_cpu, host_vendor=$host_vendor, host_os=$host_os])
#AC_MSG_RESULT([target_cpu=$target_cpu, target_vendor=$target_vendor, target_os=$target_os])

host_os=$(uname -a);
case $host_os in
	*Cygwin*) CYGWINPREFIX=$SYSTEMDRIVE/cygwin;
		  OS="cygwin";
		  echo "Detected Cygwin environment";
		  echo "  OS: '$host_os'";
		  echo "  using CYGWINPREFIX=$CYGWINPREFIX";
		  ;;

	*Linux*)  CYGWINPREFIX="";
		  OS="linux";
		  echo "Detected linux: $host_os";
		  ;;

	*Darwin*) CYGWINPREFIX="";
		  OS="macosx";
		  echo "OSX: $host_os";
		  ;;
esac

dnl need to also check for basic unix utilities: rm chmod mkdir find etc
dnl see http://www.edwardrosten.com/code/autoconf/ for tips

dnl find and test make utils
AC_PROG_MAKE_SET

dnl find and test the C compiler
AC_PROG_CC
AC_LANG_C
AC_PROG_CXX
AC_HEADER_STDC

dnl AC_PATH_PROG(CD,cd,AC_MSG_ERROR([echo cd not found - is this a Unix installation?]))
AC_PATH_PROG(LN,ln,AC_MSG_ERROR([echo ln not found - is this a Unix installation?]))
AC_PATH_PROG(ECHO,echo,AC_MSG_ERROR([echo not found - is this a Unix installation?]))
AC_PATH_PROG(CAT,cat,AC_MSG_ERROR([echo cat not found - is this a Unix installation?]))
AC_PATH_PROG(CHMOD,chmod,AC_MSG_ERROR([echo chmod not found - is this a Unix installation?]))
AC_PATH_PROG(CP,cp,AC_MSG_ERROR([echo cp not found - is this a Unix installation?]))
AC_PATH_PROG(MV,mv,AC_MSG_ERROR([echo mv not found - is this a Unix installation?]))
AC_PATH_PROG(INSTALL,install,AC_MSG_ERROR([echo mv not found - is this a Unix installation?]))
AC_PATH_PROG(HEAD,head,AC_MSG_ERROR([echo head not found - is this a Unix installation?]))
AC_PATH_PROG(TAR,tar,AC_MSG_ERROR([echo tar not found - is this a Unix installation?]))
AC_PROG_SED(sed)
dnl find perl
AC_PATH_PROG(PERL,perl,AC_MSG_ERROR([echo perl not found - is this a Unix installation?]))
dnl find python
dnl AC_PATH_PROG(PYTHON,python,AC_MSG_ERROR([echo python not found - is this a Unix installation?]))
dnl find make
AC_PATH_PROG(MAKE,make,AC_MSG_ERROR([echo make not found - is this a Unix installation?]))

dnl find matlab
AC_PATH_PROG(MATLAB,matlab,AC_MSG_ERROR([echo Matlab not found. Please install it first!]))
AC_PATH_PROG(MEX,mex,AC_MSG_WARN([echo mex not found - check your MATLAB installation.]))

AC_ARG_WITH(trilinosInstallDir, [  --with-trilinosInstallDir=ARG	 default is $HOME/local/pkgs/trilinos-10.10.3_x86_64_precise])
if test "$with_trilinosInstallDir" == ""
then
	# AC_MSG_NOTICE([trilinos installation dir set to $with_trilinosInstallDir])
	with_trilinosInstallDir="$HOME/local/pkgs/trilinos-11.4.2_x86_64_raring"; # AC_MSG_NOTICE([veccvalder installation dir set to default value $with_trilinosInstallDir])
fi

AC_MSG_CHECKING([trilinos installation])
if test -e $with_trilinosInstallDir/lib/libsacado.so
then
	AC_MSG_RESULT([$with_trilinosInstallDir/lib/libsacado.so is present.])
	LDFLAGS="$LDFLAGS -L$with_trilinosInstallDir/lib/"
else
	AC_MSG_RESULT([$with_trilinosInstallDir/lib/libsacado.so IS NOT PRESENT.])
	AC_MSG_WARN([continuing; but you may want to re-run configure with --with-trilinosInstallDir=/whereever/trilinos/is/installed.])
fi

dnl get the trilinos version
TRIL_VERSION=`cat $with_trilinosInstallDir/include/Trilinos_version.h | grep '#define TRILINOS_VERSION_STRING' | awk '{print $3}' | sed -e 's/"//g'`

dnl find and test trilinos libraries: libteuchos, libsacado, libepetra, libdl
dnl teuchos is a separate library in 10.10.3 but does not seem to exist in 11.4.2
if test "$TRIL_VERSION" == "10.10.3"
then
	AC_CHECK_LIB(teuchos, _init, [], [echo "you need to install libteuchos (as part of trilinos-10.10.3)"])
else
	AC_CHECK_LIB(teuchoscore, _init, [], [echo "ERROR: libteuchoscore not found (does not contain _init)."])
	AC_CHECK_LIB(teuchosnumerics, _init, [], [echo "ERROR: libteuchosnumerics not found (does not contain _init)."])
	AC_CHECK_LIB(teuchosremainder, _init, [], [echo "ERROR: libteuchosremainder not found (does not contain _init)."])
	AC_CHECK_LIB(teuchoscomm, _init, [], [echo "ERROR: libteuchoscomm not found (does not contain _init)."])
	AC_CHECK_LIB(teuchosparameterlist, _init, [], [echo "ERROR: libteuchosparameterlist not found (does not contain _init)."])
fi
AC_CHECK_LIB(sacado, _init, [], [echo "ERROR: libsacado not found (does not contain _init)."])
AC_CHECK_LIB(epetra, _init, [], [echo "ERROR: libepetra not found (does not contain _init)."])


# AC_ARG_WITH(vecvalderInstallDir, [  --with-vecvalderInstallDir=ARG	 default is $HOME/local/pkgs/vecvalder/])
# if test "$with_vecvalderInstallDir" == ""
# then
# 	# AC_MSG_NOTICE([vecvalder installation dir set to $with_vecvalderInstallDir])
# 	with_vecvalderInstallDir="$HOME/local/pkgs/vecvalder"; # AC_MSG_NOTICE([veccvalder installation dir set to default value $with_vecvalderInstallDir])
# fi
# 
# AC_MSG_CHECKING([vecvalder installation])
# if test -f $with_vecvalderInstallDir/lib/vecvalder/utils/setuppaths_vecvalder.m || \
# 	test -f $with_vecvalderInstallDir/lib/vecvalder/utils/setuppaths_vecvalder.p
# then
# 	VV_VERSION=$(cat $with_vecvalderInstallDir/lib/vecvalder/00-VERSION | head -n 1)
# 	AC_MSG_RESULT([$with_vecvalderInstallDir/lib/utils/setuppaths_veccvalder (version $VV_VERSION) is present.])
# else
# 	AC_MSG_RESULT([$with_vecvalderInstallDir/lib/utils/setuppaths_vecvalder.m is NOT present.])
# 	AC_MSG_ERROR([Please re-run configure with --with-vecvalderInstallDir=/whereever/vecvcalder/is/installed.])
# fi
# 

AC_ARG_WITH(extraincludes, [  --with-extraincludes=ARG		e.g., "-Isomeincludedir1 -Isomeincludedir2"]) 
if test "$with_extraincludes" != ""; then
	AC_MSG_RESULT([extraincludes=\"$with_extraincludes\"])
fi

AC_ARG_WITH(extralibs, [  --with-extralibs=ARG		e.g., "-Lsomelibdir1 -Lsomelibdir2 -lsomelib1 -lsomelib2"])
if test "$with_extralibs" != ""; then
	AC_MSG_RESULT([extralibs=\"$with_extralibs\"])
fi

AC_PREFIX_DEFAULT("$HOME/local/pkgs/ModSpec")


AC_SUBST(MODSPECVERSION, $THEVERSION)
AC_SUBST(VECVALDERINSTALLDIR, $with_vecvalderInstallDir)
AC_SUBST(TRILINOSINSTALLDIR, $with_trilinosInstallDir)
AC_SUBST(CYGWINPREFIX, $CYGWINPREFIX)
AC_SUBST(EXTRAINCLUDES, $with_extraincludes)
AC_SUBST(EXTRALIBS, $with_extralibs)
AC_SUBST(OS, $OS)
AC_SUBST(TRIL_VERSION, $TRIL_VERSION)

dnl read Makefile.in and write Makefile
AC_OUTPUT([Makefile ModSpec-C++-API/Makefile ModSpec-C++-API/tests-for-Xyce/Makefile])

echo "--------------------------------------------------------------------"
echo "$THEVERSION configured."
echo ""
echo "It will be installed in:"
echo "	${prefix}"
echo ""
echo "Using vecvalder from:"
echo "	$with_vecvalderInstallDir"
echo ""
echo "Using trilinos from:"
echo "	$with_trilinosInstallDir"
echo ""
echo "Next steps for installation:"
echo "	$ make"
echo "	$ make install"
echo ""
echo "--------------------------------------------------------------------"
