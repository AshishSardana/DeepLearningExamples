DYNAMIC_BATCHING=${1:-false}

if [[ $DYNAMIC_BATCHING == true ]]
then
    static_batch_size=1  
    client_concurrency="16:48:16"
    echo "batch size: $static_batch_size"
    echo "client concurrency: $client_concurrency"
    echo "no model concurrency implemented"
    bash triton/scripts/run_perf_client_tfs.sh "bert" 1 $static_batch_size 100 10 $client_concurrency localhost 384 true
else
    for static_batch_size in 1 4 8
    do
        client_concurrency="32:96:16"
        echo "batch size: $static_batch_size"
        echo "client concurrency: $client_concurrency"
        echo "no model concurrency implemented"
        bash triton/scripts/run_perf_client_tfs.sh "bert" 1 $static_batch_size 100 10 $client_concurrency localhost 384 false
    done
fi