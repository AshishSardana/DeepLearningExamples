DYNAMIC_BATCHING=${1:-false}

if [[ $DYNAMIC_BATCHING == true ]]
then
    sed -i "s/max_batch_size.*/max_batch_size: 256/" inference/models/widedeep/config.pbtxt
    if grep -q "dynamic_batching" inference/models/widedeep/config.pbtxt
        then 
            echo "Dynamic batching is already enabled in config.pbtxt"
        else 
            echo "Enabling dynamic batching in config.pbtxt"
            echo "dynamic_batching { max_queue_delay_microseconds: 0 }" >> inference/models/widedeep/config.pbtxt
    fi
    static_batch_size=1  
    client_concurrency="512:1280:128"
    echo "batch size: $static_batch_size"
    echo "client concurrency: $client_concurrency"

    for model_concurrency in 2
    do
        echo "model concurrency: $model_concurrency"
        sed -i "s/^        count:.*/        count: $model_concurrency/" inference/models/widedeep/config.pbtxt
        instance_count=$model_concurrency bash triton/scripts/run_perf_client.sh "widedeep" 1 $static_batch_size 100 10 $client_concurrency localhost
    done
else
    sed -i "s/dynamic_batching.*/ /" inference/models/widedeep/config.pbtxt
    sed -i "s/max_batch_size.*/max_batch_size: 256/" inference/models/widedeep/config.pbtxt
    for static_batch_size in 1 8 256
    do
        client_concurrency="32:96:16"
        echo "batch size: $static_batch_size"
        echo "client concurrency: $client_concurrency"
        for model_concurrency in 1 2 4
        do
            echo "model concurrency: $model_concurrency"
            sed -i "s/^        count:.*/        count: $model_concurrency/" inference/models/widedeep/config.pbtxt
            instance_count=$model_concurrency bash triton/scripts/run_perf_client.sh "widedeep" 1 $static_batch_size 100 10 $client_concurrency localhost
        done  
    done
fi