#!/bin/bash

set-paths () {
    CheckAvail="{{ MY DOMAIN }}"
    Paths=("smb://{{ SRVR }}/{{ SHARENAME }}") 
    Paths+=("smb://{{ ANOTHER }}/home$/{{ ONE }}") #Home-Share

    export Paths
    export CheckAvail
}

check-connection () {
    ping -c3 1.1.1.1 > /dev/null 2>&1 && {
        ping -c3 $CheckAvail > /dev/null 2>&1 && {
            echo "Connected to the right network, mounting drives."
        } || {
            CNT=$(( $CNT + 1 ))
            echo "Wrong network, try #${CNT}."
            
            [[ $CNT -eq 3 ]] && {
                exit 0
            }

            sleep 3
            CNT=$CNT check-connection
        }
    } || {
        echo "No internet-connection available, trying again in 5 seconds!"
        sleep 5
        check-connection
        exit
    }
}

mount-drives () {
    for i in ${!Paths[@]}
    do 
        gio mount ${Paths[$i]} > /dev/null 2>> /tmp/drive-mount.log
        [[ $? -eq 0 ]] && {
            echo "Mounted ${Paths[$i]} successfully!"
        } || {
            echo "An error occured while mounting ${Paths[$i]}."
            local Sharerr${i}=1
        }
    done

    local | grep "Sharerr" | grep -v "=0" >/dev/null 2>&1 && {
        echo "Some drive(s) mounted with errors."
        exit 1
    } || {
        echo "All Drives mounted successfully!"
        rm -rf /tmp/drive-mount.log 2> /dev/null
    }
}

echo "Waiting for the internet connection to establish."
sleep 3

CNT=0
set-paths
check-connection
mount-drives
