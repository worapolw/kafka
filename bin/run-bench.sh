#!/bin/bash
set -euo pipefail

BROKER="localhost:29092"
TOPIC="perf-test"

# Tune these as you like
NUM_RECORDS=100000
RECORD_SIZES=(100 1000 10000 50000)  # bytes
ACKS=("1" "all")

OUT_CSV="results.csv"
echo "record_size,acks,records_per_sec,mb_per_sec,avg_latency_ms,max_latency_ms" > "$OUT_CSV"

for size in "${RECORD_SIZES[@]}"; do
  for acks in "${ACKS[@]}"; do
    echo "Running: size=${size}, acks=${acks}..."

    # Run producer perf test
    OUTPUT=$(./kafka-producer-perf-test.sh \
      --bootstrap-server "$BROKER" \
      --topic "$TOPIC" \
      --num-records "$NUM_RECORDS" \
      --record-size "$size" \
      --throughput -1 \
      --command-property acks="$acks" \
      --command-property linger.ms=5 \
      --command-property batch.size=65536 2>&1)
    
    # Find the summary line, usually like:
    # "100000 records sent, 12345.678 records/sec (12.34 MB/sec), 10.0 ms avg latency, 50.0 ms max latency."
    SUMMARY_LINE=$(echo "$OUTPUT" | grep "records sent" | tail -n1)

    # Very basic parsing; adjust if your exact format differs
    # Use comma as separator then trim pieces
    RECORDS_PER_SEC=$(echo "$SUMMARY_LINE" | awk -F',' '{print $2}' | awk '{print $1}')
    MB_PER_SEC=$(echo "$SUMMARY_LINE"      | awk -F'[()]' '{print $2}' | awk '{print $1}')
    AVG_LAT_MS=$(echo "$SUMMARY_LINE"      | awk -F',' '{print $3}' | awk '{print $1}')
    MAX_LAT_MS=$(echo "$SUMMARY_LINE"      | awk -F',' '{print $4}' | awk '{print $1}')

    echo "${size},${acks},${RECORDS_PER_SEC},${MB_PER_SEC},${AVG_LAT_MS},${MAX_LAT_MS}" >> "$OUT_CSV"
  done
done

echo "Done. Results written to $OUT_CSV"

