import pandas as pd
import matplotlib.pyplot as plt

# 1. Load data
df = pd.read_csv("results.csv")

# Ensure numeric types
df["record_size"] = df["record_size"].astype(int)
df["records_per_sec"] = df["records_per_sec"].astype(float)
df["mb_per_sec"] = df["mb_per_sec"].astype(float)
df["avg_latency_ms"] = df["avg_latency_ms"].astype(float)
df["max_latency_ms"] = df["max_latency_ms"].astype(float)

# 2. Throughput (MB/s) vs record_size, one line per acks
for acks, group in df.groupby("acks"):
    group_sorted = group.sort_values("record_size")
    plt.plot(group_sorted["record_size"], group_sorted["mb_per_sec"], marker="o", label=f"acks={acks}")

plt.xlabel("Record size (bytes)")
plt.ylabel("Throughput (MB/s)")
plt.title("Kafka producer throughput vs record size")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig("throughput_vs_record_size.png")
plt.close()

# 3. Latency vs record_size (optional)
for acks, group in df.groupby("acks"):
    group_sorted = group.sort_values("record_size")
    plt.plot(group_sorted["record_size"], group_sorted["avg_latency_ms"], marker="o", label=f"acks={acks}")

plt.xlabel("Record size (bytes)")
plt.ylabel("Average latency (ms)")
plt.title("Kafka producer avg latency vs record size")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig("latency_vs_record_size.png")
plt.close()

print("Saved: throughput_vs_record_size.png, latency_vs_record_size.png")

