#!/bin/bash
#

DEST_SCR_WINDOW="" 
CMD_DELAY_SEC=2
LINE_NUM=0

if [ -z "${1}" ] ; then 
    echo -e "\nERROR: please specify input filename\n" 
    exit 1
fi 

if [ ! -z "${2}" ] ; then 
    DEST_SCR_WINDOW="${2}"         
fi 

INPUT_CMD_FILE="${1}"
 
if [ ! -f  ${INPUT_CMD_FILE} ] ; then 
    echo -e "\nERROR: cannot find input file: ${INPUT_CMD_FILE}\n" 
    exit 2
fi  

LINE_NUM=0
while IFS= read -r line_read
do
    LINE_NUM=$((LINE_NUM+1))
#
# without xargs, cmd file need "\\\$" instead of "\\$", not sure why?  
#
    line=`printf "%s\n" ${line_read} | xargs`
    ./send-cmd-2-screen.sh "${line}" "${DEST_SCR_WINDOW}"
    if [ $? -ne 0 ] ; then 
       echo -e "\nERROR: LINE #${LINE_NUM}, send '${line_read}' failed!\n"
       exit 3
    fi 
    sleep ${CMD_DELAY_SEC}
done < "${INPUT_CMD_FILE}"


