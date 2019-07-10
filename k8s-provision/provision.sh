#! /usr/bin/env bash

DIR=$(dirname $0)

kubectl create secret generic realm-secret --from-file=${DIR}/waes-realm.json
helm install --name keycloak -f ${DIR}/keycloak-chart-values.yaml stable/keycloak
