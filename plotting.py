import numpy as np
import matplotlib.pyplot as plt

file_d30_80 = open("time_measures_w10_d30_to_80", "r")
file_d90_100 = open("time_measures_d90_to_100", "r")
file_d1 = open("time_measures_w10_d1", "r")
file_d10 = open("time_measures_w10_d10", "r")
file_d20 = open("time_measures_w10_d20", "r")
file_all = open("time_measures_all_1", "r")
lines = (
    file_d1.readlines()
    + file_d10.readlines()
    + file_d20.readlines()
    + file_d30_80.readlines()
    + file_d90_100.readlines()
)
# lines = file_d1.readlines() + file_all.readlines()

floats = np.array(list(map(float, lines)))

means = np.array([np.mean(floats[i * 10 : i * 10 + 10]) for i in range(11)])
std_devs = np.array([np.std(floats[i * 10 : i * 10 + 10]) for i in range(11)])

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
ax.set_ylabel("Creation Time (s)", fontsize=12)

# Add a title to the plot
ax.set_title("Creation Time vs. Graph Depth", fontsize=14)

# Adjust the axis tick labels and grid
ax.tick_params(axis="both", which="major", labelsize=10)
ax.grid(axis="y", linestyle="--", alpha=0.5)


plt.savefig("time_plot.png")

print(means)
print(std_devs)
