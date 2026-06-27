import numpy as np
import pandas as pd

# Sampling rate and duration
fs = 360           # 360 Hz
t = np.linspace(0, 5, 5*fs)  # 5 seconds of samples

# Generate synthetic ECG waveform
ecg = 1.0*np.sin(2*np.pi*1.3*t)         # main PQRST-like wave
ecg += 0.5*np.sin(2*np.pi*40*t)         # high-frequency component
ecg += 0.05*np.random.randn(len(t))      # added noise

# Scale to integers for Verilog
ecg_int = (ecg * 5000).astype(int)       # scale up to ensure peaks exceed threshold

# Save as CSV (one sample per line)
pd.DataFrame(ecg_int).to_csv(
    'C:/modelsim_work_space/ECG_VLSI_PROJECT/data/ecg_samples.csv', 
    index=False, header=False
)

print("✅ Scaled noisy ECG samples saved as ecg_samples.csv")
