NV_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-"2"}
DETACHED=${DETACHED:-"-d"}

# Start TRITON server in DETACHED state
docker run --runtime=nvidia --rm $DETACHED \
   --shm-size=1g \
   --ulimit memlock=-1 \
   --ulimit stack=67108864 \
   -p8010:8000 \
   -p8011:8001 \
   -p8012:8002 \
   --name triton_server_cont_bert \
   -e NVIDIA_VISIBLE_DEVICES=$NV_VISIBLE_DEVICES \
   -v $PWD/results/triton_models:/models \
   gitlab-master.nvidia.com:5005/dl/dgx/tritonserver/tritonserver-21.02-modified:cublas_11.2_cudnn_8.0.4_tf_2.3.0-devel tritonserver --model-store=/models --strict-model-config=false --backend-config=tensorflow,version=2
   #nvcr.io/nvidia/tritonserver:20.09-py3 tritonserver --model-store=/models --log-verbose=0 --strict-model-config=false --backend-config=tensorflow,version=2
   #nvcr.io/nvidia/tritonserver:davidg-master-py3-base-tf2cudnn8 tritonserver --model-store=/models  --log-verbose=0 --strict-model-config=false --backend-config=tensorflow,version=2
   #nvcr.io/nvidia/tritonserver:20.09-py3 tritonserver --model-store=/models --log-verbose=0 --strict-model-config=false --backend-config=tensorflow,version=2 
   #gitlab-master.nvidia.com:5005/dl/dgx/tritonserver/20.11-cuda11-cudnn7:latest tritonserver --model-store=/models --strict-model-config=false --log-verbose=1 --backend-config=tensorflow,version=2
