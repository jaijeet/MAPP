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

# check ModSpec installation

AC_ARG_WITH(ModSpecInstallDir, [  --with-ModSpecInstallDir=ARG	 default is $HOME/local/pkgs/ModSpec/])
if test "$with_ModSpecInstallDir" == ""
then
	# AC_MSG_NOTICE([ModSpec installation dir set to $with_ModSpecInstallDir])
	with_ModSpecInstallDir="$HOME/local/pkgs/ModSpec"; # AC_MSG_NOTICE([ModSpec installation dir set to default value $with_ModSpecInstallDir])
fi

AC_MSG_CHECKING([ModSpec installation])
if test -f $with_ModSpecInstallDir/lib/ModSpec/ModSpec-MATLAB-API/utils/setuppaths_ModSpec.m || \
	test -f $with_ModSpecInstallDir/lib/ModSpec/ModSpec-MATLAB-API/utils/setuppaths_ModSpec.p
then
	MODSPEC_VERSION=$(cat $with_ModSpecInstallDir/lib/ModSpec/00-VERSION | head -n 1)
	AC_MSG_RESULT([$with_ModSpecInstallDir/lib/ModSpec/ModSpec-MATLAB-API/utils/setuppaths_ModSpec (ModSpec version $MODSPEC_VERSION) is present.])
else
	AC_MSG_RESULT([$with_ModSpecInstallDir/lib/ModSpec/ModSpec-MATLAB-API/utils/setuppaths_ModSpec is NOT present.])
	AC_MSG_ERROR([Please re-run configure with --with-ModSpecInstallDir=/whereever/ModSpec/Is/Installed.])
fi


# check NetlistParser-for-DAEAPI installation

AC_ARG_WITH(NetlistParserForDAEAPIInstallDir, [  --with-NetlistParserForDAEAPIInstallDir=ARG	 default is $HOME/local/pkgs/NetlistParser-for-DAEAPI/])
if test "$with_NetlistParserForDAEAPIInstallDir" == ""
then
	# AC_MSG_NOTICE([NetlistParserForDAEAPI installation dir set to $with_NetlistParserForDAEAPIInstallDir])
	with_NetlistParserForDAEAPIInstallDir="$HOME/local/pkgs/NetlistParser-for-DAEAPI"; # AC_MSG_NOTICE([NetlistParserForDAEAPI installation dir set to default value $with_NetlistParserForDAEAPIInstallDir])
fi

AC_MSG_CHECKING([NetlistParser-for-DAEAPI installation])
if test -f $with_NetlistParserForDAEAPIInstallDir/lib/NetlistParser-for-DAEAPI/utils/setuppaths_NetlistParser.m || \
	test -f $with_NetlistParserForDAEAPIInstallDir/lib/NetlistParser-for-DAEAPI/utils/setuppaths_NetlistParser.p
then
	NetlistParserForDAEAPI_VERSION=$(cat $with_NetlistParserForDAEAPIInstallDir/lib/NetlistParser-for-DAEAPI/00-VERSION | head -n 1)
	AC_MSG_RESULT([$with_NetlistParserForDAEAPIInstallDir/lib/NetlistParser-for-DAEAPI/utils/setuppaths_NetlistParser (version $NetlistParserForDAEAPI_VERSION) is present.])
else
	AC_MSG_RESULT([$with_NetlistParserForDAEAPIInstallDir/lib/NetlistParser-for-DAEAPI/utils/setuppaths_NetlistParser is NOT present.])
	AC_MSG_ERROR([Please re-run configure with --with-NetlistParserForDAEAPIInstallDir=/whereever/NetlistParser-for-DAEAPI/is/installed.])
fi

# check vecvalder installation

AC_ARG_WITH(vecvalderInstallDir, [  --with-vecvalderInstallDir=ARG	 default is $HOME/local/pkgs/vecvalder/])
if test "$with_vecvalderInstallDir" == ""
then
	# AC_MSG_NOTICE([vecvalder installation dir set to $with_vecvalderInstallDir])
	with_vecvalderInstallDir="$HOME/local/pkgs/vecvalder"; # AC_MSG_NOTICE([veccvalder installation dir set to default value $with_vecvalderInstallDir])
fi

AC_MSG_CHECKING([vecvalder installation])
if test -f $with_vecvalderInstallDir/lib/vecvalder/utils/setuppaths_vecvalder.m || \
	test -f $with_vecvalderInstallDir/lib/vecvalder/utils/setuppaths_vecvalder.p
then
	VV_VERSION=$(cat $with_vecvalderInstallDir/lib/vecvalder/00-VERSION | head -n 1)
	AC_MSG_RESULT([$with_vecvalderInstallDir/lib/utils/setuppaths_veccvalder (vecvalder version $VV_VERSION) is present.])
else
	AC_MSG_RESULT([$with_vecvalderInstallDir/lib/utils/setuppaths_vecvalder is NOT present.])
	AC_MSG_ERROR([Please re-run configure with --with-vecvalderInstallDir=/whereever/vecvcalder/is/installed.])
fi



AC_PREFIX_DEFAULT("$HOME/local/pkgs/DAEAPI")

AC_SUBST(DAEAPIVERSION, $THEVERSION)
AC_SUBST(CYGWINPREFIX, $CYGWINPREFIX)
AC_SUBST(MODSPECINSTALLDIR, $with_ModSpecInstallDir)
AC_SUBST(VECVALDERINSTALLDIR, $with_vecvalderInstallDir)
AC_SUBST(NETLISTPARSERINSTALLDIR, $with_NetlistParserForDAEAPIInstallDir)

dnl read Makefile.in and write Makefile
AC_OUTPUT(Makefile)

echo "--------------------------------------------------------------------"
echo "$THEVERSION configured."
echo ""
echo "It will be installed in:"
echo "	${prefix}"
echo ""
echo "Using vecvalder from:"
echo "	$with_vecvalderInstallDir"
echo ""
echo "Using ModSpec from:"
echo "	$with_ModSpecInstallDir"
echo ""
echo "Using NetlistParser-for-DAEAPI from:"
echo "	$with_NetlistParserForDAEAPIInstallDir"
echo ""
echo "Next steps for installation:"
echo "	$ make"
echo "	$ make install"
echo ""
echo "--------------------------------------------------------------------"
