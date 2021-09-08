#!/bin/bash

POWERMON_ENV="/etc/powermon.env"
PYTHON3=`which python3`

if [ ! -f "${POWERMON_ENV}" ]; then
  echo "Required ${POWERMON_ENV} not found"
  exit 1
fi

source "${POWERMON_ENV}"

${PYTHON3} powermon.py "${URL}" "${CHECK_INTERVAL_MS}" "${RUNTIME_MS}" "${SHUTDOWN_SCRIPT}"
