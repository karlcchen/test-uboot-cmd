#!/bin/bash
#

DEST_SCR_WINDOW1="" 
CMD_DELAY_SEC=2
LINE_NUM=0

if [ -z "${1}" ] ; then 
    echo -e "\nERROR: please specify input filename\n" 
    exit 1
fi 

if [ -z "${2}" ] ; then 
    printf "\nERROR: need screen's destination windows input as 2nd argument!\n"
else
    DEST_SCR_WINDOW1="${2}"         
fi 

INPUT_CMD_FILE="${1}"
 
if [ ! -f  ${INPUT_CMD_FILE} ] ; then 
    echo -e "\nERROR: cannot find input file: ${INPUT_CMD_FILE}\n" 
    exit 2
fi  

BOARD_NAME_ARRAY[0]=""
BOARD_NAME_ARRAY[1]=""
BOARD_NAME_ARRAY[2]=""
BOARD_NAME_ARRAY[3]=""
BOARD_NAME_ARRAY[4]=""
BOARD_NAME_ARRAY[5]=""
BOARD_NAME_ARRAY[6]=""
BOARD_NAME_ARRAY[7]=""
BOARD_NAME_ARRAY[8]=""
BOARD_NAME_ARRAY[9]=""

SRC_LOG_FILE_ARRAY[0]=""
SRC_LOG_FILE_ARRAY[1]=""
SRC_LOG_FILE_ARRAY[2]=""
SRC_LOG_FILE_ARRAY[3]=""
SRC_LOG_FILE_ARRAY[4]=""
SRC_LOG_FILE_ARRAY[5]=""
SRC_LOG_FILE_ARRAY[6]=""
SRC_LOG_FILE_ARRAY[7]=""
SRC_LOG_FILE_ARRAY[8]=""
SRC_LOG_FILE_ARRAY[9]=""

WIN_INDEX=0
for CUR_WIN in ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} 
do
    SRC_LOG_FILE=~/uc-log/uc${CUR_WIN}/uc${CUR_WIN}.log
    if [ ! -f ${SRC_LOG_FILE} ] ; then 
        printf "\nERROR: Cannot find file: %s!\n" "${SRC_LOG_FILE}"
        exit 3
    fi 

    rm -f ${SRC_LOG_FILE}
    if [ $? -ne 0 ] ; then 
       echo -e "\nERROR: 'rm -f ${SRC_LOG_FILE}' failed!\n"
       exit 3
    fi 
    SRC_LOG_FILE_ARRAY[ ${WIN_INDEX} ]="${SRC_LOG_FILE}"
    WIN_INDEX=$((WIN_INDEX+1))
done

sleep 1
./send-cmd-2-screen.sh "\n" ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} 
if [ $? -ne 0 ] ; then 
   echo -e "\nERROR: send check to all screen windows failed!\n"
   exit 4
fi 
sleep 2

WIN_INDEX=0
for CUR_WIN in ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} 
do
#
    BOARD_NAME="`cat ${SRC_LOG_FILE_ARRAY[ ${WIN_INDEX} ]} | tail -n1`"
    # remove last three chars 
    BOARD_NAME="${BOARD_NAME::-3}"
#
    BOARD_NAME_ARRAY[ ${WIN_INDEX} ]="${BOARD_NAME}"
    WIN_INDEX=$((WIN_INDEX+1))
done

WIN_INDEX=0
printf "\n=== INFO of screen Board Name and Log Filename: ===\n"
for CUR_WIN in ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} 
do
    printf "Screen Window Number:%d, BOARD_NAME:\"%s\", LOG_FILE:\"%s\"\n" ${WIN_INDEX} "${BOARD_NAME_ARRAY[ ${WIN_INDEX} ]}" "${SRC_LOG_FILE_ARRAY[ ${WIN_INDEX} ]}"
    WIN_INDEX=$((WIN_INDEX+1))
done

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
            if [ "${ARG1}" = "#@" ] ; then 
                WIN_INDEX=0
                for CUR_WIN in ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9}
                do
         	b_do_line=0  
   		if [ "${ARG2}" = "IF_board_name" ] ; then 
   		    if [[ ( "${ARG3}" = "not" || "${ARG3}" = "!" ) ]] ; then 
   			if [ ! "${ARG4}" = "${BOARD_NAME_ARRAY[ ${WIN_INDEX} ]}" ] ; then 
   			    # printf "%s\n"  "${ARG_REMAIN}"
   			    line="`printf "%s\n" "${ARG_REMAIN}"`"
   			    b_do_line=1
   			fi
   		    elif [ "${ARG3}" = "${BOARD_NAME_ARRAY[ ${WIN_INDEX} ]}" ] ; then 
   			# printf "%s %s\n" "${ARG3}" "${ARG_REMAIN}"
   			line="`printf "%s %s\n" "${ARG4}" "${ARG_REMAIN}"`"
   			b_do_line=1
   		    fi      
                    elif [ "${ARG2}" = "SHELL_host_cmd" ] ; then 
   		        SHELL_CMD="${ARG3} ${ARG4} ${ARG_REMAIN}"
   		        printf "\nINFO: #@ SHELL_host_cmd: %s\n" "${SHELL_CMD}"
   		        ${SHELL_CMD}
   		    fi 
                    if [ ${b_do_line} -eq 1 ] ; then 
                        ./send-cmd-2-screen.sh "${line}" ${CUR_WIN}
        	    fi 
                    WIN_INDEX=$((WIN_INDEX+1))
                done
	    fi 
        else 
            ./send-cmd-2-screen.sh "${line}" ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9}
            if [ $? -ne 0 ] ; then 
                echo -e "\nERROR: LINE #${LINE_NUM}, send '${line_read}' failed!\n"
                exit 6
            fi 
	fi 
        sleep ${CMD_DELAY_SEC}
    fi 
done < "${INPUT_CMD_FILE}"
