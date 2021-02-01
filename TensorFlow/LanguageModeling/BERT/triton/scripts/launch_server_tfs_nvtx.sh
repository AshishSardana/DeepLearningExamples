NV_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-"all"}
DETACHED=${DETACHED:-"-it"}

BATCHING=${1:-false}
OUTPUT=${2:-"tfs_tf_fp32_bs1_batchingFalse"}
ARGUMENTS=""

if [[ $BATCHING == true ]]; then
  # enable batching with a specific batch_size and num_threads
  #ARGUMENTS="--enable_batching --batching_parameters_file=$PWD/triton/batching_params_file_tfs"
  # only enable batching with no specific params
  ARGUMENTS="--enable_batching"
fi

echo "Using args:  $(echo "$ARGUMENTS" | sed -e 's/   -/\n-/g')"
echo "The nsys profile will be saved at $PWD/nsys/$(echo "$OUTPUT" | sed -e 's/   -/\n-/g')"

# Start TFS in DETACHED state
docker run --gpus $NV_VISIBLE_DEVICES --rm $DETACHED \
   --shm-size=1g \
   --ulimit memlock=-1 \
   --ulimit stack=67108864 \
   -e ARGUMENTS=$ARGUMENTS \
   -e OUTPUT=$OUTPUT \
   -p8500:8500 \
   -p8501:8501 \
   -p8502:8502 \
   -v $PWD/results/triton_models/bert/1/model.savedmodel/:/models/bert/1/ \
   -v $PWD/nsys:/nsys \
   gitlab-master.nvidia.com:5005/dl/dgx/tritonserver/instrumented_tfs 
