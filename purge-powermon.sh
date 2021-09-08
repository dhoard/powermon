#!/bin/bash

# Rudimentary uninstall script, doesn't handle paths with spaces

export POWERMON_DIRECTORY="/opt/powermon"
export POWERMON_D_DIRECTORY="/etc/powermon.d"
export POWERMON_ENV="/etc/powermon.env"
export POWERMON_SERVICE="/etc/systemd/system/powermon.service"

function yes_or_no {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0;;
            [Nn]*) echo "Uninstall aborted" ; exit 0;;
        esac
    done
}

if [ ! "$1" == "--DANGER" ]
then
  echo "Uninstall powermon? THIS WILL REMOVE EVERYTHING... EVEN YOUR CUSTOM SCRIPTS IN ${POWERMON_D_DIRECTORY}"
  yes_or_no
fi

WHOAMI=`whoami`

echo "checking we are root"
if [ "${WHOAMI}" != "root" ]
then
  echo "uninstall requires being root"
  exit 1
fi

echo "checking for ${POWERMON_SERVICE}"
if [ -f "${POWERMON_SERVICE}" ]
then
  echo "stopping powermon"
  systemctl stop powermon > /dev/null 2>&1

  echo "disabling powermon"
  systemctl disable powermon > /dev/null 2>&1
fi

# Reload systemd
echo "reloading systemd"
systemctl daemon-reload

echo "removing ${POWERMON_SERVICE}"
rm -Rf "${POWERMON_SERVICE}"

echo "removing ${POWERMON_ENV}"
rm -Rf "${POWERMON_ENV}"

echo "removing ${POWERMON_D_DIRECTORY}"
rm -Rf "${POWERMON_D_DIRECTORY}"

echo "removing ${POWERMON_DIRECTORY}"
rm -Rf "${POWERMON_DIRECTORY}"

echo "removing /var/log/powermon.log"
rm -Rf /var/log/powermon.log

echo ""
echo "----"
echo "DONE"
echo "----"
