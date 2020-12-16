#!/bin/bash

CHECKPOINT_PATH=${1:-"./triton/model"}
EXPORT_SAVED_MODEL_DIR=${2:-"./triton/model/saved_model"} 
PRECISION=${3:-"FP16"} # CHANGE this to FP16 only if TRITON_FOR_TFTRT=true
TRANSFORMED_METADATA_PATH=${4:-"./outbrain/tfrecords"}
TRITON_FOR_TFTRT=${5:-"true"} # CHANGE this to true to use TFTRT optimized model in the above precision
EXPORT_TFTRT_MODEL_DIR=${6:-"./triton/model/tftrt"}

TRITON_FOR_SAVED_OR_TFTRT="./triton/model/saved_model" # default for saved model

cd /wide_deep_tf/

if [[ $TRITON_FOR_TFTRT == true ]]; then
  TRITON_FOR_SAVED_OR_TFTRT="./triton/model/tftrt"
fi

if [ ! "$(ls | grep -c triton)" -eq 1 ]; then
  echo "WARNING: run this script from root directory. Usage: bash ./triton/scripts/export_model.sh"
  #exit 1
fi

if [ ! -d ${CHECKPOINT_PATH} ] || [ ! "$(ls -A ${CHECKPOINT_PATH})" ]; then
  echo "Couldn't find checkpoint in ${CHECKPOINT_PATH}"
  exit 1
fi

# Install 1 missing package
# pip install tensorflow-transform==0.24.1

# Create hard directory and symlink with data for `export` to work
mkdir /outbrain
ln -s /wide_deep_tf/outbrain/tfrecords /outbrain/tfrecords

# Remove all previous exported models as the triton_config script chooses models based on random numbering
echo "Removing previous exported models from ./triton/models/ directory"
rm -rf ${EXPORT_SAVED_MODEL_DIR}
rm -rf ${EXPORT_TFTRT_MODEL_DIR}

python -m inference.utils.export_tf2 --precision_mode ${PRECISION} --checkpoint_dir ${CHECKPOINT_PATH} --export_saved_model_dir ${EXPORT_SAVED_MODEL_DIR} --export_tftrt_dir ${EXPORT_TFTRT_MODEL_DIR} --transformed_metadata_path ${TRANSFORMED_METADATA_PATH}

# Get all models, but use only one
files=("${TRITON_FOR_SAVED_OR_TFTRT}"/*)

if [ ${#files[@]} -eq 0 ]; then
  echo "No models found in ${TRITON_FOR_SAVED_OR_TFTRT}"
  exit 1
fi

python -m inference.utils.triton_config --export_dir="${files[0]}"

echo "Triton models directory created in $(pwd)/inference/models"

