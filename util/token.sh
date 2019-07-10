#! /usr/bin/env bash

HOST=$1

export TOKEN=$(curl -s            \
  --data "grant_type=password"    \
  --data "client_id=waes-client"  \
  --data "username=tester"        \
  --data "password=t3ster"        \
  http://${HOST}/auth/realms/waes/protocol/openid-connect/token | jq -r .access_token)
