#!/bin/bash

TIMEOUT=10                   # (int) seconds
COMMAND=""                   # arguments to append to ${BASE_BINARY}
BASE_BINARY="/sbin/iptables" # [/sbin/iptables|/sbin/iptables6]

TMP_CFG="./iptables-tmp.rules"
NEW_TMP_CFG="./iptables-new-tmp.rules"

INVOKED_CMD=$0

usage() {
  echo "Usage: ${INVOKED_CMD} [-t <timeout_integer(seconds)>] [-b </sbin/iptables|/sbin/iptables6>] -c <arguments_for_iptables>" 1>&2;
  echo "Example: ${INVOKED_CMD} -t 30 -b /sbin/iptables -c \"-A INPUT -s 123.123.123.123 -j DENY\"";
  exit 1;
}

while getopts ":t:c:b:" o; do
    case "${o}" in
        t)
            TIMEOUT=${OPTARG}
            [[ ! "${TIMEOUT}" =~ ^[0-9]+$ ]] && usage
            ;;
        c)
            COMMAND=${OPTARG}
            ;;
        b)
            BASE_BINARY=${OPTARG}
            if [[ "${BASE_BINARY}" != "/sbin/iptables" && "${BASE_BINARY}" != "/sbin/iptables6" ]] ; then
              usage
            fi
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [[ -z "${TIMEOUT}" || -z "${COMMAND}" || -z "${BASE_BINARY}" ]] ; then
    usage
fi

echo "[PARAMS]"
echo "TIMEOUT     = ${TIMEOUT} (ie. if no confirmation in ${TIMEOUT} seconds, rollsback iptables change"
echo "BASE_BINARY = ${BASE_BINARY}"
echo "COMMAND     = ${COMMAND}"
echo ""
echo "Entire Command To Execute: '${BASE_BINARY} ${COMMAND}'"

iptables-save > ${TMP_CFG}

eval "${BASE_BINARY} ${COMMAND}"
retCode=$?

if [[ retCode -ne 0 ]] ; then
    echo "Command '${BASE_BINARY} ${COMMAND}' returned RC${retCode}"
    exit 1
fi

echo ""
echo "[CHANGE ADDED]:"
iptables-save > ${NEW_TMP_CFG}
diff ${TMP_CFG} ${NEW_TMP_CFG} | awk '/> -/ { print }'
rm ${NEW_TMP_CFG}

echo "[y/N] to confirm changes [timeout: ${TIMEOUT}s]:"
read -t "${TIMEOUT}" ret 2>&1 || :
case "${ret:-}" in
        (y*|Y*)
                # Success
                echo "Successfully applied the configuration."
                rm ${TMP_CFG}
                exit 0
                ;;
        (*)
                # Failed
                echo
                if [ -z "${ret:-}" ]; then
                        echo "Timeout! Something happened (or did not). Rolling-back the change..."
                else
                        echo "You specified "${ret-}", so we are rolling-back the change"
                fi
                ${BASE_BINARY}-restore < ${TMP_CFG}
                rm ${TMP_CFG}
                exit 255
                ;;
esac
