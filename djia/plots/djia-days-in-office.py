import pandas as pd
import matplotlib.pyplot as plt

# Load the CSV file
df = pd.read_csv("plots/data/djia-days-in-office.csv")

# Create the plot
plt.figure(figsize=(10, 6))

# Plot each president as a separate series
for president, group in df.groupby("president"):
    plt.plot(group["nth_day_in_office"], group["delta"], marker="o", linestyle="-", label=president)

# Formatting the plot
plt.xlabel("Nth Day in Office")
plt.ylabel("Change in Market since first day, Percent")
plt.title("Stock Market Changes by President")
plt.legend(title="President")
plt.grid(True)

# Save the plot to a PNG file
plt.savefig("plots/djia-days-in-office.png", dpi=72, bbox_inches="tight")

# Close the plot to free memory
plt.close()