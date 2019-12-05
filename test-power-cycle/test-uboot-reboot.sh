#!/bin/bash
#
#

SCR_NUM=1
POWER_NUM=1

SCR_LOG_PATH="/home/kchen/uc-log/"
SCR_LOG_FILE="${SCR_LOG_PATH}/uc${SCR_NUM}/uc${SCR_NUM}.log"
TEST_LOG_FILE="${SCR_LOG_PATH}/uc${SCR_NUM}/power-cycle-boot-failure-uc${SCR_NUM}.log"
COUNT=0
OFF_TIME=4
ON_TIME=16
OK_MSG="Hit any key to stop autoboot:"

while [ true ] ;
do 
    COUNT=$((COUNT+1))
    printf "Test Loop=%d\n" "${COUNT}"
    rm -f ${SCR_LOG_FILE}
    if [ $? -ne 0 ] ; then 
        printf "ERROR: rm %s failed at loop=%d\n" "${SCR_LOG_FILE}" ${COUNT}
        exit 1
    fi 
    lpower off ${POWER_NUM} >/dev/null
    if [ $? -ne 0 ] ; then 
        printf "ERROR: lpower off failed at loop=%d\n" ${COUNT}
        exit 2
    fi 

    sleep ${OFF_TIME}  
    lpower on ${POWER_NUM} >/dev/null
    if [ $? -ne 0 ] ; then 
        printf "ERROR: lpower on failed at loop=%d\n" ${COUNT}
        exit 3
    fi 

    sleep ${ON_TIME} 
    cat "${SCR_LOG_FILE}" | grep "${OK_MSG}"
    if [ $? -ne 0 ] ; then 
        printf "ERROR: Test Failed at loop=%d\n" ${COUNT}
        DATE_STR=`date +"%m-%d-%y %H.%M.%S"`
        printf "ERROR: Test Failed at loop=%d, %s\n" ${COUNT} "${DATE_STR}" >>${TEST_LOG_FILE} 
        exit 9
    fi 
done
