#!/bin/bash
#
UBOOT_CMD_FILE="${1}"
LINE_NUM=0
while IFS= read -r line_read
do
    LINE_NUM=$((LINE_NUM+1))
    line=`printf "%s\n" ${line_read} | xargs`
    if [ "${line}" != "" ] ; then 
	if [[ ${line} =~ ^#.* ]] ; then 
	    continue 
	fi 
        printf "\'@ %d, %s\'\n" ${LINE_NUM} "${line}" 
	./out-usb-console.sh "${line}"
	if [ $? -ne 0 ] ; then 
	    echo -e "\nERROR: LINE #${LINE_NUM}, send '${line}' failed!\n"
	    exit 1
	fi 
	sleep 3
    fi 
done < "${UBOOT_CMD_FILE}"
