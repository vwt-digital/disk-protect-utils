#!/bin/bash

totalresult=0

echo -n "Check encrypted swap... "

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
