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
   -v $PWD/triton/model/config.pbtxt:/models/resnet50/config.pbtxt \
   -v $PWD/triton/model/saved_model/nvidia_rn50_tf_amp/:/models/resnet50/1/model.savedmodel/ \
   nvcr.io/nvidia/tritonserver:20.09-py3 tritonserver --model-store=/models --strict-model-config=false --log-verbose=1 --backend-config=tensorflow,version=2