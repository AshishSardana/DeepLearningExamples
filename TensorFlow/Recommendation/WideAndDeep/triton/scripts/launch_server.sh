NV_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-"1"}
DETACHED=${DETACHED:-"-d"}

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
   -v $PWD/inference/models/:/models/ \
   nvcr.io/nvidia/tritonserver:davidg-master-py3-base-tf2cudnn8 tritonserver --model-store=/models  --log-verbose=1 --backend-config=tensorflow,version=2
   #nvcr.io/nvidia/tritonserver:20.09-py3 tritonserver --model-store=/models --log-verbose=1 --backend-config=tensorflow,version=2
   #gitlab-master.nvidia.com:5005/dl/dgx/tritonserver/20.11-cuda11-cudnn7 tritonserver --model-store=/models --log-verbose=1 --backend-config=tensorflow,version=2
   #nvcr.io/nvidia/tritonserver:20.09-py3 tritonserver --model-store=/models --strict-model-config=false --log-verbose=1 --backend-config=tensorflow,version=2
   # nvcr.io/nvidia/tritonserver:20.03-py3 trtserver --model-repository=/models --log-verbose=0
