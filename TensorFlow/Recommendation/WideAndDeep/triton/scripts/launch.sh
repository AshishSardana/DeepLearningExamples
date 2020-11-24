#!/bin/bash

CMD=${@:-/bin/bash}
NV_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-"all"}


docker run --gpus $NV_VISIBLE_DEVICES --rm -it \
    --net=host \
    --shm-size=1g \
    --ulimit memlock=-1 \
    --ulimit stack=67108864 \
    -e NVIDIA_VISIBLE_DEVICES=$NV_VISIBLE_DEVICES \
    -v $PWD:/workspace/widedeep \
    -v $PWD/results:/results \
    bert $CMD
    # nvcr.io/nvidia/tritonserver:20.03-py3-clientsdk $CMD
