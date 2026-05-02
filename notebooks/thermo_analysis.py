'''
Analysis to obtain the thermodynamic data plots of PE, Number of Clusters, density (only for equilibration_NPT), Pressure, Temperature.
The python file takes three arguements:
1. DIR: location of the raw file directory. ex: /lustre/ea-nrtmidas/users/3770/emulsion_stability/data/raw/self_assembly_polymer_surfactant180_toluene_water_20260401-163540
2. ENSEMBLE: ensemble of the system. only two options are recommended: equilibration_NPT, production_NVT
3. FIGURES: location to store the plot images. ex: /lustre/ea-nrtmidas/users/3770/emulsion_stability/figures
4. SUBDIR: specific subdirectory under DIR/ENSEMBLE. If selecting every subdirectory under DIR/ENSEMBLE, type "'*'".

examples:
python thermo_analysis.py /lustre/ea-nrtmidas/users/3770/emulsion_stability/data/raw/box_var_self_assembly_polymer_surfactant_toluene_water_20260426-192641 production_NVT /lustre/ea-nrtmidas/users/3770/emulsion_stability/figures box_length-34.5_.config-1_.polymer-68_.surfactant-608_.toluene-42053
python thermo_analysis.py /lustre/ea-nrtmidas/users/3770/emulsion_stability/data/raw/self_assembly_polymer_surfactant180_toluene_water_20260401-163540 production_NVT /lustre/ea-nrtmidas/users/3770/emulsion_stability/figures '*'
'''
import pandas as pd
import glob
import numpy as np
import matplotlib.pyplot as plt
import os, sys
from io import StringIO

DIR = sys.argv[1] # raw data directory
ENSEMBLE = sys.argv[2] # dictates if equilibration_NPT, production_NVT
FIGURES = sys.argv[3] # directory to store figures
SUBDIR = sys.argv[4] # subdirectory under DIR/ENSEMBLE
dir_name = DIR.split("/")[-1]
# figure storage location
if SUBDIR == '*':
    figure_save_location = f"{FIGURES}/{dir_name}/{ENSEMBLE}" 
else:
    figure_save_location = f"{FIGURES}/{dir_name}/{ENSEMBLE}/{SUBDIR}" 
NOTEBOOK_DIR = '/lustre/ea-nrtmidas/users/3770/emulsion_stability/notebooks'
os.chdir(NOTEBOOK_DIR)

def filter_comments(file_path):
    """
    Generator to read a file and clubs lines that do not start 
    with '#' or '@'.
    """
    not_commented = []
    with open(file_path, 'r') as f:
        for line in f:
            if not line.strip().startswith('#') and not line.strip().startswith('@'):
                not_commented.append(line)
    return not_commented

def compute_mean_std(dfs, time_col, value_col):

    values_interp = []

    for df in dfs:
        t = df[time_col].values
        v = df[value_col].values

        values_interp.append(v)
    if(len(values_interp)>1):
        # presence of multiple configurations
        values_interp = np.array(values_interp)
        mean = values_interp.mean(axis=0)
        std = values_interp.std(axis=0)
    else:
        # only one configuration
        mean = values_interp[0]
        std = np.zeros_like(mean)
    return t, mean, std

# plotting styles
config_marker = ['+', 'd', 's']
config_marker_dict = {'config-3':'+', 'config-2':'d', 'config-1':'s'}
line_styles = ['-','--', '-.', ':', (0, (5, 10)), (0, (3, 10, 1, 10)), (0, (3, 5, 1, 5, 1, 5)), (0, (5, 5)), (0, (5, 1))]

plt.style.use('seaborn-v0_8-whitegrid')  # clean base style

plt.rcParams.update({
    'font.size': 16,            # base font
    'axes.labelsize': 20,       # x/y labels
    'axes.titlesize': 18,       # subplot titles
    'xtick.labelsize': 16,      # x tick numbers
    'ytick.labelsize': 16,      # y tick numbers
    'legend.fontsize': 16,      # legend text
    'legend.title_fontsize': 15,
    'lines.markersize': 6,
    'figure.titlesize': 20
})

file_thermo = 'thermo/thermo.xvg'
file_cluster = 'cluster/my_num_clusters.xvg'
configs_eq_thermo_list = []
configs_eq_cluster_list = []
config_list_thermo = []
config_list_cluster = []

# themo file data collection
for f in glob.glob(f'{DIR}/{ENSEMBLE}/{SUBDIR}/{file_thermo}'):
    config = f.split('/')[-3]
    conf_list = config_list_thermo.append(config)
    # Use StringIO to treat the filtered lines as a file for read_csv
    removed_comments = filter_comments(f'{f}')
    file_removed_comments = StringIO('\n'.join(removed_comments))
    df = pd.read_csv(file_removed_comments, header=None, sep='\s+', names=['time (ps)', 'potential', 'kinetic', 'total E', 'T', 'P', 'density'])
    configs_eq_thermo_list.append(df)

# no. cluster file data collection
for f in glob.glob(f'{DIR}/{ENSEMBLE}/{SUBDIR}/{file_cluster}'):
    config = f.split('/')[-3]
    config_list_cluster.append(config)
    # Use StringIO to treat the filtered lines as a file for read_csv
    removed_comments = filter_comments(f'{f}')
    file_removed_comments = StringIO('\n'.join(removed_comments))
    df = pd.read_csv(file_removed_comments, header=None, sep='\s+', names=['Time (ps)', 'Number of Clusters'])
    configs_eq_cluster_list.append(df)

# define intervals between the data points for thermodynamic data and number of clusters
interval_thermo = 10
interval_cluster = 10
'''
Plot PE and Number of Clusters vs time
'''
fig, axes = plt.subplots(2, 1, figsize=(7,6), sharex=True)

# Potential Energy
t_pe, pe_mean, pe_std = compute_mean_std(
    configs_eq_thermo_list,
    'time (ps)',
    'potential'
)
axes[0].plot(t_pe[interval_thermo::interval_thermo], pe_mean[interval_thermo::interval_thermo], color='tab:blue', label='PE')
if(len(configs_eq_thermo_list)>1): # denoting multiple configurations
    axes[0].fill_between(
        t_pe[interval_thermo::interval_thermo],
        pe_mean[interval_thermo::interval_thermo] - pe_std[interval_thermo::interval_thermo],
        pe_mean[interval_thermo::interval_thermo] + pe_std[interval_thermo::interval_thermo],
        color='tab:blue',
        alpha=0.3
    )

# Clusters
t_cl, cl_mean, cl_std = compute_mean_std(
    configs_eq_cluster_list,
    'Time (ps)',
    'Number of Clusters'
)
axes[1].plot(t_cl[interval_cluster::interval_cluster], cl_mean[interval_cluster::interval_cluster], color='tab:orange', label='Clusters count')
if(len(configs_eq_thermo_list)>1): # denoting multiple configurations
    axes[1].fill_between(
        t_cl[interval_cluster::interval_cluster],
        cl_mean[interval_cluster::interval_cluster] - cl_std[interval_cluster::interval_cluster],
        cl_mean[interval_cluster::interval_cluster] + cl_std[interval_cluster::interval_cluster],
        color='tab:orange',
        alpha=0.3
    )

axes[0].set_ylabel('Potential Energy \n(kJ/mol)')
axes[0].grid(alpha=0.2)
axes[1].set_xlabel('Time (ps)')
axes[1].set_ylabel('Number of Clusters')
axes[1].grid(alpha=0.2)
fig.legend(bbox_to_anchor=(1.0, 1.0))
plt.tight_layout()
os.makedirs(figure_save_location, exist_ok=True)
fig.savefig(f'{figure_save_location}/PE_Clusters.png', bbox_inches="tight")

'''
Plot density vs time for equilibration_NPT
'''
if(ENSEMBLE == 'equilibration_NPT'):
    fig, ax = plt.subplots(1, 1)
    # Potential Energy
    t_pe, pe_mean, pe_std = compute_mean_std(
        configs_eq_thermo_list,
        'time (ps)',
        'density'
    )
    ax.plot(t_pe[interval_thermo::interval_thermo], pe_mean[interval_thermo::interval_thermo], color='tab:blue')
    if(len(configs_eq_thermo_list)>1): # denoting multiple configurations
        ax.fill_between(
            t_pe[interval_thermo::interval_thermo],
            pe_mean[interval_thermo::interval_thermo] - pe_std[interval_thermo::interval_thermo],
            pe_mean[interval_thermo::interval_thermo] + pe_std[interval_thermo::interval_thermo],
            color='tab:blue',
            alpha=0.3
        )
    ax.set(xlabel= 'Time (ps)', ylabel=r'Density ($kg/m^3$)')
    ax.grid(alpha=0.2)
    fig.savefig(f'{figure_save_location}/density.png', bbox_inches="tight")

'''
Plot Pressure vs time
'''
fig, ax = plt.subplots(1, 1)
# Potential Energy
t_pe, pe_mean, pe_std = compute_mean_std(
    configs_eq_thermo_list,
    'time (ps)',
    'P'
)
ax.plot(t_pe[interval_thermo::interval_thermo], pe_mean[interval_thermo::interval_thermo], color='tab:blue')
if(len(configs_eq_thermo_list)>1): # denoting multiple configurations
    ax.fill_between(
        t_pe[interval_thermo::interval_thermo],
        pe_mean[interval_thermo::interval_thermo] - pe_std[interval_thermo::interval_thermo],
        pe_mean[interval_thermo::interval_thermo] + pe_std[interval_thermo::interval_thermo],
        color='tab:blue',
        alpha=0.3
    )
ax.set(xlabel= 'Time (ps)', ylabel=r'Pressure (bar)')
ax.axhline(1, ls='--', color='black')
ax.grid(alpha=0.2)
fig.savefig(f'{figure_save_location}/pressure.png', bbox_inches="tight")

'''
Plot Temperature vs time
'''
fig, ax = plt.subplots(1, 1)
# Potential Energy
t_pe, pe_mean, pe_std = compute_mean_std(
    configs_eq_thermo_list,
    'time (ps)',
    'T'
)
ax.plot(t_pe[interval_thermo::interval_thermo], pe_mean[interval_thermo::interval_thermo], color='tab:blue')
if(len(configs_eq_thermo_list)>1): # denoting multiple configurations
    ax.fill_between(
        t_pe[interval_thermo::interval_thermo],
        pe_mean[interval_thermo::interval_thermo] - pe_std[interval_thermo::interval_thermo],
        pe_mean[interval_thermo::interval_thermo] + pe_std[interval_thermo::interval_thermo],
        color='tab:blue',
        alpha=0.3
    )
ax.set(xlabel= 'Time (ps)', ylabel=r'Temperature (K)')
ax.axhline(298, ls='--', color='black')
ax.grid(alpha=0.2)
fig.savefig(f'{figure_save_location}/temperature.png', bbox_inches="tight")