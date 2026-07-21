#!/bin/bash

set -a
. credentials
set +a

for count in 1 2 5 10; do
  for ((i=1; i<=count; i++)); do
    curl https://loadtester.home.chitzu.ro/burn -u $USER:$PASS &
  done
  wait
  sleep 35
done