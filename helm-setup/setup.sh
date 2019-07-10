#! /usr/bin/env bash

DIR=$(dirname ${0})

kubectl apply -f ${DIR}/rbac-config.yaml
helm init --service-account tiller --history-max 200
