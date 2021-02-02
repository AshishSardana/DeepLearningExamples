DYNAMIC_BATCHING=${1:-false}

if [[ $DYNAMIC_BATCHING == true ]]
then
    sudo sed -i "s/max_batch_size.*/max_batch_size: 128/" triton/inference/resnet50/config.pbtxt
    echo "dynamic_batching { max_queue_delay_microseconds: 0 }" >> triton/inference/resnet50/config.pbtxt
    static_batch_size=1  
    echo "batch size: $static_batch_size"
    for ((client_concurrency=128; client_concurrency<=256; client_concurrency+=32))
    do
        echo "client concurrency: $client_concurrency"
        for model_concurrency in 1 2
        do
            echo "model concurrency: $model_concurrency"
            sudo sed -i "s/^        count:.*/        count: $model_concurrency/" triton/inference/resnet50/config.pbtxt
            bash triton/scripts/run_perf_client.sh "resnet50" 1 $static_batch_size 100 10 $client_concurrency localhost
        done
    done
else
    sudo sed -i "s/dynamic_batching.*/ /" triton/inference/resnet50/config.pbtxt

    for static_batch_size in 1 8 64 128
    do
        echo "batch size: $static_batch_size"
        for client_concurrency in {1..16}
        do
            echo "client concurrency: $client_concurrency"
            for model_concurrency in 1 2 4
            do
                echo "model concurrency: $model_concurrency"
                sudo sed -i "s/^        count:.*/        count: $model_concurrency/" triton/inference/resnet50/config.pbtxt
                bash triton/scripts/run_perf_client.sh "resnet50" 1 $static_batch_size 100 10 $client_concurrency localhost
            done  
        done
    done
fi