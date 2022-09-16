#!/bin/bash

WORKING_DIR=${1}
COMPI_PARAMS=${2:-""}

docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /tmp:/tmp \
    -v "${WORKING_DIR}:${WORKING_DIR}" \
    pegi3s/seda-pipeline \
        /compi run -p pipeline.xml -o -r pipeline-runner.xml ${COMPI_PARAMS} -- \
            --workingDirectory ${WORKING_DIR}