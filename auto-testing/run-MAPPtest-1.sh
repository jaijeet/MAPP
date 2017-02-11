#!/bin/bash
#
# this script runs an automatic test of MAPP and emails out results
# typically, called from crontab as follows:
#
# USER=<username> HOME=<homedir> \
# /home/jr/unison/code/newSPICE++/MAPP-git/hagrid-MAPP/auto-testing/run-MAPPtest-1.sh \
#       <branchname> [[ssh-key-for-hagrid git-access] [list of emailees]] \
#       >| /tmp/run-MAPPtest-1-master.out 2>&1
#
# Examples:
#
# USER=jr HOME=/home/jr run-MAPPtest-1.sh master  >| \
#                                       /tmp/run-MAPPtest-1-master.out 2>&1
# USER=jr HOME=/home/jr \
# /home/jr/unison/code/newSPICE++/MAPP-git/hagrid-MAPP/auto-testing/run-MAPPtest-1.sh \
#           jr-test-branch octave MAPPtest_key jr@berkeley.edu,tianshi@berkeley.edu >| \
#           /tmp/run-MAPPtest-1-jr-test-branch.out 2>&1
#
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

function usage {
	echo "Usage: $0 <MAPP-branch-name> [matlab*|octave* [[ssh-key-name [email-addresses]]]]"
    echo ""
    echo "The ssh key should be in $HOME/.ssh/. Email addresses should be separated by"
    echo "commas (with no spaces)."
    echo ""
	echo "Examples:"
    echo "  $0 master"
    echo "  $0 jr-test-branch octave MAPPtest_key jr@berkeley.edu,tianshi@berkeley.edu"
	exit 1;
}

if [ "$1" == "" ]; then
    usage;
fi


#####Please Configure information below before testing#########
export BASHRC=$HOME/.bashrc # will source this to set up PATH
export USERDATESTR=$USER-$(date +%Y-%m-%d-%H%M)
export BRANCHNAME=$1 # 1st argument to script
#BRANCHNAME=trunk
#BRANCHNAME=bichen-branches/off-trunk-r144
#BRANCHNAME=tianshi-branches/off-trunk-r148
if [ "$TMPDIR" == "" ]; then
	export TMPDIR=/tmp
fi
export TEMPGITPATH=$TMPDIR/MAPPtest-${BRANCHNAME//\//.}--$USERDATESTR--$$/
export OUTPUTFILE=$TEMPGITPATH/MAPPtest-output.txt

if [ "$2" == "" ]; then
	export MATLAB_OR_OCTAVE="matlab";
else
	export MATLAB_OR_OCTAVE="$2";
fi

if [[ ("$MATLAB_OR_OCTAVE" != "matlab"*) && ("$MATLAB_OR_OCTAVE" != "octave"*) ]]; then
   echo "$0: 2nd argument $2 unknown; must be 'matlab*' or 'octave*'.";
   usage;
fi

if [ ! "$3" == "" ]; then
	SSHID=$HOME/.ssh/$3
else
	SSHID=$HOME/.ssh/MAPPtest@neem-git-on-hagrid
fi

if [ "$4" == "" ]; then
	#export EMAILEES="tianshi@berkeley.edu,bichen@berkeley.edu,jr@berkeley.edu,aadithya@berkeley.edu"
	export EMAILEES="mappcore@draco.eecs.berkeley.edu"
else
	export EMAILEES=$4
fi

export HOSTNAME=$(hostname)
AUTOTESTSCRIPT=$TEMPGITPATH/MAPP/auto-testing/run-MAPPtest-2.sh
#AUTOTESTSCRIPT=/home/jr/unison/code/newSPICE++/MAPP-SVN/trunk/MAPPtesting/run-MAPPtest-2.sh
AUTOTESTSCRIPTOUTPUTFILE=$TEMPGITPATH/run-MAPPtest-2-output.txt
###############################################################

SHELL=/bin/bash
source $BASHRC # set up your PATH

rm -fr $TEMPGITPATH
mkdir -p $TEMPGITPATH
catch_error " cd mkdir -p $TEMPGITPATH"
cd $TEMPGITPATH
catch_error " cd $TEMPGITPATH"

echo "I am: $(whoami)"
git clone -b $BRANCHNAME --single-branch --depth 1 git@hagrid:MAPP.git
catch_error "git clone -b $BRANCHNAME --single-branch --depth 1 git@hagrid:MAPP.git"

echo ""
if [ -x $AUTOTESTSCRIPT ]; then
	echo "running \"$AUTOTESTSCRIPT >| $AUTOTESTSCRIPTOUTPUTFILE 2>&1\" ..."
	$AUTOTESTSCRIPT >| $AUTOTESTSCRIPTOUTPUTFILE 2>&1
	echo "...done."
else
	echo "$0: ERROR: MAPP test script $AUTOTESTSCRIPT does not exist."
	echo "           or is not executable!"
	ls /DOESNOTEXIST > /dev/null 2>&1
	catch_error "MAPP test script $AUTOTESTSCRIPT (in $BRANCHNAME) does not exist or is not executable."
	exit 1
fi
