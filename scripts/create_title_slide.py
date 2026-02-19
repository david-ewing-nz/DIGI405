"""
Create title slide for presentation
"""
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch

# Create figure with 16:9 aspect ratio (same as slides)
fig = plt.figure(figsize=(10, 5.625), facecolor='white')
ax = fig.add_subplot(111)
ax.set_xlim(0, 1)
ax.set_ylim(0, 1)
ax.axis('off')

# UC Blue color
uc_blue = '#003087'

# Title
ax.text(0.5, 0.75, 'Variational Bayesian Methods:', 
        ha='center', va='center', 
        fontsize=28, fontweight='bold', color=uc_blue)
ax.text(0.5, 0.68, 'Under-dispersion in Hierarchical Models', 
        ha='center', va='center', 
        fontsize=24, color=uc_blue)

# Author
ax.text(0.5, 0.52, 'David Ewing', 
        ha='center', va='center', 
        fontsize=20, fontweight='bold', color='#333333')

# Degree
ax.text(0.5, 0.45, 'Masters of Applied Data Science', 
        ha='center', va='center', 
        fontsize=16, color='#555555', style='italic')

# Supervisor
ax.text(0.5, 0.35, 'Supervisor: Dr John Holmes', 
        ha='center', va='center', 
        fontsize=14, color='#555555')

# Institution
ax.text(0.5, 0.22, 'School of Mathematics and Statistics', 
        ha='center', va='center', 
        fontsize=14, color='#666666')
ax.text(0.5, 0.16, 'University of Canterbury', 
        ha='center', va='center', 
        fontsize=14, color='#666666')

# Date
ax.text(0.5, 0.05, '30 January 2026', 
        ha='center', va='center', 
        fontsize=12, color='#888888')

# Add subtle decorative line
line = patches.Rectangle((0.2, 0.59), 0.6, 0.002, 
                         facecolor='#CCCCCC', edgecolor='none')
ax.add_patch(line)

# Save
plt.tight_layout(pad=0)
plt.savefig('figs/title_slide.png', dpi=300, bbox_inches='tight', facecolor='white')
print("Title slide created: figs/title_slide.png")
