#!/bin/bash

newcopyright="$*"

if [ "$newcopyright" == "" ]; then
	newcopyright="\
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\r%% Type \"help MAPPlicense\" at the MATLAB\/Octave prompt to see the license      %\r%% for this software.                                                          %\r%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %\r%% reserved.                                                                   %\r%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\r"
fi

echo Updating copyright to:;
echo "$newcopyright";
echo ""

FILES=$(find . -type f ! -name "*.svn*" -exec egrep -q "^%+\s*[Cc]opyright" \{\} \; -print);
# note: ignores soft links

#echo "$FILES"

# note: \_. means match any character including newline
# usually a bad idea to use \_.* - use \_.\{-} instead (shortest match)
# while * (or \* if magic is off) means 0 or more off, \+ means 1 or more of.
# \n matches newline (but don't use in the to-substitute pattern, use \r
# instead
# see http://stackoverflow.com/questions/784176/multi-line-regex-support-in-vim
# BE CAREFUL TO MAKE THE SUBSTITUTE PATTERN PROPERLY SPECIFIC TO WHAT YOU WANT

# also: check out the 4 modes vim has for regexes: 
# - http://andrewradev.com/2011/05/08/vim-regexes/
# - :help magic
# http://vim.wikia.com/wiki/Perl_compatible_regular_expressions

# vim 7.3/7.4 seem to have a bug matching \n inside groups - if inside a group,
# \n never matches. But ^ and $ inside a group seem to work (note the grouping
# in the middle using \( ... \)):
# excmd1=":%s/^%\+$\n^%\+\s*\([Aa]uthor\|Type\).*$\n\(^%.*$\)\n^%.*$\n^%\+\s*[Cc]opyright\s\+([Cc]).*$\n^%\+$/$newcopyright/"

excmd1=":%s/^%\+$\n^%\+\s*\([Aa]uthor\|Type\)\_.\{-}\n^%\+\s*[Cc]opyright\s\+([Cc])\_.\{-}\n^%\+$/$newcopyright/"
# the above totally wipes out all lines with %\+\n% Author: ... in it!
excmd1=":%s/^%\+$\n^%\+\s*\(Type \"help MAPPlicense\"\).*$\n\(^%.*$\n\)\{-}^%\+\s*[Cc]opyright\s\+([Cc]).*$\n\(^%.*$\n\)\{-}^%\+$/$newcopyright/"
excmd1=":%s/^%\+$\n^%\+\s*\(Type \"help MAPPlicense\"\)\_.\{-,200}\n^%\+\s*[Cc]opyright\s\+([Cc])\_.\{-,200}\n^%\+$/$newcopyright/"
excmd1="%s/^%\+$\n^%\+\s*\([Aa]uthor\|Type \"help MAPPlicense\"\)\_.\{-,200}\n^%\+\s*[Cc]opyright\s\+([Cc])\_.\{-,200}\n^%\+$/$newcopyright/"
excmd1="%s/^%\+$\n^%\+\s*\(Type \"help MAPPlicense\"\)\_.\{-,200}\n^%\+\s*[Cc]opyright\s\+([Cc])\_.\{-,200}\n^%\+$/$newcopyright/"

#for i in "DAEAPI/DAEs/LCtanhOsc.m"; do
for i in $FILES; do
	ex -s -c "$excmd1" -c :wq $i
	if [ $? == 0 ]; then
		status="changed";
	else
		status="unchanged";
	fi
	echo "done ($status): $i";
done
