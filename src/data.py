import pandas as pd
import numpy as np

def load_raw_data(filepath: str) -> pd.DataFrame:
    return pd.read_csv(filepath)

def remove_outliers_iqr(df: pd.DataFrame, columns: list) -> pd.DataFrame:
    cleaned_df = df.copy()
    for col in columns:
        Q1 = cleaned_df[col].quantile(0.25)
        Q3 = cleaned_df[col].quantile(0.75)
        IQR = Q3 - Q1
        lower_bound = Q1 - 1.5 * IQR
        upper_bound = Q3 + 1.5 * IQR
        cleaned_df = cleaned_df[(cleaned_df[col] >= lower_bound) & (cleaned_df[col] <= upper_bound)]
    return cleaned_df