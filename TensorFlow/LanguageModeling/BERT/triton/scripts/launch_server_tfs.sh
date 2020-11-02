NV_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-"all"}
DETACHED=${DETACHED:-"-d"}

# Start TRITON server in DETACHED state
# TFS 8500 mapped to TRITON Client 8001 for GRPC requests
# TFS 8501 mapped to TRITON Client 8000 for HTTP requests
docker run --gpus $NV_VISIBLE_DEVICES --rm $DETACHED \
   --shm-size=1g \
   --ulimit memlock=-1 \
   --ulimit stack=67108864 \
   -p8001:8500 \
   -p8000:8501 \
   -p8502:8502 \
   --name tfs_server_cont \
   -e NVIDIA_VISIBLE_DEVICES=$NV_VISIBLE_DEVICES \
   -e MODEL_NAME=bert \
   -v $PWD/results/triton_models/bert:/models/bert \
   tensorflow/serving &
