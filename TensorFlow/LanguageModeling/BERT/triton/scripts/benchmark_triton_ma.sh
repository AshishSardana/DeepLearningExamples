DYNAMIC_BATCHING=${1:-false}

if [[ $DYNAMIC_BATCHING == true ]]
then
    sed -i "s/max_batch_size.*/max_batch_size: 8/" results/triton_models/bert/config.pbtxt
    if grep -q "dynamic_batching" results/triton_models/bert/config.pbtxt
        then 
            echo "Dynamic batching is already enabled in config.pbtxt"
        else 
            echo "Enabling dynamic batching in config.pbtxt"
            echo "dynamic_batching { max_queue_delay_microseconds: 0 }" >> results/triton_models/bert/config.pbtxt
    fi
    static_batch_size=1  
    client_concurrency="16:48:16"
    echo "batch size: $static_batch_size"
    echo "client concurrency: $client_concurrency"
    
    for model_concurrency in 2
    do
        echo "model concurrency: $model_concurrency"
        sed -i "s/^        count:.*/        count: $model_concurrency/" results/triton_models/bert/config.pbtxt
        instance_count=$model_concurrency bash triton/scripts/run_perf_client.sh "bert" 1 $static_batch_size 100 10 $client_concurrency localhost
    done
else
    sed -i "s/dynamic_batching.*/ /" results/triton_models/bert/config.pbtxt
    sed -i "s/max_batch_size.*/max_batch_size: 8/" results/triton_models/bert/config.pbtxt
    for model_concurrency in 2
    do
        echo "model concurrency: $model_concurrency"
        sed -i "s/^        count:.*/        count: $model_concurrency/" results/triton_models/bert/config.pbtxt
        bash triton/scripts/run_model_analyzer.sh
    done  
fi