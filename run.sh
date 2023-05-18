#!/bin/bash

WORKING_DIR=${1}
COMPI_PARAMS=${2:-""}

function info() {
    tput setaf 2
	echo -e "[INFO] [run.sh] ${1}"
	tput sgr0
}

function show_error() {
	tput setaf 1
	echo -e "${1}"
	tput sgr0
}

if [ $# -ne 1 ] && [ $# -ne 2 ]; then
	show_error "[ERROR]: This script requires one or two arguments (working directory and, optionally, Compi CLI parameters)"
	exit 1
fi

info "Running SEDA-Compi pipeline at ${WORKING_DIR}"

PIPELINE_PARAMS_FILE=""
if [ -f "${WORKING_DIR}/compi.params" ]; then
    PIPELINE_PARAMS_FILE="--params ${WORKING_DIR}/compi.params"
    info "Pipeline parameters found at ${WORKING_DIR}/compi.params"
fi

DOCKER_ENV_PARAMS=""
if [ ! -z "${SEDA_JAVA_MEMORY}" ]; then
    DOCKER_ENV_PARAMS="-e SEDA_JAVA_MEMORY=${SEDA_JAVA_MEMORY}"
    info "Docker environment parameters: ${DOCKER_ENV_PARAMS}"
fi

docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /tmp:/tmp \
    -v "${WORKING_DIR}:${WORKING_DIR}" \
    -w "${WORKING_DIR}" \
    ${DOCKER_ENV_PARAMS} \
    test/seda-cli-pipeline \
        /compi run -p /pipeline.xml -o -r /pipeline-runner.xml ${COMPI_PARAMS} ${PIPELINE_PARAMS_FILE} -- \
            --workingDirectory ${WORKING_DIR}
