import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Load the CSV file
df = pd.read_csv("data/ice_denormalized_data.csv")

# Convert measured_on to datetime for better plotting
df['measured_on'] = pd.to_datetime(df['measured_on'])

# Group by date and sum the male_crim and male_non_crim values across all facilities
aggregated_data = df.groupby('measured_on').agg({
    'male_crim': 'sum',
    'male_non_crim': 'sum'
}).reset_index()

# Sort by date
aggregated_data = aggregated_data.sort_values('measured_on')

# Calculate percentage of non-criminal detainees
aggregated_data['total_detainees'] = aggregated_data['male_crim'] + aggregated_data['male_non_crim']
aggregated_data['non_criminal_percentage'] = (aggregated_data['male_non_crim'] / aggregated_data['total_detainees']) * 100

# Create the plot with two y-axes
fig, ax1 = plt.subplots(figsize=(12, 8))

# Plot total male_crim and male_non_crim on the first y-axis
ax1.plot(aggregated_data['measured_on'], aggregated_data['male_crim'], 
         marker='o', linestyle='-', linewidth=2, label='Total Male Criminal')
ax1.plot(aggregated_data['measured_on'], aggregated_data['male_non_crim'], 
         marker='s', linestyle='-', linewidth=2, label='Total Male Non-Criminal')

# Set labels for the first y-axis
ax1.set_xlabel('Date')
ax1.set_ylabel('Total Count')
ax1.tick_params(axis='y', labelcolor='black')

# Create a second y-axis that shares the same x-axis
ax2 = ax1.twinx()

# Plot percentage of non-criminal detainees on the second y-axis
ax2.plot(aggregated_data['measured_on'], aggregated_data['non_criminal_percentage'], 
         marker='^', linestyle='-', linewidth=2, color='red', label='Percentage Non-Criminal')

# Set labels for the second y-axis
ax2.set_ylabel('Percentage of Non-Criminal Detainees (%)')
ax2.tick_params(axis='y', labelcolor='red')

# Set the y-axis limits for the second axis to be 0 to 100 percent
ax2.set_ylim(0, 100)

# Add title
plt.title('Male Detainees Across All Facilities')

# Add legends for both axes
lines1, labels1 = ax1.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax1.legend(lines1 + lines2, labels1 + labels2, loc='upper left')

# Format the plot
plt.grid(True)
plt.xticks(rotation=45)
plt.tight_layout()

# Save the plot to a PNG file in the plots folder
plt.savefig("criminal.png", dpi=100, bbox_inches="tight")

# Close the plot to free memory
plt.close()

print("Generated aggregate criminal data plot with percentage on second axis")
