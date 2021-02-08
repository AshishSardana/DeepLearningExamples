#!/bin/bash

# Copyright (c) 2019 NVIDIA CORPORATION. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

MODEL_NAME=${1:-"bert"}
MODEL_VERSION=${2:-1}
BATCH_SIZE=${3:-1}
MAX_LATENCY=${4:-100}
MAX_CLIENT_THREADS=${5:-10}
CONCURRENCY_RANGE=${6:-"1:1:1"}
SERVER_HOSTNAME=${7:-"localhost"}
SEQ_LEN=${8:-384}
BATCHING=${9:-false}
instance_count=${instance_count:-"uknwn"}

if [[ $SERVER_HOSTNAME == *":"* ]]; then
  echo "ERROR! Do not include the port when passing the Server Hostname. These scripts require that the TRITON HTTP endpoint is on Port 8000 and the gRPC endpoint is on Port 8001. Exiting..."
  exit 1
fi

if [ "$SERVER_HOSTNAME" = "localhost" ]
then
    if [ ! "$(docker inspect -f "{{.State.Running}}" tfs_server_cont_bert)" = "true" ] ; then

        echo "Launching TFS server"
        bash triton/scripts/launch_server_tfs.sh $BATCHING
        SERVER_LAUNCHED=true

        function cleanup_server {
            echo "Killing TFS server"
            docker kill tfs_server_cont_bert
        }

        # Ensure we cleanup the server on exit
        # trap "exit" INT TERM
        trap cleanup_server EXIT
    fi
fi

# Wait until server is up. Manual sleep of 15s
sleep 15

TIMESTAMP=$(date "+%y%m%d_%H%M")

bash scripts/docker/launch.sh mkdir -p /results/perf_client_tfs/${MODEL_NAME}
OUTPUT_FILE_CSV="/results/perf_client_tfs/${MODEL_NAME}/ic-${instance_count}_cc-${CONCURRENCY_RANGE}_bs-${BATCH_SIZE}_${TIMESTAMP}.csv"

ARGS="\
   -m ${MODEL_NAME} \
   -p 10000 \
   -v \
   -i gRPC \
   -u ${SERVER_HOSTNAME}:8510 \
   --concurrency-range ${CONCURRENCY_RANGE} \
   -f ${OUTPUT_FILE_CSV} \
   -b ${BATCH_SIZE} \
   --service-kind tfserving"

echo "Using args:  $(echo "$ARGS" | sed -e 's/   -/\n-/g')"

bash scripts/docker/launch.sh /workspace/bert/perf_analyzer $ARGS
