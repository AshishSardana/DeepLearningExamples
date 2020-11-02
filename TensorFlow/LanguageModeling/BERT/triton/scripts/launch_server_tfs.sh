NV_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-"all"}
DETACHED=${DETACHED:-"-d"}

# Start TRITON server in DETACHED state
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
   tensorflow/serving:latest-gpu
