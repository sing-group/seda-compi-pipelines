FROM pegi3s/utilities:0.22.0 as base_pegi3s_utilities

FROM pegi3s/seda:1.7.2

COPY --from=base_pegi3s_utilities /opt/scripts/create_batches /opt/scripts/create_batches

ADD image-files/compi.tar.gz /

ADD pipeline-runner/pipeline-runner.sh /opt/scripts/pipeline-runner.sh
ADD pipeline-runner/pipeline-runner.xml pipeline-runner.xml
ADD pipeline.xml /pipeline.xml
ADD task-scripts task-scripts

RUN chmod u+x /opt/scripts/*
RUN chmod u+x /task-scripts/*

ENV PATH="/opt/SEDA/:/opt/scripts/:${PATH}"
