import wfdb
import numpy as np

# Folder where 100.dat and 100.hea are saved
data_path = r"C:\modelsim_work_space\ECG_VLSI_PROJECT\data"

# Read the record directly from local files
record = wfdb.rdrecord(f"{data_path}\\100")

# Select first ECG channel (MLII or V1 usually)
ecg_signal = record.p_signal[:, 0]

# Convert to integers for Verilog
ecg_int = (ecg_signal * 1000).astype(int)

# Save as CSV (one sample per line)
np.savetxt(f"{data_path}\\ecg_samples.csv", ecg_int, fmt="%d")

print("✅ ECG samples saved to:", f"{data_path}\\ecg_samples.csv")
print("Total samples:", len(ecg_int))
