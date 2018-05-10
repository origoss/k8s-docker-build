#!/bin/bash

if [ -z "${1}" ]; then
    echo "Usage: ${0} <JOB_NAME>"
    exit 1
fi

uid=$(kubectl get job "${1}" --template="{{.metadata.uid}}") || exit 2

pods=$(kubectl get pods -l controller-uid="${uid}" --no-headers -o custom-columns=NAME:.metadata.name)

for pod in "${pods}"
do
    echo "-----------------------------------------------------------"
    echo "Logs of ${pod}"
    kubectl logs "${pod}"
done
