#!/usr/bin/env bash
# Use this script to test if a given TCP host/port are available

WAITFORIT_cmdname=${0##*/}

echoerr() {
  if [[ "$WAITFORIT_QUIET" -ne 1 ]]; then
    printf "%s\n" "$*" 1>&2;
  fi
}

usage() {
  exitcode="$1"
  cat << USAGE >&2
Usage:
  $WAITFORIT_cmdname host:port [-s] [-t timeout] [-- command args]
  -h HOST | --host=HOST       Host or IP under test
  -p PORT | --port=PORT       TCP port under test
  -s | --strict               Only execute subcommand if the test succeeds
  -q | --quiet                Don't output any status messages
  -t TIMEOUT | --timeout=TIMEOUT
                              Timeout in seconds, zero for no timeout
  -- COMMAND ARGS             Execute command with args after the test finishes
USAGE
  exit "$exitcode"
}

wait_for() {
  if [[ "$WAITFORIT_TIMEOUT" -gt 0 ]]; then
    echoerr "$WAITFORIT_cmdname: waiting $WAITFORIT_TIMEOUT seconds for $WAITFORIT_HOST:$WAITFORIT_PORT"
  else
    echoerr "$WAITFORIT_cmdname: waiting for $WAITFORIT_HOST:$WAITFORIT_PORT without a timeout"
  fi
  start_ts=$(date +%s)
  while :
  do
    if [[ "$WAITFORIT_ISBUSY" -eq 1 ]]; then
      nc -z "$WAITFORIT_HOST" "$WAITFORIT_PORT"
      result=$?
    else
      (echo > /dev/tcp/"$WAITFORIT_HOST"/"$WAITFORIT_PORT") >/dev/null 2>&1
      result=$?
    fi
    if [[ "$result" -eq 0 ]]; then
      end_ts=$(date +%s)
      echoerr "$WAITFORIT_cmdname: $WAITFORIT_HOST:$WAITFORIT_PORT is available after $((end_ts - start_ts)) seconds"
      return 0
    fi
    sleep 1
    if [[ "$WAITFORIT_TIMEOUT" -gt 0 ]]; then
      now_ts=$(date +%s)
      if [[ $((now_ts - start_ts)) -ge "$WAITFORIT_TIMEOUT" ]]; then
        echoerr "$WAITFORIT_cmdname: timeout occurred after waiting $WAITFORIT_TIMEOUT seconds for $WAITFORIT_HOST:$WAITFORIT_PORT"
        return 1
      fi
    fi
  done
}

wait_for_wrapper() {
  # In order to support SIGINT during timeout: http://unix.stackexchange.com/a/57692
  if [[ "$WAITFORIT_QUIET" -eq 1 ]]; then
    timeout "$@" &> /dev/null &
  else
    timeout "$@" &
  fi
  WAITFORIT_PID=$!
  trap "kill -INT -$WAITFORIT_PID" INT
  wait $WAITFORIT_PID
  WAITFORIT_EXIT_CODE=$?
  trap - INT
  return $WAITFORIT_EXIT_CODE
}

# process arguments
while [[ $# -gt 0 ]]
do
  case "$1" in
    *:* )
    WAITFORIT_HOST=$(printf "%s\n" "$1" | cut -d : -f 1)
    WAITFORIT_PORT=$(printf "%s\n" "$1" | cut -d : -f 2)
    shift 1
    ;;
    -h | --host)
    WAITFORIT_HOST="$2"
    if [[ "$WAITFORIT_HOST" == "" ]]; then break; fi
    shift 2
    ;;
    -p | --port)
    WAITFORIT_PORT="$2"
    if [[ "$WAITFORIT_PORT" == "" ]]; then break; fi
    shift 2
    ;;
    -q | --quiet)
    WAITFORIT_QUIET=1
    shift 1
    ;;
    -s | --strict)
    WAITFORIT_STRICT=1
    shift 1
    ;;
    -t | --timeout)
    WAITFORIT_TIMEOUT="$2"
    if [[ "$WAITFORIT_TIMEOUT" == "" ]]; then break; fi
    shift 2
    ;;
    --)
    shift
    WAITFORIT_CLI=("$@")
    break
    ;;
    --help)
    usage 0
    ;;
    *)
    echoerr "Unknown argument: $1"
    usage 1
    ;;
  esac
done

if [[ "$WAITFORIT_HOST" == "" || "$WAITFORIT_PORT" == "" ]]; then
  echoerr "Error: you need to provide a host and port to test."
  usage 2
fi

WAITFORIT_TIMEOUT=${WAITFORIT_TIMEOUT:-15}
WAITFORIT_STRICT=${WAITFORIT_STRICT:-0}
WAITFORIT_QUIET=${WAITFORIT_QUIET:-0}

# Check to see if busybox timeout is available
if timeout --version >/dev/null 2>&1; then
  WAITFORIT_ISBUSY=0
else
  WAITFORIT_ISBUSY=1
fi

wait_for_wrapper wait_for "$WAITFORIT_HOST:$WAITFORIT_PORT"
WAITFORIT_RESULT=$?

if [[ "$WAITFORIT_CLI" != "" ]]; then
  if [[ $WAITFORIT_RESULT -ne 0 && $WAITFORIT_STRICT -eq 1 ]]; then
    echoerr "$WAITFORIT_cmdname: strict mode, refusing to execute subprocess"
    exit $WAITFORIT_RESULT
  fi
  exec "${WAITFORIT_CLI[@]}"
else
  exit $WAITFORIT_RESULT
fi
