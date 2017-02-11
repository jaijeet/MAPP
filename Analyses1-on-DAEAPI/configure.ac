AC_INIT([.])
THEVERSION=`head -n 1 ./00-VERSION | sed -e 's/ /_/g'`
#echo THEVERSION=$THEVERSION

host_os=$(uname -a);
case $host_os in

	*Cygwin*) CYGWINPREFIX=$SYSTEMDRIVE/cygwin;
		  echo "Detected Cygwin environment";
		  echo "  OS: '$host_os'";
		  echo "  using CYGWINPREFIX=$CYGWINPREFIX";
		  ;;

	*) 	  CYGWINPREFIX="";
		  #echo "Cygwin environment NOT detected: $host_os";
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

# check DAEAPI installation

AC_ARG_WITH(DAEAPIinstallDir, [  --with-DAEAPIinstallDir=ARG	 default is $HOME/local/pkgs/DAEAPI/])
if test "$with_DAEAPIinstallDir" == ""
then
	# AC_MSG_NOTICE([DAEAPI installation dir set to $with_DAEAPIinstallDir])
	with_DAEAPIinstallDir="$HOME/local/pkgs/DAEAPI"; # AC_MSG_NOTICE([DAEAPI installation dir set to default value $with_DAEAPIinstallDir])
fi

AC_MSG_CHECKING([DAEAPI installation])
if test -f $with_DAEAPIinstallDir/lib/DAEAPI/utils/setuppaths_DAEAPI.m || \
	test -f $with_DAEAPIinstallDir/lib/DAEAPI/utils/setuppaths_DAEAPI.p
then
	DAEAPI_VERSION=$(cat $with_DAEAPIinstallDir/lib/DAEAPI/00-VERSION | head -n 1)
	AC_MSG_RESULT([$with_DAEAPIinstallDir/lib/DAEAPI/utils/setuppaths_DAEAPI (DAEAPI version $DAEAPI_VERSION) is present.])
else
	AC_MSG_RESULT([$with_DAEAPIinstallDir/lib/DAEAPI/utils/setuppaths_DAEAPI is NOT present.])
	AC_MSG_ERROR([Please re-run configure with --with-DAEAPIinstallDir=/whereever/DAEAPI/is/installed.])
fi

AC_PREFIX_DEFAULT("$HOME/local/pkgs/Analyses1-on-DAEAPI")
THE_PREFIX=`test "$prefix" = NONE && prefix=$ac_default_prefix; eval echo "${prefix}"` # "hairy", because ac_default_prefix undocumented

AC_SUBST(A1oDAEAPIVERSION, $THEVERSION)
AC_SUBST(CYGWINPREFIX, $CYGWINPREFIX)
AC_SUBST(DAEAPIINSTALLDIR, $with_DAEAPIinstallDir)
AC_SUBST(A1oDAEAPIINSTALLDIRLIB, $THE_PREFIX/lib/Analyses1-on-DAEAPI)

dnl read Makefile.in and write Makefile
AC_OUTPUT(Makefile)

echo "--------------------------------------------------------------------"
echo "$THEVERSION configured."
echo ""
echo "It will be installed in:"
echo "	${prefix}"
echo ""
echo "Using DAEAPI from:"
echo "	$with_DAEAPIinstallDir"
echo ""
echo "Next steps for installation:"
echo "	$ make"
echo "	$ make install"
echo ""
echo "--------------------------------------------------------------------"
