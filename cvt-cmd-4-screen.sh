#!/bin/bash
#

DEST_SCR_WINDOW=0 
CMD_DELAY_SEC=2
UBOOT_CMD_FILE="${1}"
LINE_NUM=0
OUTPUT_CMD_FILE="temp_cvt_cmd_4_screen.txt"

if [ ! -z "$2" ] ; then 
    OUTPUT_CMD_FILE="${2}"
fi 

trim_line() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    echo -n "$var"
}
   
if [ -f "${OUTPUT_CMD_FILE}" ] ; then    
    read -p "WARNING: output file '${OUTPUT_CMD_FILE}' exists, overwrite? (Yes/No):" -n 1 -r
    echo  # (optional) move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
	exit 1
    fi
    rm ${OUTPUT_CMD_FILE}
fi 

while IFS= read -r line_read
do
    LINE_NUM=$((LINE_NUM+1))
    line=`trim_line ${line_read}` 
    if [ ! "${line}" = "" ] ; then 
	if [[ ${line} =~ ^#.* ]] ; then 
	    continue 
	fi 
#
# prefix "$" with "\\$"
# change begin/end of single-quote ' to \'
# change begin/end of double-quote ' to \"
# but do not convert both singel/double quotes on the same line !
#
#        echo ${line} | sed 's/\$/\\\\$/g' | sed "0,/'/s/'/\\\'/" | sed '0,/\"/s/\"/\\\"/' | rev | sed "0,/'/s/'/'\\\/" | sed '0,/\"/s/\"/\"\\/' | rev >>${OUTPUT_CMD_FILE}
        echo ${line} | sed 's/\$/\\\\$/g' | sed "0,/'/s/'/\\\'/" | sed 's/\"/\\\"/g' | rev | sed "0,/'/s/'/'\\\/" | rev >>${OUTPUT_CMD_FILE}
#        echo ${line} | sed 's/\$/\\\\$/g' | sed "0,/'/s/'/\\\'/" | rev | sed "0,/'/s/'/'\\\/" | rev >>${OUTPUT_CMD_FILE}
	if [ $? -ne 0 ] ; then 
	    echo -e "\nERROR: LINE #${LINE_NUM}, process '${line}' failed!\n"
	    exit 3
	fi 
    fi 
done < "${UBOOT_CMD_FILE}"

printf "\n=== INFO: file: '%s' generated ===\n" ${OUTPUT_CMD_FILE}

