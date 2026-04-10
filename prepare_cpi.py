import pandas as pd

BASE = '/Users/iffahmojid/Dropbox/IM22110005063/SQLite/'

# Load with no header, all as strings to avoid mixed type warning
df_raw = pd.read_csv(BASE + 'mm23.csv', header=None, dtype=str, low_memory=False)

# Row 1 contains the CDID series codes — use as column headers
df_raw.columns = df_raw.iloc[1]

# Rename the first column (was "Title"/"CDID") to 'period'
df_raw = df_raw.rename(columns={df_raw.columns[0]: 'period'})

# Drop the metadata rows at the top (rows 0-6: Title, CDID, PreUnit, Unit, etc.)
df = df_raw.iloc[7:].reset_index(drop=True)

# Keep only annual rows — 4-digit years e.g. 1988, 1989
df = df[df['period'].str.match(r'^\d{4}$', na=False)]

# Select the series we want and rename them
series_map = {
    'D7G7': 'cpi_all_items',
    'D7BT': 'cpi_food',
    'D7BU': 'cpi_alcohol_tobacco',
    'D7CA': 'cpi_energy',
    'D7CE': 'cpi_transport',
    'CZBH': 'rpi_all_items'
}

# Only keep columns that actually exist in the file
cols_to_keep = ['period'] + [k for k in series_map if k in df.columns]
df = df[cols_to_keep].rename(columns=series_map)

# Convert value columns to numeric
for col in df.columns:
    if col != 'period':
        df[col] = pd.to_numeric(df[col], errors='coerce')

# Drop rows where all CPI values are NaN (pre-1988 data)
df = df.dropna(subset=['cpi_all_items'])

df.to_csv(BASE + 'cpi_clean.csv', index=False)
print(df.head(10))
print(f"\nDone — {len(df)} rows exported to cpi_clean.csv")