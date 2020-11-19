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

MODEL_NAME=${1:-"resnet50"}
MODEL_VERSION=${2:-1}
BATCH_SIZE=${3:-1}
MAX_LATENCY=${4:-100}
MAX_CLIENT_THREADS=${5:-10}
MAX_CONCURRENCY=${6:-50}
SERVER_HOSTNAME=${7:-"localhost"}

if [[ $SERVER_HOSTNAME == *":"* ]]; then
  echo "ERROR! Do not include the port when passing the Server Hostname. These scripts require that the TRITON HTTP endpoint is on Port 8000 and the gRPC endpoint is on Port 8001. Exiting..."
  exit 1
fi

TIMESTAMP=$(date "+%y%m%d_%H%M")

bash triton/scripts/launch.sh mkdir -p /results/perf_client_tfs/${MODEL_NAME}
OUTPUT_FILE_CSV="/results/perf_client_tfs/${MODEL_NAME}/results_${TIMESTAMP}.csv"

ARGS="\
   --max-threads ${MAX_CLIENT_THREADS} \
   -m ${MODEL_NAME} \
   -p 200000 \
   -d \
   -v -z \
   -i gRPC \
   -u ${SERVER_HOSTNAME}:8500 \
   -l ${MAX_LATENCY} \
   -c ${MAX_CONCURRENCY} \
   -f ${OUTPUT_FILE_CSV} \
   -b ${BATCH_SIZE} \
   --service-kind tfserving"

echo "Using args:  $(echo "$ARGS" | sed -e 's/   -/\n-/g')"

bash triton/scripts/launch.sh /workspace/resnet50/perf_analyzer $ARGS
