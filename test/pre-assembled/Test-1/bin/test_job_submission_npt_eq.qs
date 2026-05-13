#!/bin/bash -l
#SBATCH --job-name=Test1_PA_NPT_Eq_SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1G
#SBATCH --partition=idle
#SBATCH --time=0-2:00:00
#SBATCH --mail-user=gokul@udel.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --export=NONE
#UD_QUIET_JOB_SETUP=YES
#UD_MACHINE_FILE_FORMAT='%h%[:]C'
#export UD_JOB_EXIT_FN_SIGNALS="SIGTERM EXIT"

# Packages
vpkg_require anaconda/2024.02
conda activate md
vpkg_require gromacs
. /opt/shared/slurm/templates/libexec/openmpi.sh

# User-Defined variables
no=1

# Copy relavant data and navigate to the desired folder
cd /lustre/ea-nrtmidas/users/3770/emulsion_stability/test/pre-assembled
mkdir -p Test-$no
cd Test-$no
cd surfactant_water

# NPT Equilibration
mpirun gmx grompp -f mdp/npt_eq.mdp -c equilibration/nvt/nvt_eq.gro -r equilibration/nvt/nvt_eq.gro -p top/assembled_system_surfactant_water.top -o equilibration/npt/npt_eq.tpr
mpirun gmx mdrun -v -deffnm equilibration/npt/npt_eq -cpt 10
