import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.path import Path
import matplotlib.patches as patches

# Let's test drawing the letters E, V, E, R, Y, D, E, V, I, C, E and Z, E, R, O, T, R, U, S
fig, ax = plt.subplots(figsize=(12, 6), facecolor='black')
ax.set_facecolor('black')
ax.set_xlim(0, 1000)
ax.set_ylim(0, 500)
ax.invert_yaxis()
ax.axis('off')

# Save initial figure to verify matplotlib works
plt.savefig('scratch/test_out.png', bbox_inches='tight', dpi=100)
print('Matplotlib works!')
