#!/bin/bash

if [ -z "${1}" ]; then
    echo "Usage: ${0} <JOB_NAME>"
    exit 1
fi

while :
do
    status=$(kubectl get job "${1}" --template='{{or .status.active "0"}} {{or .status.succeeded "0"}} {{or .status.failed "0"}}') || exit 2
    read active succeeded failed <<< "${status}"
    if [ "${succeeded}" -gt 0 ]; then
        echo "Success"
        exit 0
    fi
    if [ "${failed}" -gt 0 ]; then
        echo "Failure"
        exit 3
    fi
    echo "active: ${active}"
    sleep 1
done
