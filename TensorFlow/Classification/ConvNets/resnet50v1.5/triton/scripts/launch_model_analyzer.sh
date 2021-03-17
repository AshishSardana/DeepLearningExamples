NV_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-"0"}
DETACHED=${DETACHED:-"-it"}

# Start TRITON server in DETACHED state
docker run --runtime=nvidia --rm $DETACHED \
   --shm-size=1g \
   --ulimit memlock=-1 \
   --ulimit stack=67108864 \
   --net=host \
   -e NVIDIA_VISIBLE_DEVICES=$NV_VISIBLE_DEVICES \
   -v $PWD:/workspace/examples \
   modelanalyzer model-analyzer -f /workspace/examples/triton/config_model_analyzer.yaml
   #nvcr.io/nvidia/tritonserver:20.09-py3 tritonserver --model-store=/models --log-verbose=0 --strict-model-config=false --backend-config=tensorflow,version=2
   #nvcr.io/nvidia/tritonserver:davidg-master-py3-base-tf2cudnn8 tritonserver --model-store=/models  --log-verbose=0 --strict-model-config=false --backend-config=tensorflow,version=2
   #nvcr.io/nvidia/tritonserver:20.09-py3 tritonserver --model-store=/models --log-verbose=0 --strict-model-config=false --backend-config=tensorflow,version=2 
   #gitlab-master.nvidia.com:5005/dl/dgx/tritonserver/20.11-cuda11-cudnn7:latest tritonserver --model-store=/models --strict-model-config=false --log-verbose=1 --backend-config=tensorflow,version=2
