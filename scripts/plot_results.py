# plot_results.py
import pandas as pd
import matplotlib.pyplot as plt
import sys

fn = "results/annotated_out.csv"
df = pd.read_csv(fn)
fs = 360.0  # sampling rate - change if you used another rate
df['time_s'] = df['sample_index'] / fs

plt.figure(figsize=(12,4))
plt.plot(df['time_s'], df['filtered_out'], linewidth=0.9, label='Filtered ECG')
peaks = df[df['r_peak'] == 1]
plt.scatter(peaks['time_s'], peaks['filtered_out'], color='red', s=30, label='Detected R-peaks')
plt.xlabel('Time (s)')
plt.ylabel('Amplitude (a.u.)')
plt.title('Simulated ECG with detected R-peaks')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()

# Print some summary stats:
if len(df) > 0:
    hr_vals = df['heart_rate']
    print("Heart rate (sampled): min,max,mean (ignore zeros):")
    nonzero = hr_vals[hr_vals>0]
    if len(nonzero)>0:
        print(int(nonzero.min()), int(nonzero.max()), float(nonzero.mean()))
    else:
        print("no HR values detected in output")
