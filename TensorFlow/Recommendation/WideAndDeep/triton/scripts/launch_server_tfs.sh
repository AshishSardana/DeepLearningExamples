NV_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-"0"}
DETACHED=${DETACHED:-"-d"}

BATCHING=${1:-false}
ARGUMENTS=""

if [[ $BATCHING == true ]]; then
  # enable batching with specific params
  ARGUMENTS="--enable_batching --batching_parameters_file=$PWD/triton/batching_params_file_tfs"
  # only enable batching with no specific params
  #ARGUMENTS="--enable_batching"
fi

echo "Using args:  $(echo "$ARGUMENTS" | sed -e 's/   -/\n-/g')"

# Start TFS in DETACHED state
docker run --runtime=nvidia --rm $DETACHED \
   --shm-size=1g \
   --ulimit memlock=-1 \
   --ulimit stack=67108864 \
   -e MODEL_NAME=widedeep \
   -e "TF_FORCE_GPU_ALLOW_GROWTH = True" \
   -p8520:8500 \
   -p8521:8501 \
   -p8522:8502 \
   --name tfs_server_cont_wnd \
   -e NVIDIA_VISIBLE_DEVICES=$NV_VISIBLE_DEVICES \
   -v $PWD/triton/batching_params_file_tfs:$PWD/triton/batching_params_file_tfs \
   -v $PWD/inference/models/widedeep/1/model.savedmodel/:/models/widedeep/1/ \
   tensorflow/serving:2.4.0-gpu $ARGUMENTS
   #gitlab-master.nvidia.com:5005/dl/dgx/tritonserver/tensorflow_serving:version_1 $ARGUMENTS
