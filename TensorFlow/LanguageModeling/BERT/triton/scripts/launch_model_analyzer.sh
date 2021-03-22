NV_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-"0"}
DETACHED=${DETACHED:-"-it"}

# Start TRITON server in DETACHED state
docker run --runtime=nvidia --rm $DETACHED \
   --shm-size=1g \
   --ulimit memlock=-1 \
   --ulimit stack=67108864 \
   --net=host \
   --privileged \
   -u $(id -u):$(id -g) \
   -v /var/run/docker.sock:/var/run/docker.sock \
   -e NVIDIA_VISIBLE_DEVICES=$NV_VISIBLE_DEVICES \
   -v $PWD:/workspace/examples \
   model-analyzer model-analyzer -f /workspace/examples/triton/config_model_analyzer_docker.yaml