#!/bin/bash

readonly LOG_DIR=$1
readonly RESULT_FILE=$(mktemp)

function print_usage {
  echo "conc_b.log.helper.sh <log_folder>"
  exit -1
}

function analysis {
  echo "the folder is: ${LOG_DIR}"
  for file in $(find "${LOG_DIR}" -type f -name "*_oc_log.out");
  do
    echo "handling ${file}"
    local last_line
    last_line=$(tail -n 1 ${file})
    printf '%s\n' "${file}" >> "${RESULT_FILE}"
    printf '%s\n' "${last_line}" >> "${RESULT_FILE}"
  done
  echo "the result file is ${RESULT_FILE}"
}

if [[ "$#" -ne 1 || ! -d "${LOG_DIR}" ]]; then
  print_usage
fi
analysis
