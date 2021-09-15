#!/bin/bash

# Rudimentary install script, doesn't handle paths with spaces

export POWERMON_DIRECTORY="/opt/powermon"
export POWERMON_D_DIRECTORY="/etc/powermon.d"
export POWERMON_ENV="/etc/powermon.env"
export POWERMON_SERVICE="/etc/systemd/system/powermon.service"

WHOAMI=`whoami`

echo "checking we are root"
if [ "${WHOAMI}" != "root" ]
then
  echo "install requires being root"
  exit 1
fi

echo "checking for python3"
command -v python3 >/dev/null 2>&1
if [ ! "$?" == "0" ]
then
  echo "python3 is required"
  exit 1
fi

PYTHON3=`which python3`

echo "checking for ${POWERMON_SERVICE}"
if [ -f "${POWERMON_SERVICE}" ]
then
  echo "stopping powermon"
  systemctl stop powermon > /dev/null 2>&1

  echo "disabling powermon"
  systemctl disable powermon > /dev/null 2>&1
fi

echo "checking for ${POWERMON_DIRECTORY}"
if [ ! -d "${POWERMON_DIRECTORY}" ]
then
  echo "creating ${POWERMON_DIRECTORY}"
  mkdir -p "${POWERMON_DIRECTORY}"
else
  echo "${POWERMON_DIRECTORY} exists"
fi

echo "checking for ${POWERMON_D_DIRECTORY}"
if [ ! -d "${POWERMON_D_DIRECTORY}" ]
then
  echo "creating ${POWERMON_D_DIRECTORY}"
  mkdir -p "${POWERMON_D_DIRECTORY}"
else
  echo "${POWERMON_D_DIRECTORY} exists"
fi

echo "checking for ${POWERMON_ENV}"
if [ -f "${POWERMON_ENV}" ]
then
  echo "${POWERMON_ENV} exists"
else
  echo "creating default ${POWERMON_ENV}"
  \cp env/powermon.env "${POWERMON_ENV}"
fi

echo "copying src/powermon.sh to ${POWERMON_DIRECTORY}/powermon.sh"
\cp src/powermon.sh "${POWERMON_DIRECTORY}"
chmod u+x "${POWERMON_DIRECTORY}/powermon.sh"

echo "copying src/powermon.fg.sh to ${POWERMON_DIRECTORY}/powermon.fg.sh"
\cp src/powermon.fg.sh "${POWERMON_DIRECTORY}"
chmod u+x "${POWERMON_DIRECTORY}/powermon.fg.sh"

echo "copying src/powermon.py to ${POWERMON_DIRECTORY}/powermon.py"
\cp src/powermon.py "${POWERMON_DIRECTORY}"
chmod ugo-x "${POWERMON_DIRECTORY}/powermon.py"

echo "checking for ${POWERMON_D_DIRECTORY}/powermon.shutdown.sh"
if [ -f  "${POWERMON_D_DIRECTORY}/powermon.shutdown.sh" ]
then
  echo "${POWERMON_D_DIRECTORY}/powermon.shutdown.sh exists"
else
  echo "copying src/powermon.shutdown.sh to ${POWERMON_D_DIRECTORY}/powermon.shutdown.sh"
  \cp src/powermon.shutdown.sh "${POWERMON_D_DIRECTORY}"
  chmod u+x "${POWERMON_D_DIRECTORY}/powermon.shutdown.sh"
fi

echo "copying src/powermon.service to /etc/systemd/system/powermon.service"
\cp src/powermon.service /etc/systemd/system/

# Get the path to python3
PYTHON3=`which python3`

# Reload systemd
echo "reloading systemd"
systemctl daemon-reload

echo ""
echo "----"
echo "DONE"
echo "----"
echo ""
echo "Next steps..."
echo ""
echo "1) Edit ${POWERMON_ENV} to change defaults"
echo "2) Edit /etc/powermon.d/powermon.shutdown.sh"
echo "3) Enable powermon (systemctl enable powermon.service)"
echo "4) Start powermon (systemctl start powermon.service)"
echo ""
