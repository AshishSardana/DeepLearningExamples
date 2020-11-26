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

precision_mode=${1:-"FP32"}
saved_model_dir=${2:-"./triton/model/saved_model/nvidia_rn50_tf_amp"}
export_tftrt_dir=${3:-"./triton/model/tftrt/"}

ARGS="\
   --precision_mode ${precision_mode} \
   --saved_model_dir ${saved_model_dir} \
   --export_tftrt_dir ${export_tftrt_dir}"

docker run -it --rm --runtime=nvidia -v $PWD:/resnet50 bert python /resnet50/triton/scripts/export_model.py ${ARGS}
#docker run -it --rm --runtime=nvidia -v $PWD:/resnet50 bert ls /resnet50/triton/scripts/