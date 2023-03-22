#!/bin/bash

WORKING_DIR=${1}
COMPI_PARAMS=${2:-""}

function show_error() {
	tput setaf 1
	echo -e "${1}"
	tput sgr0
}

if [ $# -ne 1 ] && [ $# -ne 2 ]; then
	show_error "[ERROR]: This script requires one or two arguments (working directory and, optionally, Compi CLI parameters)"
	exit 1
fi

docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /tmp:/tmp \
    -v "${WORKING_DIR}:${WORKING_DIR}" \
    test/seda-cli-pipeline \
        /compi run -p pipeline.xml -o -r pipeline-runner.xml ${COMPI_PARAMS} -- \
            --workingDirectory ${WORKING_DIR}
