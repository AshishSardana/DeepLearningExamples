NV_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-"all"}
DETACHED=${DETACHED:-"-it"}

BATCHING=${1:-false}
ARGUMENTS=""

if [[ $BATCHING == true ]]; then
  ARGUMENTS="--enable_batching --batching_parameters_file=$PWD/triton/batching_params_file_tfs"
fi

echo "Using args:  $(echo "$ARGUMENTS" | sed -e 's/   -/\n-/g')"

# Start TFS in DETACHED state
docker run --gpus $NV_VISIBLE_DEVICES --rm $DETACHED \
   --shm-size=1g \
   --ulimit memlock=-1 \
   --ulimit stack=67108864 \
   -e MODEL_NAME=bert \
   -p8500:8500 \
   -p8501:8501 \
   -p8502:8502 \
   --name tfs_server_cont \
   -v $PWD/results/triton_models/bert/1/model.savedmodel/:/models/bert/1/ \
   tensorflow/serving:latest-gpu $ARGS
