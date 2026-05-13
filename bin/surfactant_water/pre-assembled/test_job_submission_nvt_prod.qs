#!/bin/bash -l
#SBATCH --job-name=Test1_PA_NVT_prod_SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1G
#SBATCH --partition=standard
#SBATCH --time=0-24:00:00
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

# navigate to the desired folder
cd /lustre/ea-nrtmidas/users/3770/emulsion_stability/test/pre-assembled
mkdir -p Test-$no
cd Test-$no
cd surfactant_water

# NVT Production
mkdir -p production/nvt
mpirun gmx grompp -f mdp/nvt_prod.mdp -c equilibration/npt/npt_eq.gro -p top/assembled_system_surfactant_water.top -o production/nvt/nvt_prod.tpr
mpirun gmx mdrun -v -deffnm production/nvt/nvt_prod -cpt 15
