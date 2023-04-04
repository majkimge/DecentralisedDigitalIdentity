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

file_d30_80 = open("time_measures_w10_d30_to_80", "r")
file_d90_100 = open("time_measures_d90_to_100", "r")
file_d1 = open("time_measures_w10_d1", "r")
file_d10 = open("time_measures_w10_d10", "r")
file_d20 = open("time_measures_w10_d20", "r")
file_all = open("time_measures_all_1", "r")
lines_exe = (
    file_d1.readlines()
    + file_d10.readlines()
    + file_d20.readlines()
    + file_d30_80.readlines()
    + file_d90_100.readlines()
)
# lines = file_d1.readlines() + file_all.readlines()

floats_exe = np.array(list(map(float, lines_exe)))

means_exe = np.array([np.mean(floats_exe[i * 10 : i * 10 + 10]) for i in range(11)])
std_devs_exe = np.array([np.std(floats_exe[i * 10 : i * 10 + 10]) for i in range(11)])

x = [1] + [i * 10 for i in range(1, 11)]
x = np.array(x)

fig, ax1 = plt.subplots()

ax2 = ax1.twinx()

ax1.errorbar(
    x,
    means_exe,
    yerr=std_devs_exe,
    fmt="o",
    markersize=5,
    capsize=3,
    capthick=1,
    ecolor="black",
    label="Creation Time (s)",
)

# Set the x and y1 axis labels
ax1.set_xlabel("Depth of the Graph", fontsize=12)
ax1.set_ylabel("Creation Time (s)", fontsize=12)

# Add a legend to the plot
ax1.legend(loc="upper left", fontsize=10)

# Plot the second data set with error bars on the right axis
ax2.errorbar(
    x,
    means,
    yerr=std_devs,
    fmt="^",
    markersize=5,
    capsize=3,
    capthick=1,
    ecolor="red",
    c="green",
    label="Authentication time (ms)",
)

# Set the y2 axis label
ax2.set_ylabel("Authentication time (ms)", fontsize=12)

# Add a legend to the plot
ax2.legend(loc="upper right", fontsize=10)

# Add a title to the plot
ax1.set_title("Creation and Authentication Time vs. Depth", fontsize=14)

# Adjust the axis tick labels and grid
ax1.tick_params(axis="both", which="major", labelsize=10)
ax2.tick_params(axis="both", which="major", labelsize=10)
ax1.grid(axis="y", linestyle="--", alpha=0.5)


plt.savefig("both_plot.png")

print(means)
print(std_devs)
