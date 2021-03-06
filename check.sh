#!/bin/bash

totalresult=0

myos=$(uname -s)
case "${myos}" in
    Linux*) echo -n "Check encrypted swap... "
            # Check if swaping is enabled, if not then there's no need to encrypt
            if [ -n "$(swapon --show)" ]
            then
                swapon --show | grep -q "/dev/dm-"
                result=$?
            else
                result=0
            fi

            if [ ${result} -eq 0 ]
            then
                echo "OK"
            else
                echo "FAILED"
                totalresult=1
            fi

            echo -n "Check /tmp on tmpfs...  "
            df /tmp | grep -q "^tmpfs\\s"
            result=$?
            if [ ${result} -eq 0 ]
            then
                echo "OK"
            else
                echo "FAILED"
                totalresult=1
            fi

            echo -n "Check encrypted home... "
            df /home | grep -q "^/dev/mapper/crypthome\\s"
            result=$?
            if [ ${result} -eq 0 ]
            then
                echo "OK"
            else
                echo "FAILED"
                totalresult=1
            fi

            exit ${totalresult}
            ;;
    Darwin*) if [[ $(id -u) -ne 0 ]]; then
                echo "Please run as root"
                exit 1
            fi

            echo -n "Check FileVault... "
            fdesetup status | grep -qi "FileVault is On"
            result=$?
            if [ ${result} -eq 0 ]; then
                echo "OK"
            else
                echo "FAILED"
                totalresult=1
            fi

            echo -n "Check firmware password... "
            firmwarepasswd -check | grep -qi "Password Enabled: Yes"
            result=$?
            if [ ${result} -eq 0 ]; then
                echo "OK"
            else
                echo "FAILED"
                totalresult=1
            fi

            echo -n "Check System Integrity Protection... "
            csrutil status |grep -qi "System Integrity Protection status: enabled"
            result=$?
            if [ ${result} -eq 0 ]; then
                echo "OK"
            else
                echo "FAILED"
                totalresult=1
            fi

            exit ${totalresult}
            ;;
    *)      echo "Unknown OS"
            exit 1
            ;;
esac
