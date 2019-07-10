#! /usr/bin/env bash

DIR=$(dirname ${0})

kubectl create secret generic config-secret --from-file=${DIR}/../config/staging.json
kubectl apply -f ${DIR}/waes-ta-deployment.yaml
kubectl apply -f ${DIR}/waes-ta-service.yaml

