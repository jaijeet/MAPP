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
dnl AC_PROG_CC
dnl AC_LANG_C
dnl AC_PROG_CXX
dnl AC_HEADER_STDC

AC_PATH_PROG(CAT,cat,AC_MSG_ERROR([cat not found - is this a Unix installation?]))
AC_PATH_PROG(CHMOD,chmod,AC_MSG_ERROR([chmod not found - is this a Unix installation?]))
AC_PATH_PROG(CP,cp,AC_MSG_ERROR([cp not found - is this a Unix installation?]))
AC_PATH_PROG(MV,mv,AC_MSG_ERROR([mv not found - is this a Unix installation?]))
AC_PATH_PROG(INSTALL,install,AC_MSG_ERROR([mv not found - is this a Unix installation?]))
AC_PATH_PROG(HEAD,head,AC_MSG_ERROR([head not found - is this a Unix installation?]))
AC_PATH_PROG(TAR,tar,AC_MSG_ERROR([tar not found - is this a Unix installation?]))
AC_PROG_SED(sed)
dnl find perl
AC_PATH_PROG(PERL,perl,AC_MSG_ERROR([perl not found - is this a Unix installation?]))
dnl find python
dnl AC_PATH_PROG(PYTHON,python,AC_MSG_ERROR([python not found - is this a Unix installation?]))
dnl find make
AC_PATH_PROG(MAKE,make,AC_MSG_ERROR([make not found - is this a Unix installation?]))

dnl find matlab
AC_PATH_PROG(MATLAB,matlab,AC_MSG_ERROR([Matlab not found. Please install it first!]))
AC_PATH_PROG(MEX,mex,AC_MSG_WARN([mex not found - check your MATLAB installation.]))

VVVERSION=`head -n 1 ./00-VERSION | sed -e 's/ /_/g'`
#echo VVVERSION=$VVVERSION

AC_PREFIX_DEFAULT("$HOME/local/pkgs/vecvalder")

AC_SUBST(VVVERSION, $VVVERSION)
AC_SUBST(CYGWINPREFIX, $CYGWINPREFIX)

dnl read Makefile.in and write Makefile
AC_OUTPUT(Makefile)

echo "--------------------------------------------------------------------"
echo "$VVVERSION configured."
echo ""
echo "It will be installed in:"
echo "	${prefix}"
echo ""
echo "Next steps for installation:"
echo "	$ make (or make pcode)"
echo "	$ make install (or make installpcode)"
echo ""
echo "--------------------------------------------------------------------"
