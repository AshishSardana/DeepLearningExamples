NV_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-"1"}
DETACHED=${DETACHED:-"-d"}
OUTPUT=${OUTPUT:-"try"}
DURATION=${DURATION:-30}

echo "$DURATION"

# Start TRITON server in DETACHED state
docker run --runtime=nvidia --rm $DETACHED \
   --shm-size=1g \
   --ulimit memlock=-1 \
   --ulimit stack=67108864 \
   -p8000:8000 \
   -p8001:8001 \
   -p8002:8002 \
   --name triton_server_cont \
   -e NVIDIA_VISIBLE_DEVICES=$NV_VISIBLE_DEVICES \
   -v $PWD/results/triton_models:/models \
   -v $PWD/nsys:/nsys \
   gitlab-master.nvidia.com:5005/dl/dgx/tritonserver:instrumented-triton-devel nsys profile -t cuda,nvtx,cudnn --delay=10 --duration=$DURATION --force-overwrite true --output /nsys/$OUTPUT tritonserver --model-store=/models  --log-verbose=0 --strict-model-config=false --backend-config=tensorflow,version=2
   #nvcr.io/nvidia/tritonserver:20.09-py3 tritonserver --model-store=/models --log-verbose=0 --strict-model-config=false --backend-config=tensorflow,version=2 
   #gitlab-master.nvidia.com:5005/dl/dgx/tritonserver/20.11-cuda11-cudnn7:latest tritonserver --model-store=/models --strict-model-config=false --log-verbose=1 --backend-config=tensorflow,version=2
