AC_INIT([.])
SHELL=/bin/bash
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

# set version and user
GITVERSION=$(git log -n 1 --pretty=oneline | perl -ane "@_ = split; print @_[[0]]")
BRANCHNAME=$(git symbolic-ref --short HEAD)
#echo GITVERSION=$GITVERSION
THEVERSION=`head -n 1 ./00-VERSION | sed -e "s/GETVERSIONFROMGIT/$GITVERSION/" -e "s/GETBRANCHNAMEFROMGIT/$BRANCHNAME/" -e "s/USER/$USER/" -e 's/ /_/g'`
#echo THEVERSION=$THEVERSION


# set up installation directories

#AC_ARG_WITH(MAPPlocalLinksDir, [  --with-MAPPlocalLinksDir=ARG	 (default is $(pwd)/$THEVERSION)])
#if test "$with_MAPPlocalLinksDir" == ""
#then
#	#AC_MSG_NOTICE([MAPPlocalLinksDir set to $with_MAPPlocalLinksDir]) 
#	with_MAPPlocalLinksDir="$(pwd)/$THEVERSION"; # AC_MSG_NOTICE([MAPPlocalLinksDir set to default value $with_MAPPlocalLinksDir])
with_MAPPlocalLinksDir="$(pwd)/$THEVERSION"

AC_ARG_WITH(VVimplementation, [  --with-VVimplementation=ARG    vecvalder implementation (vv1 or vv2; default is vv2)])
if test "$with_VVimplementation" == ""
then
	with_VVimplementation="vv2"; # AC_MSG_NOTICE([VVimplementation set to default value vv2])
fi

LOCALA2oDAEAPI="Analyses2-on-DAEAPI"
A2oDAEAPI=""; # if = "", no support for A2oDAEAPI
AC_ARG_WITH([A2oDAEAPI],
            [AS_HELP_STRING([--with-A2oDAEAPI],
              [enable support for $LOCALA2oDAEAPI (default=no)])],
            [],
            [with_A2oDAEAPI=no])

if test "$with_A2oDAEAPI" != "no"; then
    if test -e ./Analyses2-on-DAEAPI; then
        A2oDAEAPI="A2oDAEAPI-MATLAB";
    else
        AC_MSG_ERROR([echo --with-A2oDAEAPI specified, but no directory $LOCALA2oDAEAPI exists!])
    fi
fi

LOCALA3oDAEAPI="Analyses3-on-DAEAPI"
A3oDAEAPI=""; # if = "", no support for A3oDAEAPI
AC_ARG_WITH([A3oDAEAPI],
            [AS_HELP_STRING([--with-A3oDAEAPI],
              [enable support for $LOCALA3oDAEAPI (default=no)])],
            [],
            [with_A3oDAEAPI=no])

if test "$with_A3oDAEAPI" != "no"; then
    if test -e ./Analyses3-on-DAEAPI; then
        A3oDAEAPI="A3oDAEAPI-MATLAB";
    else
        AC_MSG_ERROR([echo --with-A3oDAEAPI specified, but no directory $LOCALA3oDAEAPI exists!])
    fi
fi

LOCALCONTRIBS="contribs"
CONTRIBS=""; # if = "", no support for contribs
AC_ARG_WITH([usercontribs],
            [AS_HELP_STRING([--with-usercontribs],
              [enable support for user contributed modules (default=no)])],
            [],
            [with_usercontribs=no])

if test "$with_usercontribs" != "no"; then
    if test -e ./$LOCALCONTRIBS; then
        CONTRIBS="contribs";
    else
        AC_MSG_ERROR([echo --with-usercontribs specified, but no directory ./contribs exists!])
    fi
fi

LOCALOPTO="opticalStuff"
OPTO=""; # if = "", no support for optical stuff
AC_ARG_WITH([opto],
            [AS_HELP_STRING([--with-opto],
              [enable support for optical modelling (default=no)])],
            [],
            [with_opto=no])

if test "$with_opto" != "no"; then
    if test -e ./$LOCALOPTO; then
        OPTO="opto-MATLAB";
    else
        AC_MSG_ERROR([echo --with-opto specified, but no directory ./opticalStuff exists!])
    fi
fi

LOCALVAPP="VAPP"
VAPP=""; # if = "", no support for VAPP
AC_ARG_WITH([VAPP],
            [AS_HELP_STRING([--with-VAPP],
              [enable support for VAPP (Verilog-A Parser and Processor) (default=no)])],
            [],
            [with_VAPP=no])

if test "$with_VAPP" != "no"; then
    if test -e ./$LOCALVAPP; then
        VAPP="VAPP";
        cat help/help_MAPP.txt.in.src help/help_VAPP.txt > help/help_MAPP.txt.in
    else
        AC_MSG_ERROR([echo --with-VAPP specified, but no directory ./VAPP exists!])
    fi
else
    cat help/help_MAPP.txt.in.src > help/help_MAPP.txt.in
fi

AC_PREFIX_DEFAULT("--prefix is NOT USED by MAPP")
#THE_PREFIX=`test "$prefix" = NONE && prefix=$ac_default_prefix; eval echo "${prefix}"` # "hairy", because ac_default_prefix undocumented

VECVALDER="vecvalder"
UTILS="utils"
MODSPEC="ModSpec-MATLAB"
LOCALMODSPEC="ModSpec/ModSpec-MATLAB-API"
DAEAPI="DAEAPI-MATLAB"
LOCALDAEAPI="DAEAPI"
DOCUMENTATION="Documentation"
A1oDAEAPI="A1oDAEAPI-MATLAB"
LOCALA1oDAEAPI="Analyses1-on-DAEAPI"
MAPPTESTDATABASE="$(pwd)/$LOCALA1oDAEAPI/test-data"

AC_SUBST(MAPPVERSION, $THEVERSION)
AC_SUBST(BRANCHNAME, $BRANCHNAME)
AC_SUBST(CYGWINPREFIX, $CYGWINPREFIX)
AC_SUBST(MAPPLOCALLINKSDIR, $with_MAPPlocalLinksDir)
AC_SUBST(VVIMPLEMENTATION, $with_VVimplementation)
#AC_SUBST(MAPPINSTALLDIR, $THE_PREFIX)
AC_SUBST(VECVALDER, $VECVALDER)
AC_SUBST(UTILS, $UTILS)
AC_SUBST(MODSPEC, $MODSPEC)
AC_SUBST(LOCALMODSPEC, $LOCALMODSPEC)
AC_SUBST(DAEAPI, $DAEAPI)
AC_SUBST(LOCALDAEAPI, $LOCALDAEAPI)
AC_SUBST(A1oDAEAPI, $A1oDAEAPI)
AC_SUBST(A2oDAEAPI, $A2oDAEAPI)
AC_SUBST(A3oDAEAPI, $A3oDAEAPI)
AC_SUBST(LOCALA1oDAEAPI, $LOCALA1oDAEAPI)
AC_SUBST(LOCALA2oDAEAPI, $LOCALA2oDAEAPI)
AC_SUBST(LOCALA3oDAEAPI, $LOCALA3oDAEAPI)
AC_SUBST(CONTRIBS, $CONTRIBS)
AC_SUBST(LOCALCONTRIBS, $LOCALCONTRIBS)
AC_SUBST(OPTO, $OPTO)
AC_SUBST(LOCALOPTO, $LOCALOPTO)
AC_SUBST(DOCUMENTATION, $DOCUMENTATION)
AC_SUBST(THEVERSION, $THEVERSION)
AC_SUBST(MAPPTESTDATABASE, $MAPPTESTDATABASE)
AC_SUBST(VAPP, $VAPP)
AC_SUBST(MAPPTOP, `pwd`)

dnl read <each file below>.in and write <each file below>
AC_OUTPUT(Makefile setuppaths_MAPP.m start_MAPP.m Generate_help.sh
          vecvalder/vv4/vv4-tests/create_vv4_models_for_test_vv4_MVS_9_stage_ring_oscillator_transient.py
          vecvalder/vv4/vv4-tests/test_vv4_MVS_9_stage_ring_oscillator_transient.m
          vecvalder/vv4/vv4-tests/check_for_vv4_python_dependencies.m
          help/help_MAPP.txt Analyses1-on-DAEAPI/test-scripts/MAPPtest/MAPPtest.m)
#AC_OUTPUT(Makefile setuppaths_MAPP.m start_MAPP.m Generate_help.sh help/help_MAPP.txt)

echo "--------------------------------------------------------------------"
echo "$THEVERSION configured."
echo ""
echo "Local installation (soft links into the git working copy) will be in:"
echo "	${with_MAPPlocalLinksDir}"
echo ""
echo "Next steps:"
echo "	$ make installlocallinks"
echo "	or just"
echo "	$ make"
echo ""
echo "--------------------------------------------------------------------"
