DYNAMIC_BATCHING=${1:-false}

if [[ $DYNAMIC_BATCHING == true ]]
then
    static_batch_size=1  
    echo "batch size: $static_batch_size"
    for ((client_concurrency=128; client_concurrency<=256; client_concurrency+=32))
    do
        echo "client concurrency: $client_concurrency"
        echo "no model concurrency implemented"
        bash triton/scripts/run_perf_client_tfs.sh "bert" 1 $static_batch_size 100 10 $client_concurrency localhost 384 true
    done
else
    for static_batch_size in 1 8 64
    do
        echo "batch size: $static_batch_size"
        for client_concurrency in {1..16}
        do
            echo "client concurrency: $client_concurrency"
            echo "no model concurrency implemented"
            bash triton/scripts/run_perf_client_tfs.sh "bert" 1 $static_batch_size 100 10 $client_concurrency localhost 384 false
        done
    done
fi

