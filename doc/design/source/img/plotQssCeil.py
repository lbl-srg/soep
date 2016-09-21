import matplotlib.pyplot as plt
from matplotlib import lines

from matplotlib import rc
rc('text', usetex=True)
rc('font', family='serif')
from pylab import *
rcParams['figure.figsize'] = 11, 4 


def getLine(t, x, col):
    line = []
    for i in range(len(x)-1):
        if x[i] != None:
            k = 0
            for j in range(i+1, len(x)):
                if x[j] != None:
                    k = j
                    break
                elif j == len(x)-1:
                    k = j
                    break
            line.append(lines.Line2D([t[i], t[k]], [x[i], x[i]], lw=0.5, color=col))
    return line


t = [0, 0.0166666666667, 0.033908045977, 0.05, 0.0519009230769, 0.0719009230769, 0.0927342564103, 0.1]

x1 = [10, None, None, None, None, None, None, 9]
x2 = [10, None, None, 9, None, None, None, 8]
x3 = [10, 9, 8, None, 7, 6, 5, None]

fig = plt.figure()
ax = fig.add_subplot(111)
plt.subplots_adjust(bottom=0.22)
ax.stem(t, x1, linefmt='b-', markerfmt='bo', label='$\chi_1$', basefmt='')
ax.stem(t, x2, linefmt='g--', markerfmt='gd', label='$\chi_2$', basefmt='')
ax.stem(t, x3, linefmt='r-.', markerfmt='r.', label='$\chi_3$', basefmt='')

xticks = [float("{:1.4f}".format(s)) for s in t]
xticklabels = xticks
ax.set_xticks(xticks)

plt.xticks(rotation=90)

# Draw lines
for l in getLine(t, x1, 'b'):
    ax.add_line(l)
for l in getLine(t, x2, 'g'):
    ax.add_line(l)
for l in getLine(t, x3, 'r'):
    ax.add_line(l)
# Pad margins so that markers don't get clipped by the axes
ax.margins(0.5)
# Tweak spacing to prevent clipping of tick-labels
#ax.grid()
ax.set_xlabel('time')
ax.set_ylabel('$\chi$')
ax.legend()
ax.legend(loc='upper center', bbox_to_anchor=(0.5, 1.2),
          ncol=3)
gcf().subplots_adjust(top=0.8)
gcf().subplots_adjust(bottom=0.2)
gcf().subplots_adjust(left=0.1)
gcf().subplots_adjust(right=0.95)
ax.set_xlim([-0.01, 0.11])
ax.set_ylim([4.9, 10.3])
plt.savefig('qssCeil.pdf')
plt.savefig('qssCeil.png')
#plt.show()
