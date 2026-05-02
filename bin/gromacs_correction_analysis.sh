#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=idle
#SBATCH --account=ea-nrtmidas
#SBATCH --time=10:20:00
#SBATCH --job-name="gromacs_analysis"
#SBATCH --output="gromacs_analysis.out"
#SBATCH --error="gromacs_analysis.err"
#SBATCH --comment "Obtain GROMACS analysis files through python file automation."

#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=gokul@udel.edu
#SBATCH --mail-type=FAIL
#SBATCH --export=NONE
#UD_QUIET_JOB_SETUP=YES
#UD_MACHINE_FILE_FORMAT='%h%[:]C'
#export UD_JOB_EXIT_FN_SIGNALS="SIGTERM EXIT"  

# adding necessary packages
vpkg_require gromacs  
vpkg_require conda
conda activate md

# execute python file
notebook_path=/lustre/ea-nrtmidas/users/3770/emulsion_stability/notebooks/properties.py
raw_dir=/lustre/ea-nrtmidas/users/3770/emulsion_stability/data/raw/self_assembly_polymer_surfactant530_toluene_water_20260430-171831
python $notebook_path $raw_dir
