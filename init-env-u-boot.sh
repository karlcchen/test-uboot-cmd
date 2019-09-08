#!/bin/bash
#
#
CMD_SRC_FILE="${1}"
CVT_CMD_FILE="x1.cmd.txt"
#
./cvt-cmd-4-screen.sh -f ${CMD_SRC_FILE} ${CVT_CMD_FILE}
if [ $? -ne 0 ] ; then
    printf "\nERROR: \"./cvt-cmd-4-screen.sh %s\" failed!\n" "${CVT_CMD_FILE}"
    exit 1 
fi  
#
./file-cmd-2-screen.sh ${CVT_CMD_FILE} ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9}
if [ $? -ne 0 ] ; then
    printf "\nERROR: \"./file-cmd-2-screen.sh %s\" failed!\n" "${CVT_CMD_FILE}"
    exit 2 
fi  

