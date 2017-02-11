#!/bin/bash

# can be run standalone or from run-MAPPtest-1.sh. In the latter case, a
# number of shell variables should already have been exported (see below -
# UTSL)

function catch_error() {
        if [ $? != 0 ]; then
                echo "Error executing (on $HOSTNAME):" >>  $OUTPUTFILE
                echo $1 >>  $OUTPUTFILE
                subjectline="FAILED: MAPPtest on $BRANCHNAME ("$HOSTNAME:$USERDATESTR")" 
                cat  $OUTPUTFILE |  mail -s "$subjectline" $EMAILEES
		echo "error caught"
		cat $OUTPUTFILE
        fi
}

#trap Ctrl-C
trap '{ 
	subjectline="FAILED: MAPPtest on $BRANCHNAME ($HOSTNAME:$USERDATESTR)" 
	echo "Ctrl-C pressed while $0 running: exiting." | mail -s "$subjectline" $EMAILEES
	exit 1; 
}' INT

SHELL=/bin/bash

if [ "$TMPDIR" == "" ]; then
	export TMPDIR=/tmp
fi

if [ "$TEMPGITPATH" == "" ]; then
	if [ "$1" == "" ]; then
		echo "Usage: $0 <FULL-TEMP-GIT-PATH>"
		echo "Examples:"
		echo "	$0 $TMPDIR/MAPPtest-jr-2013-09-23-0850--20487/"
		echo ""
		echo "(If the exported shell variable TEMPGITPATH is"
		echo " properly set, then this script can be called"
		echo " with no arguments)."
		exit 1;
	fi
	export TEMPGITPATH=$1 # 1st arg to script 
fi


if [ "$BASHRC" == "" ]; then
	export BASHRC=$HOME/.bashrc # will source this to set up PATH
fi

source $BASHRC # set up your PATH

MATLABPATH=""; # set this up if the right matlab is not in your PATH (in .bashrc)
if [ ! "$MATLABPATH" == "" ]; then
	export PATH=$MATLABPATH:$PATH
fi

OCTAVEPATH=""; # set this up if the right octave is not in your PATH (in .bashrc)
if [ ! "$OCTAVEPATH" == "" ]; then
	export PATH=$OCTAVEPATH:$PATH
fi

if [ "$USERDATESTR" == "" ]; then
	export USERDATESTR=$USER-$(date +%Y-%m-%d-%H%M)
fi

if [ "$OUTPUTFILE" == "" ]; then
	export OUTPUTFILE=$TEMPGITPATH/MAPPtest-output.txt
fi

if [ "$HOSTNAME" == "" ]; then
	export HOSTNAME=$(hostname)
fi

if [ "$EMAILEES" == "" ]; then
	export EMAILEES="bichen@berkeley.edu,jr@berkeley.edu,aadithya@berkeley.edu,tianshi@berkeley.edu"
fi

###########################################

# Start time
job_started_at=$(date);


cd $TEMPGITPATH/MAPP
catch_error "cd $TEMPGITPATH/MAPP"

#if [ "$BRANCHNAME" == "" ]; then
#	export BRANCHNAME=$(svn info | grep URL | awk '{print $2}' | sed -e 's#.*/svnrepos/MAPP/##')
#fi


GITVERSION=$(git log -n 1 --pretty=oneline | perl -ane "@_ = split; print @_[0]")
MAPPINSTALLDIR=`head -n 1 ./00-VERSION | sed -e 's/ /_/g' -e "s/GETVERSIONFROMGIT/$GITVERSION/" -e "s/USER/$USER/"`
BRANCHNAMEFROMGIT=`git symbolic-ref --short HEAD`
MAPPINSTALLDIR=`head -n 1 ./00-VERSION | sed -e "s/GETVERSIONFROMGIT/$GITVERSION/" -e "s/GETBRANCHNAMEFROMGIT/$BRANCHNAMEFROMGIT/" -e "s/USER/$USER/" -e 's/ /_/g'`
#MAPPINSTALLDIR=$(cat 00-VERSION | head -n 1) # ideally, autoconf should fill this in, but there's a bit of a chicken/egg problem

# MATLAB_OR_OCTAVE should be exported by run-MAPPtest-1.sh
if [[ "$MATLAB_OR_OCTAVE" == "matlab"* ]]; then
    MATLAB=$(which $MATLAB_OR_OCTAVE)
    if [ "$MATLAB" == "" ]; then
        echo "$0: ERROR: $MATLAB_OR_OCTAVE NOT FOUND"
        exit -5;
    fi
    OCTAVE="";
else
    OCTAVE=$(which $MATLAB_OR_OCTAVE)
    if [ "$OCTAVE" == "" ]; then
        echo "$0: ERROR: OCTAVE NOT FOUND"
        exit -5;
    fi
    MATLAB="";
fi


# show stuff while testing this script
if [ 1 == 1 ]; then
	echo PATH=$PATH
	echo TEMPGITPATH=$TEMPGITPATH
	echo BRANCHNAME=$BRANCHNAME
	echo BRANCHNAMEFROMGIT=$BRANCHNAMEFROMGIT
	echo EMAILEES=$EMAILEES
	echo OUTPUTFILE=$OUTPUTFILE
	echo MATLAB=$MATLAB
	echo OCTAVE=$OCTAVE
	echo MATLAB_OR_OCTAVE=$MATLAB_OR_OCTAVE
	echo GITVERSION=$GITVERSION
	echo MAPPINSTALLDIR=$MAPPINSTALLDIR
fi


# Install MAPP-MATLAB 
autoconf
catch_error "autoconf"

./configure
catch_error "./configure"

make 
catch_error "make"

#cp ./$MAPPINSTALLDIR/setuppaths_MAPP.m $TEMPGITPATH/setuppaths_MAPP.m 
#catch_error "cp ./$MAPPINSTALLDIR/setuppaths_MAPP.m $TEMPGITPATH/setuppaths_MAPP.m"
cp ./$MAPPINSTALLDIR/start_MAPP.m $TEMPGITPATH/start_MAPP.m 
catch_error "cp ./$MAPPINSTALLDIR/start_MAPP.m $TEMPGITPATH/start_MAPP.m"

cd ..
catch_error "cd .."

rm -f run_MAPPtest.m
catch_error "rm -f run_MAPPtest.m"

cat > run_MAPPtest.m << EOF
try 
        start_MAPP;
EOF
#catch_error "cat > run_MAPPtest.m << EOF (1)"

echo "	diary('"$OUTPUTFILE"');" >> run_MAPPtest.m
catch_error "echo diary('$OUTPUTFILE') >> run_MAPPtest.m"

cat >> run_MAPPtest.m << EOF
        disp('------------------------------------------------------------------------------');
        disp('TEST SCRIPTS RUN:');
        disp('  - MAPPtest(''compare'')');
        disp('------------------------------------------------------------------------------');

        disp('TEST RESULTS:');
        disp('------------------------------------------------------------------------------');
        MAPPtest('compare'); %MAPPtest_transient
        disp('CODE TERMINATED SUCCESSFULLY.');
catch err
        disp(err.message);
        disp('CODE DID NOT TERMINATE SUCCESSFULLY.');
        diary off
end
EOF
catch_error "cat > run_MAPPtest.m << EOF (2)"


if [ "$MATLAB" != "" ]; then
    $MATLAB -nodesktop -nosplash -r "run_MAPPtest; exit" 
    catch_error "$MATLAB -nodesktop -nosplash -r \"run_MAPPtest; exit\""
else
    $OCTAVE --no-gui run_MAPPtest.m
    catch_error "$OCTAVE --no-gui run_MAPPtest.m"
fi

# Time when job finishes
job_finished_at=$(date);
echo "finished running MAPPtest in $MATLAB_OR_OCTAVE at $job_finished_at."

cd MAPP
catch_error "cd MAPP";

# Parsing file 
result=$(grep -i "FAIL" $OUTPUTFILE);
# a somewhat fragile way of determining if all went well
last_line=$(cat $OUTPUTFILE | grep "." | tail -1)

if [ -z "$result" ] && [[ $last_line == "CODE TERMINATED SUCCESSFULLY." ]] 
then 
        FAILED=0;
        subjectline="passed: MAPPtest/$MATLAB_OR_OCTAVE on $BRANCHNAME revision $GITVERSION ("$HOSTNAME:$USERDATESTR")"
else
        FAILED=1;
        subjectline="FAILED: MAPPtest/$MATLAB_OR_OCTAVE on $BRANCHNAME revision $GITVERSION ("$HOSTNAME:$USERDATESTR")"
fi
echo "mail subjectline = $subjectline"

#cd $TEMPGITPATH

# Create a header for email
header_file="$TEMPGITPATH/header.tc"
echo "MAPPtest started at "$job_started_at >> $header_file
echo "MAPPtest finished at "$job_finished_at >> $header_file
echo "Branch Tested: "$BRANCHNAME >>$header_file
echo "" >>$header_file
echo "--------------------------------------------------------------------------------" >> $header_file
echo "git log -n 1: ">>$header_file
echo "--------------------------------------------------------------------------------" >> $header_file
git log -n 1 >>$header_file
echo "--------------------------------------------------------------------------------" >> $header_file

# Prepare email text and send it
cat $header_file $OUTPUTFILE |  mail -s "$subjectline" $EMAILEES
cat $header_file $OUTPUTFILE

# Clean 
cd $TEMPGITPATH
#rm -fr $TEMPGITPATH/MAPP # temporarily commented out for debugging
#leave the other stuff there
