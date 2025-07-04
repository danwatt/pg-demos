import pandas as pd
import matplotlib.pyplot as plt
import os
import re

# Load the CSV file
df = pd.read_csv("data/ice_denormalized_data.csv")

# Convert measured_on to datetime for better plotting
df['measured_on'] = pd.to_datetime(df['measured_on'])

# Get unique facilities
facilities = df['facility_name'].unique()

# For each facility, create a plot
for facility in facilities:
    # Filter data for this facility
    facility_data = df[df['facility_name'] == facility]

    # Sort by date
    facility_data = facility_data.sort_values('measured_on')

    # Create the plot
    plt.figure(figsize=(10, 6))

    # Plot male_crim and male_non_crim
    plt.plot(facility_data['measured_on'], facility_data['male_crim'], marker='o', linestyle='-', label='Male Criminal')
    plt.plot(facility_data['measured_on'], facility_data['male_non_crim'], marker='s', linestyle='-', label='Male Non-Criminal')

    # Formatting the plot
    plt.xlabel('Date')
    plt.ylabel('Count')
    plt.title(f'Male Criminal and Non-Criminal Detainees at {facility}')
    plt.legend()
    plt.grid(True)
    plt.xticks(rotation=45)
    plt.tight_layout()

    # Format facility name for filename (replace all non-alphanumeric characters with hyphens)
    filename = re.sub(r'[^a-zA-Z0-9]', '-', facility.lower())

    # Save the plot to a PNG file in the plots folder
    plt.savefig(f"{filename}.png", dpi=100, bbox_inches="tight")

    # Close the plot to free memory
    plt.close()

print(f"Generated plots for {len(facilities)} facilities")