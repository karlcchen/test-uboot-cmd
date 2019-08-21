#!/bin/bash
#

if [ -z "${2}" ] ; then 
    echo -e "${1}"
    sudo screen -S usb-console -X stuff "${1}\n"
    if [ $? -ne 0 ] ; then 
        echo -e "ERROR: send to screen failed!"
        exit 2
    fi
else 
    echo -e "${1}"
    sudo screen -S usb-console -p "${2}" -X stuff "${1}\n"
    if [ $? -ne 0 ] ; then 
        echo -e "ERROR: send to screen failed!"
        exit 2
    fi
fi
