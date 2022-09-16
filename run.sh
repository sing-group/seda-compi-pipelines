#!/bin/bash

docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /tmp:/tmp \
    -v "${1}:${1}" \
    pegi3s/seda-pipeline \
        /compi run -p pipeline.xml -o -r pipeline-runner.xml -- \
            --workingDirectory ${1}