#!/bin/bash

echo "Createing topic..."
./kafka-topics.sh \
    -bootstrap-server localhost:29092 \
    -create \
    -topic perf-test \
    -partitions 6 \
    -replication-factor 1 \
    -config retention.ms=10000
echo "Finish createing topic..."

echo "Benching producer..."
./kafka-producer-perf-test.sh \
  --topic perf-test \
  --num-records 1000000 \
  --record-size 100 \
  --throughput 50000 \
  --warmup-records 100000 \
  --command-property \
    bootstrap.servers=localhost:29092 \
    acks=1 \
    linger.ms=5 \
    batch.size=65536 \
    compression.type=snappy \
  --print-metrics
echo "Finish benching producer."

echo "Benching consumer..."
for i in 1 2 3 4; do
  ./kafka-consumer-perf-test.sh \
    --bootstrap-server localhost:29092 \
    --topic perf-test \
    --group perf-test-group-$i \
    --num-records 1000000 \
    --timeout 60000 \
    --print-metrics \
    --show-detailed-stats &
done

wait
echo "Finish benching consumer."
