DYNAMIC_BATCHING=${1:-false}

if [[ $DYNAMIC_BATCHING == true ]]
then
    static_batch_size=1  
    client_concurrency="128:256:32"
    echo "batch size: $static_batch_size"
    echo "client concurrency: $client_concurrency"
    echo "no model concurrency implemented"
    bash triton/scripts/run_perf_client_tfs.sh "widedeep" 1 $static_batch_size 100 10 $client_concurrency localhost true
else
    for static_batch_size in 1 8 256
    do
        client_concurrency="1:16:1"
        echo "batch size: $static_batch_size"
        echo "client concurrency: $client_concurrency"
        echo "no model concurrency implemented"
        bash triton/scripts/run_perf_client_tfs.sh "widedeep" 1 $static_batch_size 100 10 $client_concurrency localhost false
    done
fi

