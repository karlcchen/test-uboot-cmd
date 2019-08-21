#!/bin/bash
#

if [ -z "${1}" ] ; then 
    printf "\nERROR: no input found!\n"
    exit 1
fi 

CMD_STR="${1}"
#printf "cmd=%s\n" "${CMD_STR}"

if [ -z "${2}" ] ; then 
    printf "%s\n" "${CMD_STR}"
# note: screen stuff can interpreter "\n"
# but not normal shell var string, "${CMD_STR}\n" does not work !
    sudo screen -S usb-console -X stuff "${CMD_STR}\n"
    if [ $? -ne 0 ] ; then 
        printf "ERROR: send cmd=\"%s\" to active screen window failed!\n" "${CMD_STR}"
        exit 2
    fi
else 
    OUT_WINDOW="${2}"
    N_CMD=0 
    while [ ! -z "${OUT_WINDOW}" ] ; 
    do 
	N_CMD=$((N_CMD+1))
# note: screen "-X stuff" can interpreter "\n"
# but not normal shell var string, "${CMD_STR}\n" does not work !
        printf "c=%d,w=%d, %s\n" "${N_CMD}" "${OUT_WINDOW}" "${CMD_STR}"
	sudo screen -S usb-console -p "${OUT_WINDOW}" -X stuff "${CMD_STR}\n"
	if [ $? -ne 0 ] ; then 
	    printf "ERROR: send cmd=\"%s\" to screen window: \"%s\" failed!\n" "${CMD_STR}" "${OUT_WINDOW}" 
	    exit 3
	fi
	shift 1
	OUT_WINDOW="${2}"
    done
fi

