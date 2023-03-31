import numpy as np
import matplotlib.pyplot as plt


file_all = open("time_measures_auth", "r")
file_60 = open("time_measures_auth_60", "r")
file_70 = open("time_measures_auth_70", "r")
lines_60 = file_60.readlines()
lines = file_all.readlines()[:66] + lines_60[:11] + file_70.readlines() + lines_60[22:]
# lines = file_d1.readlines() + file_all.readlines()

floats = np.array(list(map(float, lines)))
floats_good = []
for i in range(0, len(floats), 11):
    floats_good += list(floats[i + 3 : i + 11])

floats_good = np.array(floats_good) * 1000

print(floats_good)

means = np.array([np.mean(floats_good[i * 8 : i * 8 + 8]) for i in range(11)])
std_devs = np.array([np.std(floats_good[i * 8 : i * 8 + 8]) for i in range(11)])

x = [1] + [i * 10 for i in range(1, 11)]
x = np.array(x)

fig, ax = plt.subplots()

# Plot the data with error bars
ax.errorbar(
    x,
    means,
    yerr=std_devs,
    fmt="o",
    markersize=5,
    capsize=3,
    capthick=1,
    ecolor="black",
)

# Set the x and y axis labels
ax.set_xlabel("Depth of the Graph", fontsize=12)
ax.set_ylabel("Authentication Time (ms)", fontsize=12)

# Add a title to the plot
ax.set_title("Authentication Time vs. Graph Depth", fontsize=14)

# Adjust the axis tick labels and grid
ax.tick_params(axis="both", which="major", labelsize=10)
ax.grid(axis="y", linestyle="--", alpha=0.5)


plt.savefig("auth_plot.png")

print(means)
print(std_devs)
