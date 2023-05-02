#!/bin/bash

function message() {
	echo "[seda/pipeline-runner] [${task_id}] $1"
}

SEDA_OPERATION_NAME=$(echo ${task_id} | sed 's/_[0-9]*$//')

#
# Set the input files for the current task.
#
INPUT_LIST=$(mktemp /tmp/seda.${task_id}.XXXXX)
TASK_AFTER=$(env | grep "^task_after" | sed 's/^task_after*=//')
if [ -z "${TASK_AFTER}" ]; then
	ls ${workingDirectory}/${input}/${task_id}/* > ${INPUT_LIST}
else
	for TASK in ${TASK_AFTER}; do 
		ls ${workingDirectory}/${output}/${TASK}/* > ${INPUT_LIST}
	done
fi

#
# Divide the current list of input files in batches if batchSize is set for the current task.
#
INPUT_BATCHES_DIR=$(mktemp -d /tmp/seda.${task_id}.batches.XXXXX)
task_id_for_batch_size=$(echo ${task_id} | sed 's#-#_#g')
TASK_BATCH_SIZE=$(env | grep -i "^batchSize_${task_id_for_batch_size}" | sed 's/^batchSize.*=//')

if [ -z "${TASK_BATCH_SIZE}" ]; then
	message "Batch size not specified, processing all files at once."
	cp ${INPUT_LIST} ${INPUT_BATCHES_DIR}/all
else
	message "Batch size is ${TASK_BATCH_SIZE}, create batches."
	${script_create_batches} ${INPUT_LIST} ${INPUT_BATCHES_DIR} ${TASK_BATCH_SIZE}
fi

#
# Set the curent task parameters.
#
if [ -f "${workingDirectory}/${paramsDir}/${task_id}.cliParams" ]; then
	CLI_PARAMS=$(head -1 ${workingDirectory}/${paramsDir}/${task_id}.cliParams | tr -d '\n' | tr -d '\r')
fi

if [ -f "${workingDirectory}/${paramsDir}/${task_id}.sedaParams" ]; then
	PARAMS="${CLI_PARAMS} --parameters-file ${workingDirectory}/${paramsDir}/${task_id}.sedaParams"
else
	PARAMS="${CLI_PARAMS}"
fi

OUTPUT=${workingDirectory}/${output}/${task_id}

mkdir -p ${OUTPUT}

#
# Run the SEDA command for each batch file.
#
for BATCH_FILE in $(ls ${INPUT_BATCHES_DIR}/*); do
	message "Running ${sedaCli} ${SEDA_OPERATION_NAME} -il ${BATCH_FILE} -od ${OUTPUT} ${PARAMS}"
	${sedaCli} ${SEDA_OPERATION_NAME} -il ${BATCH_FILE} -od ${OUTPUT} ${PARAMS}
done
