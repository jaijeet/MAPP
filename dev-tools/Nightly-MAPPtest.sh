#!/bin/bash
# This can only be run from mohanty@ataraxia

# <TODO> Receive an argument which tell which branch/working-copy to
# install
subjectline="MAPP auto-tests ("$(date +%Y-%m-%d)"): | PASSED" 
cat temp.txt|mail -s "$subjectline" mohanty@berkeley.edu #,jr@berkeley.edu,aadithya@berkeley.edu,tianshi@berkeley.edu
