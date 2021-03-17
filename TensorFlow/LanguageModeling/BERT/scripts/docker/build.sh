#!/bin/bash

docker pull nvcr.io/nvidia/tritonserver:21.02-py3

docker build . --rm -t bert
