import sys
import requests
import time
import datetime
import subprocess

# Constants
BASH = "/bin/bash"
LS = "ls"

POWER_UP = "POWER UP"
POWER_DOWN = "POWER DOWN"
POWER_FAILURE = "POWER FAILURE"

HEADERS = {
    "cache-control": "no-cache",
}

# Debug
def debug(message):

    unused = 0
    #log("DEBUG >> " + message)

# Log
def log(message):

    print(str(datetime.datetime.fromtimestamp(time.time())) + " " + message, flush = True)

# Main
def main(url, checkIntervalMs, runtimeMs, shutdownScript):

    log("starting...")
    log("  url = [" + url + "]")
    log("  checkIntervalMs = [" + str(checkIntervalMs) + "]")
    log("  runtimeMs = [" + str(runtimeMs) + "]")
    debug("  shutdownScript = [" + shutdownScript + "]")

    previousStatus = ""
    shutdownAtTimeMs = time.time() * 1000.0 + runtimeMs

    log("running...")

    while ((time.time() * 1000.0) < shutdownAtTimeMs):

        statusChange = False

        try:

            response = requests.request("GET", url, headers = HEADERS)
            statusCode = response.status_code
            debug("statusCode = [" + str(statusCode) + "]")

            currentStatus = response.text.strip()
            debug("currentStatus = [" + currentStatus + "]")

            if statusCode != 200:

                currentStatus = POWER_FAILURE

            if currentStatus != POWER_UP and currentStatus != POWER_DOWN:

                currentStatus = POWER_FAILURE

        except Exception as e:

            currentStatus = POWER_FAILURE

            if currentStatus != previousStatus:

                log("exception getting status, [" + str(e) + "]")

        debug("previousStatus = [" + previousStatus + "]")
        debug("currentStatus = [" + currentStatus + "]")

        if currentStatus != previousStatus:

            statusChange = True

        debug("statusChange = [" + str(statusChange) + "]")

        if statusChange == True:

            log("status = [" + currentStatus + "]")

        if currentStatus == POWER_UP:

            if statusChange == True and previousStatus == POWER_FAILURE:

                log("shutdown canceled")

            shutdownAtTimeMs = (time.time() * 1000.0) + runtimeMs

        elif currentStatus == POWER_DOWN:

            shutdownAtTimeMs = 0

        else:

            if statusChange == True:

                log("shutdown scheduled at " + str(datetime.datetime.fromtimestamp(shutdownAtTimeMs / 1000.0)))

        previousStatus = currentStatus
        time.sleep(checkIntervalMs / 1000)

    log("running shutdown script...")

    result = subprocess.run([BASH, shutdownScript], stdout = subprocess.PIPE)
    buffer = result.stdout.splitlines()

    for i in buffer:

        log(i.decode("utf-8"))

if __name__ == '__main__':

    argumentCount = len(sys.argv)

    if argumentCount != 5:
        log("Usage: python3 " + sys.argv[0] + " <URL> <CHECK_INTERVAL_MS> <RUNTIME_MS> <SHUTDOWN_SCRIPT>");
        exit(1)

    url = sys.argv[1]
    checkIntervalMs = int(sys.argv[2])
    runtimeMs = int(sys.argv[3])
    shutdownScript = sys.argv[4]

    main(url, checkIntervalMs, runtimeMs, shutdownScript)