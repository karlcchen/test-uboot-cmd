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

USB_NUM=$((DEST_SCR_WINDOW-1))
SRC_LOG_FILE=~/uc-log/uc${DEST_SCR_WINDOW}/uc${DEST_SCR_WINDOW}.log
#SRC_LOG_FILE=~/screenlog/scr${DEST_SCR_WINDOW}/scr${DEST_SCR_WINDOW}.log
if [ ! -f ${SRC_LOG_FILE} ] ; then 
   printf "\nERROR: Cannot find file: %s!\n" "${SRC_LOG_FILE}"
   exit 3
fi 

rm -f ${SRC_LOG_FILE}
if [ $? -ne 0 ] ; then 
   echo -e "\nERROR: 'rm -f ${SRC_LOG_FILE}' failed!\n"
   exit 3
fi 

sleep 1
./send-cmd-2-screen.sh "\n" "${DEST_SCR_WINDOW}"
if [ $? -ne 0 ] ; then 
   echo -e "\nERROR: \'./send-cmd-2-screen.sh "\n" "${DEST_SCR_WINDOW}"\' failed!\n"
   exit 3
fi 
sleep 2

BOARD_NAME="`cat ${SRC_LOG_FILE} | tail -n1`"
# remove last three chars 
BOARD_NAME="${BOARD_NAME::-3}"
printf "INFO: found board: \"%s\"\n" "${BOARD_NAME}"

LINE_NUM=0
while IFS= read -r line_read
do
    LINE_NUM=$((LINE_NUM+1))
#
# without xargs, cmd file need "\\\$" instead of "\\$", not sure why?  
#
    line=`printf "%s\n" "${line_read}" | xargs`
#    line=`printf "%s\n" "${line_read}"`
    if [ ! -z "${line}" ] ; then 
        if [[ ${line} =~ ^#.* ]] ; then 
            ARG1="`echo "${line}" | awk '{print $1}'`"
	    ARG2="`echo "${line}" | awk '{print $2}'`"
	    ARG3="`echo "${line}" | awk '{print $3}'`"
	    ARG4="`echo "${line}" | awk '{print $4}'`"
	    ARG_REMAIN="`echo "${line}" | awk '{print $5 " " $6 " " $7 " " $8 " " $9}'`"
	    b_do_line=0  
            if [ "${ARG1}" = "#@" ] ; then 
		if [ "${ARG2}" = "IF_board_name" ] ; then 
		    if [[ ( "${ARG3}" = "not" || "${ARG3}" = "!" ) ]] ; then 
			if [ ! "${ARG4}" = "${BOARD_NAME}" ] ; then 
			    # printf "%s\n"  "${ARG_REMAIN}"
			    line="`printf "%s\n" "${ARG_REMAIN}"`"
			    b_do_line=1
			fi
		    elif [ "${ARG3}" = "${BOARD_NAME}" ] ; then 
			# printf "%s %s\n" "${ARG3}" "${ARG_REMAIN}"
			line="`printf "%s %s\n" "${ARG4}" "${ARG_REMAIN}"`"
			b_do_line=1
		    fi      
		elif [ "${ARG2}" = "SHELL_host_cmd" ] ; then 
		    SHELL_CMD="${ARG3} ${ARG4} ${ARG_REMAIN}"
		    printf "\nINFO: #@ SHELL_host_cmd: %s\n" "${SHELL_CMD}"
		    ${SHELL_CMD}
		fi 
	    fi 
	    if [ ${b_do_line} -eq 0 ] ; then 
		continue
	    fi 
	fi 
        ./send-cmd-2-screen.sh "${line}" "${DEST_SCR_WINDOW}"
        if [ $? -ne 0 ] ; then 
           echo -e "\nERROR: LINE #${LINE_NUM}, send '${line_read}' failed!\n"
           exit 3
        fi 
        sleep ${CMD_DELAY_SEC}
    fi 
done < "${INPUT_CMD_FILE}"
