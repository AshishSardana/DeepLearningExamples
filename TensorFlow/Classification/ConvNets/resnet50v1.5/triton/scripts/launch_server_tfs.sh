NV_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-"0"}
DETACHED=${DETACHED:-"-d"}

BATCHING=${1:-false}
ARGUMENTS=""

if [[ $BATCHING == true ]]; then
  # enable batching with a specific batch_size and num_threads
  #ARGUMENTS="--enable_batching --batching_parameters_file=$PWD/triton/batching_params_file_tfs"
  # only enable batching with no specific params
  ARGUMENTS="--enable_batching"
fi

echo "Using args:  $(echo "$ARGUMENTS" | sed -e 's/   -/\n-/g')"

# Start TFS in DETACHED state
docker run --runtime=nvidia --rm $DETACHED \
   --shm-size=1g \
   --ulimit memlock=-1 \
   --ulimit stack=67108864 \
   -e MODEL_NAME=resnet50 \
   -p8500:8500 \
   -p8501:8501 \
   -p8502:8502 \
   --name tfs_server_cont \
   -e NVIDIA_VISIBLE_DEVICES=$NV_VISIBLE_DEVICES \
   -v $PWD/triton/inference/resnet50/1/model.savedmodel/:/models/resnet50/1/ \
   tensorflow/serving:latest-gpu $ARGUMENTS