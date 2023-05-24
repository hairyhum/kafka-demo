#!/usr/bin/env bash

set -ex
set -m

cat ${ENROLL_TOKEN}

## Weirdly, this command is idempotent
ockam identity create sidecar

## We check if node exists, but need to check if identity is authenticated,
## but there is no api for that
if [$(ockam node list | grep sidecar) = ""]; then
  ockam project authenticate ${ENROLL_TOKEN} --identity sidecar
else
  echo "Node exists"
fi

ockam node create sidecar --foreground -v --identity sidecar &

## To let the foreground node start
sleep 2

## To ping the node
ockam node list

ockam kafka-${ROLE} create -v --node sidecar --bootstrap-server ${BOOTSTRAP_SERVER} --project-route /dnsaddr/${OUTLET_HOST}/tcp/${OUTLET_PORT}

fg %1
